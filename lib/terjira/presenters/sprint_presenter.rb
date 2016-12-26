# encoding: utf-8

module Terjira
  module SprintPresenter
    def render_sprint_detail(sprint)
      return render('Empty') if sprint.nil?
      attrs = sprint.attrs
      summary = [
        pastel.bold("#{sprint.id}. #{sprint.name} #{colorize_sprint_state(sprint.state)}"),
        attrs['goal'].to_s,
        "#{formatted_date(attrs['startDate'])} ~ #{formatted_date(attrs['endDate'])}"
      ]

      render(summary.reject(&:empty?).join("\n"))
    end

    def render_sprints_summary(sprints)
      headers = %w(ID Summary).map { |h| pastel.bold(h) }
      rows = []
      sort_sprint_by_state(sprints).each do |sprint|
        rows << [pastel.bold(sprint.id), summarise_sprint(sprint)]
      end

      table = TTY::Table.new(headers, rows)
      result = table.render(:unicode, multiline: true) do |renderer|
        renderer.border.separator = :each_row
      end
      render(result)
    end

    def summarise_sprint(sprint)
      summary = colorize_sprint_state(sprint.state)
      summary += ' ' + pastel.bold(sprint.name)
      if sprint.respond_to? :startDate
        summary += "\n"
        summary += formatted_date(sprint.startDate) + ' ~ '
        summary += formatted_date(sprint.endDate) if sprint.respond_to? :endDate
      end
      summary += "\n#{sprint.goal}" if sprint.respond_to? :goal
      summary
    end

    def colorize_sprint_state(state)
      state = " #{state.to_s.capitalize} "
      if state =~ /active/i
        pastel.on_blue.bold(state)
      elsif state =~ /close/i
        pastel.dim(state)
      else
        pastel.on_magenta.bold(state)
      end
    end

    def sort_sprint_by_state(sprints)
      sprints.sort_by do |sprint|
        if sprint.state == 'active'
          [0, sprint.id]
        elsif sprint.state == 'future'
          [1, sprint.id]
        elsif sprint.state == 'closed'
          [2, sprint.id * -1]
        else
          [3, 0]
        end
      end
    end
  end
end
