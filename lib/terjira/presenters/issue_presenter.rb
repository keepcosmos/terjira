# encoding: utf-8

require 'tty-prompt'
require 'tty-table'
require 'pastel'

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

    def render_issue_detail(issue)
      header_title = "#{pastel.bold(issue.key)} in #{issue.project.name}"
      header = [insert_new_line(header_title, screen_width - 10)]

      rows = []
      rows << pastel.underline.bold(issue.summary)
      rows << ''
      rows << issue_sutats_partial(issue)
      rows << ''

      rows << [pastel.bold('Assignee'), username_with_email(issue.assignee)].join(' ')
      rows << [pastel.bold('Reporter'), username_with_email(issue.reporter)].join(' ')
      rows << ''
      rows << pastel.bold('Description')
      rows << (issue.description.blank? ? 'None' : issue.description)

      if issue.respond_to?(:environment) && issue.environment.present?
        rows << pastel.bold('Environment')
        rows << issue.environment
      end

      if issue.respond_to? :timetracking
        rows << ''
        rows << "#{pastel.bold('Estimate')} #{estimate_partial(issue)}"
      end

      if issue.comments.present?
        rows << ''
        rows << pastel.bold('Comments')
        remain_comments = issue.comments
        comments = remain_comments.pop(COMMENTS_SIZE)

        if comments.size.zero?
          rows << 'None'
        elsif remain_comments.present?
          rows << pastel.dim("- #{remain_comments.size} previous comments exist -")
        end

        comments.each do |comment|
          comment_title = pastel.bold(comment.author['displayName'])
          comment_title += " #{formatted_date(comment.created)}"
          rows << comment_title
          rows << comment.body
          rows << ''
        end
      end

      rows = rows.map { |row| insert_new_line(row, screen_width - 10) }

      table = TTY::Table.new header, rows.map { |r| [r] }
      result = table.render(:unicode, padding: [0, 1, 0, 1], multiline: true)

      render(result)
    end

    def summarise_issue(issue)
      first_line = [colorize_issue_stastus(issue.status),
                    issue.summary.tr("\t", ' ')].join

      second_line = [colorize_priority(issue.priority),
                     colorize_issue_type(issue.issuetype),
                     assign_info(issue)].join(' ')

      lines = [first_line, second_line].map do |line|
        insert_new_line(line, screen_width - 30)
      end
      lines.join("\n")
    end

    private

    def assign_info(issue)
      reporter = issue.reporter ? issue.reporter.name : 'None'
      assignee = issue.assignee ? issue.assignee.name : 'None'
      "#{reporter} ⇨ #{assignee}"
    end

    def issue_sutats_partial(issue)
      bar = ["#{pastel.bold('Type')}: #{colorize_issue_type(issue.issuetype)}",
             "#{pastel.bold('Status')}: #{colorize_issue_stastus(issue.status)}",
             "#{pastel.bold('priority')}: #{colorize_priority(issue.priority, title: true)}"]
      bar.join("\s\s\s")
    end

    def estimate_partial(issue)
      return unless issue.timetracking.is_a? Hash
      original_estimate = issue.timetracking['originalEstimate']
      remaining_estimate = issue.timetracking['remainingEstimate']
      "#{remaining_estimate} / #{original_estimate}"
    end

    def colorize_issue_type(issue_type)
      title = " #{issue_type.name} "
      if title =~ /bug/i
        pastel.on_red.white.bold(title)
      elsif title =~ /task/i
        pastel.on_blue.white.bold(title)
      elsif title =~ /story/i
        pastel.on_green.white.bold(title)
      elsif title =~ /epic/i
        pastel.on_magenta.white.bold(title)
      else
        pastel.on_cyan.white.bold(title)
      end
    end

    def colorize_issue_stastus(status)
      title = "#{status.name} "
      category = title
      if status.respond_to? :statusCategory
        category = (status.statusCategory || {})['name'] || ''
      end
      if category =~ /to\sdo|open/i
        pastel.blue.bold(title)
      elsif category =~ /in\sprogress/i
        pastel.yellow.bold(title)
      elsif category =~ /done|close/i
        pastel.green.bold(title)
      else
        pastel.magenta.bold(title)
      end
    end

    def colorize_priority(priority, opts = {})
      return '' unless priority.respond_to? :name
      name = priority.name
      info = if name =~ /high|major|critic/i
               { color: :red, icon: '⬆' }
             elsif name =~ /medium|default/i
               { color: :yellow, icon: '⬆' }
             elsif name =~ /minor|low|trivial/i
               { color: :green, icon: '⬇' }
             else
               { color: :green, icon: '•' }
             end
      title = opts[:title] ? "#{info[:icon]} #{name}" : info[:icon]
      pastel.send(info[:color], title)
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
