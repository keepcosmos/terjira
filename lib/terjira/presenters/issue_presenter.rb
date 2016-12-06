# encoding: utf-8

require 'tty-prompt'
require 'tty-table'
require 'pastel'

module Terjira
  module IssuePresenter
    def render_issues(issues, opts = {})
      header = [pastel.bold("Key"), pastel.bold("Summary")] if opts[:header]

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

      header_title = "#{pastel.bold(issue.key)} in #{issue.project.name}"

      header = [insert_new_line(header_title, screen_width - 10)]

      rows = []
      summary = issue.summary
      rows << pastel.underline.bold(summary)
      rows << ""
      rows << "#{title_pastel.("Type")}: #{colorize_issue_type(issue.issuetype)}\s\s\s#{title_pastel.("Status")}: #{colorize_issue_stastus(issue.status)}\s\s\s#{title_pastel.("priority")}: #{colorize_priority(issue.priority, title: true)}"
      rows << ""

      rows << title_pastel.("Assignee") + " " +  username_with_email(issue.assignee)
      rows << title_pastel.("Reporter") + " " + username_with_email(issue.reporter)
      rows << ""
      rows << title_pastel.("Description")
      rows << (issue.description.blank? ? "None" : issue.description.gsub("\r", ""))

      if issue.comments.present?
        rows << ""
        rows << title_pastel.("Comments")
        remain_comments = issue.comments
        comments = remain_comments.pop(4)

        if comments.size == 0
          rows << "None"
        elsif remain_comments.size > 0
          rows << pastel.dim("- #{remain_comments.size} previous comments exist -")
        end

        comments.each do |comment|
          rows << "#{pastel.bold(comment.author["displayName"])} <#{comment.author["emailAddress"]}> | #{formatted_date(comment.created)}"
          rows << comment.body
          rows << ""
        end
      end

      rows = rows.map { |row| insert_new_line(row, screen_width - 10) }

      table = TTY::Table.new header, rows.map { |r| [r] }
      result = table.render(:unicode, padding: [0, 1, 0, 1], multiline: true) do |renderer|
      end

      puts result
    end

    def summarise_issue(issue)
      first_line = colorize_issue_stastus(issue.status) + issue.summary.gsub("\t", " ")

      second_line = "#{colorize_priority(issue.priority)} #{colorize_issue_type(issue.issuetype)} "
      second_line += assign_info(issue)

      [first_line, second_line].map { |line| insert_new_line(line, screen_width - 30) }.join("\n")
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

    def colorize_priority(priority, opts = {})
      return '' unless priority.respond_to? :name
      name = priority.name
      info = if name =~ /high|major|critic/i
               { color: :red, icon: "⬆"}
             elsif name =~ /medium|default/i
               { color: :yellow, icon: "⬆"}
             elsif name =~ /minor|low|trivial/i
               { color: :green, icon: "⬇"}
             else
               { color: :green, icon: "•"}
             end
      title = opts[:title] ? "#{info[:icon]} #{name}" : info[:icon]
      pastel.send(info[:color], title)
    end

    def extract_status_names(issues)
      issues.sort_by do |issue|
        status_key = %w[new indeterminate done]
        idx = if issue.status.respond_to? :statusCategory
                status_key.index(issue.status.statusCategory["key"])
              end
        idx || status_key.size
      end.map { |issue| issue.status.name }.uniq
    end
  end
end
