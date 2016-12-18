require_relative 'base_cli'

module Terjira
  class BoardCLI < BaseCLI
    no_commands do
      def client_class
        Client::Board
      end
    end

    desc "( ls | list)", "List all boards"
    map ls: :list
    def list
      boards = client_class.all
      render_boards_summary(boards.sort_by { |b| b.id })
    end

    desc "backlog", "Backlog from the board"
    jira_options :board, :assignee, :issuetype, :priority
    def backlog
      opts = suggest_options(required: [:board])
      board = opts.delete(:board)
      issues = client_class.backlog(board.key_value, opts)
      render_issues(issues)
    end
  end
end
