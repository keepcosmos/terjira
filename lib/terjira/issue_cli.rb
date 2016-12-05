# encoding: utf-8

require_relative 'base_cli'

module Terjira
  class IssueCLI < BaseCLI

    desc 'show [ISSUE_KEY]', 'Show detail of the issue'
    def show(issue_key = nil)
      return invoke(:help) unless issue_key
      issue = Client::Issue.find(issue_key)
      render_issue_detail(issue)
    end

    desc "ls", "List of isseus"
    jira_options :assignee, :status, :project, :issuetype, :priority
    map ls: :list
    def list
      opts = suggest_options
      opts[:statusCategory] ||= ["To Do", "In Progress"] unless opts[:status]
      opts[:assignee] ||= current_username
      opts.delete(:assignee) if opts[:assignee] =~ /^all/i

      issues = Client::Issue.all(opts)
      render_issues(issues)
    end

    desc 'trans [KEY] [STATUS]', 'Update status of the issue'
    def trans(issue, *args)
      status = if args.size == 1
                 args.first
               elsif args.size > 1
                 args.join(" ")
               end
    end

    desc "new", "create issue"
    jira_options :project, :issuetype, :priority, :status, :summary, :assignee
    def new
      opts = suggest_options(required: [:project, :summary, :issuetype])
      result = Client::Issue.create(opts)
      puts result.map { |k, v| "#{k}=#{v.key_value}"}
    end

    desc "edit", "edit issue"
    def edit(issue)
    end

    desc "commenct", "comment issue"
    jira_options :comment
    def comment(issue)
      opts = suggest_options(required: [:comment])
      10.times do
        if comment_id = Client::Issue.write_comment(issue, opts[:comment])
          puts pastel.blue.bold("Success! comment id: #{comment_id}")
        else
          puts pastel.red("Error")
        end
      end
    end

    desc "take ISSUE_KEY", "assign issue to self"
    def take(issue)
      assign(issue, current_username)
    end

    desc "assign ISSUE_KEY (ASSIGNEE)", "assing issue to user"
    def assign(*keys)
      issue = keys[0]
      assignee = keys[1]
      if assignee.nil?
        issue = Client::Issue.find(issue)
        opts = suggest_options(required: [:assignee],
                               resouces: { issue: issue })
        assignee = opts[:assignee]
      end
      Client::Issue.assign(issue, assignee)
      show(issue.key_value)
    end
  end
end
