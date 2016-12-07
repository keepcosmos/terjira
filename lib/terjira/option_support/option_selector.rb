# encoding: utf-8

require 'tty-prompt'
require_relative 'resource_store'

module Terjira
  module OptionSelector
    MENU_SEP = " - ".freeze

    def select_project
      fetch_resource :project do
        projects = fetch_resource(:projects) { Client::Project.all }
        option_prompt.select("Choose project?") do |menu|
          projects.each { |project| menu.choice project_choice_title(project), project }
        end
      end
    end

    def select_assignee
      fetch_resource(:assignee) do
        users = fetch_resource(:users) do
                  if issue = get_resource(:issue)
                    Client::User.assignables_by_issue(issue)
                  elsif board = get_resource(:board)
                    Client::User.assignables_by_board(board)
                  elsif sprint = get_resource(:sprint)
                    Client::User.assignables_by_sprint(board)
                  else
                    users = Client::User.assignables_by_project(select_project)
                  end
                end

        option_prompt.select("Choose assignee?") do |menu|
          users.each { |user| menu.choice user_choice_title(user), user }
        end
      end
    end

    def select_board(type = nil)
      fetch_resource(:board) do
        boards = fetch_resource(:boards) { Client::Board.all(type: type) }
        option_prompt.select("Choose board?") do |menu|
          boards.sort_by { |b| b.id }.each do |board|
            menu.choice "#{board.key_value}#{MENU_SEP}#{board.name}", board
          end
        end
      end
    end

    def select_sprint
      fetch_resource(:sprint) do
        board = select_board('scrum')
        sprints = fetch_resource(:sprints) { Client::Sprint.all(board) }
        option_prompt.select("Choose sprint?") do |menu|
          sort_sprint_by_state(sprints).each do |sprint|
            menu.choice sprint_choice_title(sprint), sprint
          end
        end
      end
    end

    def select_issuetype
      fetch_resource(:issuetype) do
        project = select_project
        if project.is_a? String
          project = Client::Project.find(project)
          set_resource(:project, project)
        end

        option_prompt.select("Choose isseu type?") do |menu|
          project.issuetypes.each do |issuetype|
            menu.choice issuetype.name, issuetype
          end
        end
      end
    end

    def select_issue_status
      fetch_resource(:status) do
        statuses = fetch_resource(:statuses) do
                     project = if issue = get_resource(:issue)
                                 if issue.respond_to?(:project)
                                   issue.project
                                 else
                                   set_resource(:issue, Client::Issue.find(issue)).project
                                 end
                               else
                                 select_project
                               end
                     Client::Status.all(project)
                   end

        option_prompt.select("Choose status?") do |menu|
          statuses.each do |status|
            menu.choice status.name, status
          end
        end
      end
    end

    def select_priority
      fetch_resource(:priority) do
        priorities = fetch_resource(:priorities) { Terjira::Client::Priority.all }
        option_prompt.select("Choose priority?") do |menu|
          priorities.each do |priority|
            menu.choice priority.name, priority
          end
        end
      end
    end

    def write_comment
      fetch_resource(:comment) do
        comment = option_prompt.multiline("Comment? (Return empty line for finish)\n",)
        comment.join("\n") if comment
      end
    end

    def write_description
      fetch_resource(:description) do
        desc = option_prompt.multiline("Description? (Return empty line for finish)\n",)
        desc.join("\n") if desc
      end
    end

    def write_summary
      fetch_resource(:summary) { option_prompt.ask("Summary?") }
    end

    private

    def sprint_choice_title(sprint)
      "#{sprint.key_value}#{MENU_SEP}#{sprint.name} (#{sprint.state.capitalize})"
    end

    def user_choice_title(user)
      "#{user.key_value}#{MENU_SEP}#{user.displayName}"
    end

    def project_choice_title(project)
      "#{project.key_value}#{MENU_SEP}#{project.name}"
    end

    def get_resource(resource_name)
      ResourceStore.instance.get(resource_name)
    end

    def set_resource(resource_name, resource)
      ResourceStore.instance.set(resource_name, resource)
    end

    def fetch_resource(resource_name, options = {}, &block)
      result = ResourceStore.instance.fetch(resource_name, &block)
    end

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
  end
end
