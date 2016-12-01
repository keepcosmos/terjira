require 'tty-prompt'
require_relative 'resource_store'

module Terjira
  module OptionBuilder
    MENU_SEP = " - ".freeze

    def select_project
      if project = resource_store.get(:project)
        return project
      end

      projects = resource_store.fetch(:projects) do
        Client::Project.all
      end

      project = option_prompt.select("Choose project?") do |menu|
        projects.each do |project|
          menu.choice "#{project.key_value}#{MENU_SEP}#{project.name}", project
        end
      end
      resource_store.set(:project, project)
    end

    def select_assignee
      if assignee = resource_store.get(:assignee)
        return assignee
      end

      users = resource_store.get(:users)

      issue = resource_store.get(:issue)
      users = Client::User.assignables_by_issue(issue) if users.nil? && issue

      if users.nil?
        project = select_project
        users = Client::User.assignables_by_project(project)
      end

      resource_store.set(:users, users)

      assignee = option_prompt.select("Choose assignee?") do |menu|
        users.each do |user|
          menu.choice "#{user.key_value}#{MENU_SEP}#{user.displayName}", user
        end
      end

      resource_store.set(:assignee, assignee)
    end

    def select_board(type = nil)
      boards = resource_store.fetch(:boards) do
        Client::Board.all(type: type)
      end

      board = option_prompt.select("Choose board?") do |menu|
        boards.sort_by { |b| b.id }.each do |board|
          menu.choice "#{board.key_value}#{MENU_SEP}#{board.name}", board
        end
      end

      resource_store.set(:board, board)
    end

    def select_sprint
      board = select_board('scrum')

      sprints = resource_store.fetch(:sprints) do
        Client::Sprint.all(board)
      end

      sprint = option_prompt.select("Choose sprint?") do |menu|
        sort_sprint_by_state(sprints).each do |sprint|
          menu.choice "#{sprint.key_value}#{MENU_SEP}#{sprint.name} (#{sprint.state.capitalize})", sprint
        end
      end

      resource_store.set(:sprint, sprint)
    end

    private

    def option_prompt
      @option_prompt ||= TTY::Prompt.new
    end

    def clean_options
      result = {}
      options.each do |key, value|
        if key.to_s == value.to_s
          result[key.to_sym] = nil
        elsif (value.downcase != "all")
          result[key.to_sym] = value
        end
      end
      result
    end

    def resource_store
      ResourceStore.instance
    end
  end
end
