require_relative 'base_cli'

module Terjira
  class SprintCLI < BaseCLI

    desc "BOARD_ID", "show sprints"
    def show()

    end

    desc "list", "show sprints"
    def list(board_id = nil)
      if board_id.nil?
        boards = Client::Agile.boards
        board_id = select_board(boards)
      end
      sprints = Client::Agile.sprints(board_id)
      render_sprints_summary sprints
    end
  end
end
