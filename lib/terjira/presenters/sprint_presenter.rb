module Terjira
  module SprintPresenter
    def render_sprints_summary(sprints)
      headers = ["ID", "Summary"].map { |h| pastel.bold(h) }
      rows = []
      sprints.each do |sprint|
        rows << [pastel.bold(sprint["id"]), summarise_sprint(sprint)]
      end

      table = TTY::Table.new(headers, rows)
      result = table.render(:unicode, multiline: true) do |renderer|
        renderer.border.separator = :each_row
      end
      puts result
    end

    def summarise_sprint(sprint)
      summary = colorize_sprint_state(sprint["state"])
      summary += " " + pastel.bold(sprint["name"])
      if sprint["startDate"]
        summary += "\n"
        summary += formatted_date(sprint["startDate"]) + " ~ "
        summary += formatted_date(sprint["endDate"]) if sprint["endDate"]
      end
      summary += "\n#{sprint["goal"]}" if sprint["goal"]
      summary
    end

    def colorize_sprint_state(state)
      state = state.capitalize
      if(state =~ /active/i)
        pastel.on_blue.bold(state)
      elsif(state =~ /close/i)
        pastel.on_black.bold.dim(state)
      else
        pastel.on_magenta.bold(state)
      end
    end
  end
end
