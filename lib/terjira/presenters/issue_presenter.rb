require 'tty-prompt'
require 'tty-table'
require 'pastel'

module Terjira
  module IssuePresenter
    def render_issues(issues, options = {})
      header = [pastel.bold("Key"), pastel.bold("Summary")] if options[:header]

      rows = issues.map { |issue| [pastel.bold(issue.key), summarise_issue(issue)] }

      table = TTY::Table.new header, rows
      result = table.render(:unicode, padding: [0, 1, 0, 1], multiline: true) do |renderer|
        renderer.border.separator = :each_row
      end

      puts result
    end

    def render_divided_issues_by_status(issues)
      extract_status_names(issues).each do |name|
        selected_issues = issues.select { |issue| issue.status.name == name }
        title = colorize_issue_stastus(selected_issues.first.status)
        title += "(#{selected_issues.size})"
        puts title
        render_issues(selected_issues, header: false)
      end
    end

    def render_issue_detail(issue)
      title_pastel = pastel.bold.detach
      header = ["#{pastel.bold(issue.key)} in #{issue.project.name}"]

      rows = []
      rows << pastel.underline.bold("#{issue.summary}")
      rows << ""
      rows << "#{title_pastel.("Type")}: #{colorize_issue_type(issue.issuetype)}\s\s\s#{title_pastel.("Status")}: #{colorize_issue_stastus(issue.status)}\s\s\s#{title_pastel.("priority")}: #{colorize_priority(issue.priority)}"
      rows << ""
      rows << title_pastel.("Assignee") + " #{issue.assignee.displayName}(#{issue.assignee.name}, #{issue.assignee.emailAddress})"
      rows << title_pastel.("Reporter") + " #{issue.reporter.displayName}(#{issue.reporter.name}, #{issue.reporter.emailAddress})"
      rows << ""
      rows << title_pastel.("Description")
      rows << (issue.description.blank? ? "None" : issue.description.gsub("\r", ""))

      if issue.comments.present?
        rows << ""
        rows << title_pastel.("Comments")
        rows << "None" if issue.comments.size == 0
        issue.comments.each do |comment|
          rows << "#{pastel.bold(comment.author["displayName"])} <#{comment.author["emailAddress"]}> | #{formatted_date(comment.created)}"
          rows << comment.body
          rows << ""
        end
      end
      table = TTY::Table.new header, rows.map { |r| [r] }
      result = table.render(:unicode, padding: [0, 1, 0, 1], multiline: true) do |renderer|
      end

      puts result
    end

    def summarise_issue(issue)
      summary = colorize_issue_stastus(issue.status)
      summary += issue.summary.gsub("\t", " ") + "\n"
      summary += "#{colorize_priority(issue.priority, title: false)} #{colorize_issue_type(issue.issuetype)} "
      summary +=  assign_info(issue)
      summary
    end

    private

    def assign_info(issue)
      reporter = issue.reporter ? issue.reporter.name : "None"
      assignee = issue.assignee ? issue.assignee.name : "None"
      "#{reporter} ⇨ #{assignee}"
    end

    def colorize_issue_type(issue_type)
      title = " #{issue_type.name} "
      if title =~ /bug/i
        pastel.on_red.bold(title)
      elsif title =~ /task/i
        pastel.on_blue.bold(title)
      elsif title =~ /story/i
        pastel.on_green.bold(title)
      elsif title =~ /epic/i
        pastel.on_magenta.bold(title)
      else
        pastel.on_cyan.bold(title)
      end
    end

    def colorize_issue_stastus(status)
      title = "#{status.name} "
      category = status.try(:statusCategory).try(:[], "name") || ""
      if title =~ /to\sdo|open/i
        pastel.blue.bold(title)
      elsif title =~ /in\sprogress/i
        pastel.yellow.bold(title)
      elsif title =~ /done|close/i
        pastel.green.bold(title)
      else
        pastel.magenta.bold(title)
      end
    end

    def colorize_priority(priority, title: true)
      name = priority.name
      info = if name =~ /high|major|critic/i
               { color: :red, icon: "⬆", name: name }
             elsif name =~ /medium|default/i
               { color: :yellow, icon: "⬆", name: name }
             elsif name =~ /minor|low|trivial/i
               { color: :green, icon: "⬇", name: name }
             else
               { color: :green, icon: "•", name: name }
             end
      title = title ? "#{info[:icon]} #{info[:name]}" : info[:icon]
      pastel.send(info[:color], title)
    end

    def extract_status_names(issues)
      issues.sort_by do |issue|
        status_key = %w[new indeterminate done]
        idx = status_key.index(issue.status.statusCategory["key"])
        idx || status_key.size
      end.map { |issue| issue.status.name }.uniq
    end
  end
end
