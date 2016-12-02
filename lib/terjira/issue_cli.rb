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
    jira_options :assignee, :'status-category', :status, :project, :type, :priority
    map ls: :list
    def list
      options[:statusCategory] = ["To Do", "In Progress"] unless options[:status]
      options[:assignee] = current_username unless options[:assignee]
      options[:issuetype] = options.delete(:type) if options[:type]

      issues = Client::Issue.all(options)
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
    def new
    end

    desc "edit", "edit issue"
    def edit(issue)
    end

    desc "take [KEY]", "assign issue to self"
    def take(issue)
    end

    desc "assign [KEY] ([assignee])", "assing issue to user"
    def assign(issue, assignee = nil)
    end
  end
end
