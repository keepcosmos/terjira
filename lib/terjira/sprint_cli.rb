require_relative 'base_cli'

module Terjira
  # CLI for Sprints
  class SprintCLI < BaseCLI
    no_commands do
      def client_class
        Client::Sprint
      end
    end

    default_task :show

    desc '[SPRINT_ID]', 'Default, show sprint'
    jira_option(:assignee)
    def show(sprint = nil)
      opts = suggest_options(required: [:sprint], resources: { sprint: sprint })
      sprint = client_class.find(opts[:sprint])
      opts[:assignee] ||= current_username

      issues = Client::Issue.all(opts.merge(sprint: sprint))
      render_sprint_with_issues(sprint, issues)
    end

    desc 'active', 'Show active sprints and issues from the board'
    jira_options :board, :assignee
    def active
      opts = suggest_options(required: [:board])
      board = opts[:board]
      sprints = client_class.find_active(board)

      opts[:assignee] ||= current_username

      sprints.each do |sprint|
        issues = Client::Issue.all(opts.merge(sprint: sprint))
        render_sprint_with_issues(sprint, issues)
      end
    end

    desc '( ls | list )', 'list all sprint from the board'
    jira_options :board, :state
    map ls: :list
    def list
      opts = suggest_options(required: [:board])

      state = opts['state'].join(',') if opts['state']
      sprints = client_class.all(opts[:board], state: state)
      render_sprints_summary sprints
    end

    no_commands do
      def render_sprint_with_issues(sprint, issues)
        render_sprint_detail sprint
        render_divided_issues_by_status issues
      end
    end
  end
end
