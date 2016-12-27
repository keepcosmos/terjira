# encoding: utf-8

require 'tty-prompt'
require 'tty-table'
require 'pastel'
require 'erb'

module Terjira
  module IssuePresenter
    COMMENTS_SIZE = 3

    def render_issues(issues, opts = {})
      return render('Empty') if issues.blank?

      header = [pastel.bold('Key'), pastel.bold('Summary')] if opts[:header]

      rows = issues.map do |issue|
        [pastel.bold(issue.key), summarise_issue(issue)]
      end

      table = TTY::Table.new header, rows
      table_opts = { padding: [0, 1, 0, 1], multiline: true }
      result = table.render(:unicode, table_opts) do |renderer|
        renderer.border.separator = :each_row
      end

      render(result)
    end

    def render_divided_issues_by_status(issues)
      extract_status_names(issues).each do |name|
        selected_issues = issues.select { |issue| issue.status.name == name }
        title = colorize_issue_stastus(selected_issues.first.status)
        title += "(#{selected_issues.size})"
        render(title)
        render_issues(selected_issues, header: false)
      end
    end

    def render_issue_detail(issue, epic_issues = [])
      result = ERB.new(issue_detail_template, nil, '-').result(binding)
      result += ERB.new(comments_template, nil, '-').result(binding)
      rows = insert_new_line(result, screen_width - 15)
      table = TTY::Table.new nil, rows.split("\n").map { |r| [r] }
      render table.render(:unicode, padding: [0, 1, 0, 1], multiline: true)
    end

    def summarise_issue(issue)
      first_line = [colorize_issue_stastus(issue.status),
                    issue.summary.tr("\t", ' ')].join(' ')

      second_line = [colorize_priority(issue.priority),
                     colorize_issue_type(issue.issuetype),
                     issue.assignee.try(:name)].join(' ')

      lines = [first_line, second_line].map do |line|
        insert_new_line(line, screen_width - 30)
      end
      lines.join("\n")
    end

    def issue_detail_template
      %{<%= bold(issue.key) + ' in ' + issue.project.name %>

      <%= bold(issue.summary) %>

      Type: <%= colorize_issue_type(issue.issuetype) %>\s\sStatus: <%= colorize_issue_stastus(issue.status) %>\s\sPriority: <%= colorize_priority(issue.priority, title: true) %>
      <% if issue.parent.nil?  -%>

        Epic: <%= issue.try(:epic).try(:key) %> <%= issue.try(:epic).try(:name) || dim_none %>
      <% end -%>
      <% if issue.try(:parent) && issue.epic.nil? -%>
        Parent: <%= issue.parent.key %>
      <% end %>
      <% if issue.try(:sprint) -%>
        Sprint: <%= colorize_sprint_state(issue.try(:sprint).try(:state)) %> <%= issue.try(:sprint).try(:id) %>. <%= issue.try(:sprint).try(:name) %>
      <% end -%>
      <% if estimate = issue_estimate(issue) -%>

        <%= estimate[0] %>: <%= estimate[1] %>
      <% end -%>

      Assignee: <%= username(issue.assignee) %>
      Reporter: <%= username(issue.reporter) %>

      <%= issue.description || dim("No description") %>
      <% if issue.try(:environment) -%>

        <%= Environment %>:
        <%= issue.environment %>
      <% end -%>
      <% if issue.try(:attachment).present? -%>

        <%= bold('Attachment') %>
        <%= issue.attachment.map { |item| item['filename'] }.join(", ") %>
      <% end -%>
      <% if issue.subtasks.size > 0 -%>

        <%= bold('SubTasks') %>
        <% issue.subtasks.each do |subtask| -%>
          * <%= bold(subtask.key) %> <%= colorize_issue_stastus(subtask.status) %> <%= subtask.summary %>
        <% end -%>
      <% end -%>
      <% if epic_issues.present? -%>

        <%= bold('Issues in Epic') %>
        <% epic_issues.each do |epic_issue| -%>
          * <%= bold(epic_issue.key) %> <%= colorize_issue_stastus(epic_issue.status) %> <%= epic_issue.summary %>
        <% end -%>
      <% end -%>
      }
    end

    def comments_template
      """
      <% remain_comments = issue.comments -%>
      <% visiable_comments = remain_comments.pop(COMMENTS_SIZE) -%>
      Comments:
      <% if visiable_comments.empty? -%>
        <%= dim_none %>
      <% elsif remain_comments.size != 0 -%>
        <%= pastel.dim('- ' + remain_comments.size.to_s + ' previous comments exist -') %>
      <% end -%>
      <% visiable_comments.each do |comment| -%>
        <%= comment.body %>
        - <%= comment.author['displayName'] %> <%= formatted_date(comment.created) %>
      <% end -%>
      """
    end

    private

    def colorize_issue_type(issue_type)
      title = " #{issue_type.name} "
      background = if title =~ /bug/i
                     :on_red
                   elsif title =~ /task/i
                     :on_blue
                   elsif title =~ /story/i
                     :on_green
                   elsif title =~ /epic/i
                     :on_magenta
                   else
                     :on_cyan
                   end
      pastel.decorate(title, :white, background, :bold)
    end

    def colorize_issue_stastus(status)
      category = status.statusCategory['name'] rescue nil
      category ||= status.name
      title = "#{status.name}"

      color = if category =~ /to\sdo|open/i
                :blue
              elsif category =~ /in\sprogress/i
                :yellow
              elsif category =~ /done|close/i
                :green
              else
                :magenta
              end
      pastel.decorate(title, color, :bold)
    end

    def colorize_priority(priority, opts = {})
      return '' unless priority.respond_to? :name
      name = priority.name
      infos = if name =~ /high|major|critic/i
                [:red, '⬆']
              elsif name =~ /medium|default/i
                [:yellow, '⬆']
              elsif name =~ /minor|low|trivial/i
                [:green, '⬇']
              else
                [:green, '•']
              end
      title = opts[:title] ? "#{infos[1]} #{name}" : infos[1]
      pastel.decorate(title, infos[0])
    end

    # Extract estimate or story points
    # @return Array, first element is title and second is value
    def issue_estimate(issue)
      field = Client::Field.story_points
      story_points = issue.try(field.key) if field.respond_to? :key
      return ['Story Points', story_points] if story_points

      return unless issue.try(:timetracking).is_a? Hash

      if origin = issue.timetracking['originalEstimate']
        remain = issue.timetracking['remainingEstimate']
        ['Estimate', "#{remain} / #{origin}"]
      else
        ['Estimate', dim_none]
      end
    end

    def extract_status_names(issues)
      issue_names = issues.sort_by do |issue|
        status_key = %w(new indeterminate done)
        idx = if issue.status.respond_to? :statusCategory
                status_key.index(issue.status.statusCategory['key'])
              end
        idx || status_key.size
      end
      issue_names.map { |issue| issue.status.name }.uniq
    end
  end
end
