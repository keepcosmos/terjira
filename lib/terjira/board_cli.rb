require_relative 'base_cli'

module Terjira
  class BoardCLI < BaseCLI
    desc "list(ls)", "list all boards"
    map ls: :list
    def list
      boards = Client::Board.all
      render_boards_summary(boards.sort_by { |b| b.id })
    end
  end
end
