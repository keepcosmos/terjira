module Terjira
  module BoardPresenter

    def render_boards_summary(boards)
      pastel = Pastel.new

      header = ["ID", "Name", "Type"].map { |title| pastel.bold(title) }
      rows = []
      boards.each do |board|
        rows << [pastel.bold(board["id"]), board["name"], board["type"]]
      end

      table = TTY::Table.new header, rows
      result = table.render(:unicode, padding: [0, 1, 0, 1])

      puts result
    end

    def render_active_board(sprint)
      summary = [
        pastel.bold("#{sprint["id"]}. #{sprint["name"]} #{colorize_sprint_state(sprint["state"])}"),
        "#{sprint["goal"]}",
        "#{formatted_date(sprint["startDate"])} ~ #{formatted_date(sprint["endDate"])}"
      ]

      puts summary.join("\n")
    end

    def select_board(boards)
      prompt = TTY::Prompt.new
      sep = " - "
      keys = boards.sort_by { |b| b["id" ] }.map { |board| [board["id"].to_s + sep + board["name"].to_s] }
      prompt.select("Choose board?", keys).split(sep)[0]
    end
  end
end
