# encoding: utf-8

require_relative 'base_cli'

module Terjira
  class IssueCLI < BaseCLI
    no_commands do
      def client_class
        Client::Issue
      end
    end

    default_task :show

    desc '[ISSUE_KEY]', 'Show detail of the issue'
    def show(issue = nil)
      return invoke(:help) unless issue
      issue = client_class.find(issue)
      if issue.issuetype.name.casecmp('epic').zero?
        epic_issues = client_class.all_epic_issues(issue)
        render_issue_detail(issue, epic_issues)
      else
        render_issue_detail(issue)
      end
    end

    desc 'open [ISSUE_KEY]', 'Open browser'
    def open(issue)
      open_url(client_class.site_url + "/browse/#{issue}")
    end

    desc '( ls | list )', 'List of issues'
    jira_options :assignee, :status, :project, :issuetype, :priority
    map ls: :list
    def list
      opts = suggest_options
      opts[:statusCategory] ||= default_status_categories unless opts[:status]
      opts[:assignee] ||= current_username
      opts.delete(:assignee) if opts[:assignee] =~ /^all/i

      issues = client_class.all(opts)
      render_issues(issues)
    end

    desc 'jql "[QUERY]"', "Search issues with JQL"
    long_desc <<-EXAMPLE
      jira issue jql "project = 'IST' AND assignee = currentuser()"
    EXAMPLE
    def jql(*query)
      jql = query.join(" ")
      render_issues Client::Issue.jql(jql)
    end

    desc 'new', 'Create an issue'
    jira_options :summary, :description, :project, :issuetype,
                 :priority, :assignee, :parent, :epiclink
    def new
      opts = suggest_options(required: [:project, :summary, :issuetype])

      suggest_related_value_options(opts)

      issue = client_class.create(opts)
      render_issue_detail(issue)
    end

    desc 'edit [ISSUE_KEY]', 'Edit the issue'
    jira_options :summary, :description, :project, :issuetype,
                 :priority, :assignee, :epiclink
    def edit(issue)
      return if options.blank?
      issue = client_class.find(issue)
      opts = suggest_options(resources: { issue: issue })
      suggest_related_value_options(opts)

      issue = client_class.update(issue, opts)
      render_issue_detail(issue)
    end

    desc 'delete [ISSUE_KEY]', 'Delete the issue'
    def delete(issue)
      client_class.delete(issue)
      render("Deleted")
    end

    desc 'comment [ISSUE_KEY]', 'Write comment on the issue'
    jira_options :comment
    def comment(issue)
      opts = suggest_options(required: [:comment])
      issue = client_class.write_comment(issue, opts[:comment])
      render_issue_detail(issue)
    end

    desc 'take [ISSUE_KEY]', 'Assign the issue to self'
    def take(issue)
      assign(issue, current_username)
    end

    desc 'assign [ISSUE_KEY] ([ASSIGNEE])', 'Assign the issue to user'
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

    desc 'search [SUMMARY]', 'Search for an issue by summary'
    def search(*keys)
      search_term = client_class.search(summary: keys[0])
      render_issues(search_term)
    end

    desc 'trans [ISSUE_KEY] ([STATUS])', 'Do transition'
    jira_options :comment, :assignee, :resolution
    def trans(*args)
      issue = args.shift
      raise 'must pass issue key or id' unless issue
      status = args.join(' ') if args.present?
      issue = client_class.find(issue, expand: 'transitions.fields')

      transitions = issue.transitions
      transition = transitions.find { |t| t.name.casecmp(status.to_s).zero? }

      resources = if transition
                    { status: transition, issue: issue }
                  else
                    { statuses: transitions, issue: issue }
                  end

      opts = suggest_options(required: [:status], resources: resources)
      issue = client_class.trans(issue, opts)
      render_issue_detail(issue)
    end

    no_commands do
      def default_status_categories
        Client::StatusCategory.all.reject { |category| category.key =~ /done/i }.map(&:name)
      end
    end
  end
end
