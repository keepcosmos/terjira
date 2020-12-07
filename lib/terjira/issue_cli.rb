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
      open_url(issue_url(issue))
    end

    desc 'url [ISSUE_KEY]', 'Print url for issue'
    def url(issue)
      puts issue_url(issue)
    end

    desc '( ls | list )', 'List of issues'
    jira_options :assignee, :status, :project, :issuetype, :priority
    map ls: :list
    def list
      opts = suggest_options
      opts[:statusCategory] ||= default_status_categories unless opts[:status]
      opts[:assignee] ||= current_username

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
    jira_options :assignee, :description, :epiclink, :editor,
                 :project, :priority, :summary, :issuetype, :parent
    def new
      opts = suggest_options(required: [:project, :summary, :issuetype])

      suggest_related_value_options(opts)

      issue = client_class.create(opts)
      render_issue_detail(issue)
    end

    desc 'edit [ISSUE_KEY]', 'Edit the issue'
    jira_options :assignee, :epiclink, :editor, :description,
                 :project, :priority, :summary, :issuetype
    def edit(issue)
      return puts "Pass options to be updated. Use 'jira issue help edit' for the options." if options.blank?
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

    desc 'priority [ISSUE_KEY] [NEW_PRIORITY]', 'Update priority of the issue'
    def prioirty(issue, newPriority = 3)
      client_class.prioirty(issue, newPriority)
      render("Priority Updated")
    end

    desc 'comment [ISSUE_KEY]', 'Write comment on the issue'
    jira_options :comment, :editor
    def comment(issue)
      opts = suggest_options(required: [:comment])
      issue = client_class.write_comment(issue, opts[:comment])
      render_issue_detail(issue)
    end

    desc 'edit_comment [ISSUE_KEY] ([COMMENT_ID])',
         "Edit user's comment on the issue.
          If COMMENT_ID is not given, it will choose user's last comment"
    jira_options :comment_id, :editable_comment
    def edit_comment(issue, comment_id = '')
      opts = suggest_options(
        resources: { issue: issue, comment_id: comment_id },
        required: [:editable_comment]
      )

      if opts['editable_comment'].present?
        selected_comment = opts['editable_comment']['selected_comment']
        new_content = opts['editable_comment']['new_content']

        issue = client_class.edit_comment(
          issue,
          selected_comment.id,
          new_content
        )
        render_issue_detail(issue)
      else
        render("You don't have any editable comment.")
      end
    end

    desc 'attach_file [ISSUE_KEY] [FILE]', 'Attach a file to the issue'
    jira_options :file
    def attach_file(issue, file)
      issue = client_class.attach_file(issue, file)
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

    desc 'search [SUMMARY]', 'Search for issues by summary'
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
        Client::StatusCategory.all.reject { |category| category.key =~ /done/i }.map(&:key)
      end
    end

    private

    def issue_url(issue)
      "#{client_class.site_url}/browse/#{issue}".gsub(/([^:])([\/]{2,})/, '\1/')
    end
  end
end
