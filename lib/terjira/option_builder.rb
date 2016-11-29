require 'tty-prompt'

module Terjira
  module OptionBuilder
    def select_project(projects)
      sep = " - "
      keys = projects.map { |p| [p.key + sep + p.name] }
      option_prompt.select("Choose project?", keys).split(sep)[0]
    end

    def select_assignee(assignees)
      choose_options = assignees.map { |user| "#{user.name} (#{user.displayName})" }
      result = option_prompt.select("Choose assignee?", choose_options)
      result.split(/\s\(/).first
    end

    def select_board(boards)
      sep = " - "
      keys = boards.sort_by { |b| b.id }.map do |board|
        ["#{board.id}#{sep}#{board.name}"]
      end
      option_prompt.select("Choose board?", keys).split(sep)[0]
    end

    def select_sprint(sprints)
      sep = " - "
      keys = sort_sprint_by_state(sprints).map do |sprint|
        ["#{sprint.id}#{sep}#{sprint.name} (#{sprint.state.capitalize})"]
      end
      option_prompt.select("Choose board?", keys).split(sep)[0]
    end

    private

    def option_prompt
      @option_prompt ||= TTY::Prompt.new
    end
  end
end
