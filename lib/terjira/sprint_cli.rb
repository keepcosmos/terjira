require_relative 'base_cli'

module Terjira
  class SprintCLI < BaseCLI

    no_commands do
      def client_class
        Client::Sprint
      end
    end

    desc "active", "show active sprint and issues on the board"
    jira_options :board, :assignee
    def active
      if options[:board].nil? || options[:board] == "board"
        board = select_board('scrum')
      else
        board = options[:board]
      end
      sprints = client_class.find_active(board)
      opts = suggest_options(required: [:sprint],
                             resources: { board: board, sprint: sprints.first }
                            )

      opts[:assignee] ||= current_username

      sprints.each do |sprint|
        issues = Client::Issue.all(opts)
        render_sprint_with_issues(sprint, issues)
      end
    end

    desc "show [SPRINT_ID]", "show sprint"
    jira_option(:assignee)
    def show(sprint = nil)
      sprint = client_class.find(sprint)
      opts = suggest_options(resources: { sprint: sprint })
      opts[:assignee] ||= current_username

      issues = Client::Issue.all(opts.merge({ sprint: sprint }))
      render_sprint_with_issues(sprint, issues)
    end

    desc "list|ls", "list all sprint in BOARD"
    jira_options :board, :state
    map ls: :list
    def list
      opts = suggest_options(required: [:board])
      puts ":::::#{opts}"
      if opts[:board].type == 'kanban'
        return render("Kanban board does not support sprints")
      end

      state = opts["state"].join(",") if opts["state"]
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
