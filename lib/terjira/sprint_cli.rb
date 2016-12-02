require_relative 'base_cli'

module Terjira
  class SprintCLI < BaseCLI

    desc "active [BOARD_ID]", "show active sprint and issues on the board"
    jira_options :assignee
    def active(board_id = nil)
      options[:assignee] ||= current_username
      if board_id.nil?
        board = select_board('scrum')
      else
        board = Client::Board.build("id" => board_id)
      end

      build_options!(resouces: { board: board })

      sprint = Client::Sprint.find_active(board)
      render_sprint_with_issues(sprint)
    end

    desc "show [SPRINT_ID]", "show sprint"
    jira_option(:assignee)
    def show(sprint_id = nil)
      options[:assignee] ||= current_username
      sprint_id = select_sprint unless sprint_id

      sprint = Client::Sprint.find(sprint_id)

      render_sprint_with_issues(sprint)
    end

    desc "list(ls)", "list all sprint in BOARD"
    jira_options :board, :"sprint-state"
    map ls: :list
    def list
      opts = suggest_options(required: [:board])

      if opts[:board].type == 'kanban'
        return puts "Kanban board does not support sprints"
      end

      state = opts["sprint-state"].join(",")
      sprints = Client::Sprint.all(opts[:board], state: state)
      render_sprints_summary sprints
    end

    no_commands do
      def render_sprint_with_issues(sprint)
        unless sprint.nil?
          options[:sprint] ||= sprint.id
          issues = Client::Issue.all(options)
        end
        render_sprint_detail sprint
        render_divided_issues_by_status issues
      end
    end
  end
end
