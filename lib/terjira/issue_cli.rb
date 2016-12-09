# encoding: utf-8

require_relative 'base_cli'

module Terjira
  class IssueCLI < BaseCLI

    no_commands do
      def client_class
        Client::Issue
      end
    end

    desc 'show [ISSUE_KEY]', 'Show detail of the issue'
    def show(issue_key = nil)
      return invoke(:help) unless issue_key
      issue = client_class.find(issue_key)
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

      issues = client_class.all(opts)
      render_issues(issues)
    end

    desc 'trans [KEY] [STATUS]', 'Update status of the issue'
    jira_options :comment, :assignee, :resolution
    def trans(*args)
      issue = args.shift
      raise "must pass issue key or id" unless issue
      status = args.join(" ") if args.present?
      issue = client_class.find(issue, { expand: 'transitions.fields' })

      transitions = issue.transitions
      transition = transitions.find do |t|
        t.name.downcase == status.to_s.downcase
      end

      resources = if transition
                    { status: transition, issue: issue }
                  else
                    { statuses: transitions, issue: issue }
                  end

      opts = suggest_options(required: [:status], resources: resources )
      issue = client_class.trans(issue, opts)
      render_issue_detail(issue)
    end

    desc "new", "create issue"
    jira_options :summary, :description, :project, :issuetype,
                 :priority, :assignee
    def new
      opts = suggest_options(required: [:project, :summary, :issuetype])

      if opts[:issuetype].key_value.downcase == "epic"
        epic_name_field = Client::Field.epic_name
        opts[epic_name_field.key] = write_epic_name
      end

      issue = client_class.create(opts)
      render_issue_detail(issue)
    end

    desc "edit", "edit issue"
    jira_options :summary, :description, :project, :issuetype,
                 :priority, :assignee
    def edit(issue)
      return if options.blank?
      issue = client_class.find(issue)
      opts = suggest_options(resources: { issue: issue })
      issue = client_class.update(issue, opts)
      render_issue_detail(issue)
    end

    desc "commenct", "comment issue"
    jira_options :comment
    def comment(issue)
      opts = suggest_options(required: [:comment])
      issue = client_class.write_comment(issue, opts[:comment])
      render_issue_detail(issue)
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
        issue = client_class.find(issue)
        opts = suggest_options(required: [:assignee],
                               resouces: { issue: issue })
        assignee = opts[:assignee]
      end
      client_class.assign(issue, assignee)
      show(issue.key_value)
    end
  end
end
