module Terjira
  module BoardPresenter
    def render_boards_summary(boards)
      pastel = Pastel.new

      header = %w(ID Name Type).map { |title| pastel.bold(title) }
      rows = []
      boards.each do |board|
        rows << [pastel.bold(board.id), board.name, board.type]
      end

      table = TTY::Table.new header, rows
      result = table.render(:unicode, padding: [0, 1, 0, 1])

      render(result)
    end
  end
end
