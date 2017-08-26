# encoding: utf-8

require 'tty-prompt'
require_relative 'resource_store'
require_relative 'editor'

module Terjira
  module OptionSelector
    delegate :get, :set, :fetch, to: :resource_store

    def select_project
      fetch :project do
        projects = fetch(:projects) { Client::Project.all }
        option_prompt.select('Choose project?', per_page: per_page(projects)) do |menu|
          projects.each { |project| menu.choice project_choice_title(project), project }
        end
      end
    end

    def select_board(type = nil)
      fetch(:board) do
        boards = fetch(:boards) { Client::Board.all(type: type) }
        option_prompt.select('Choose board?', per_page: per_page(boards)) do |menu|
          boards.sort_by(&:id).each do |board|
            menu.choice "#{board.key_value} - #{board.name}", board
          end
        end
      end
    end

    def select_sprint
      fetch(:sprint) do
        board = select_board('scrum')
        sprints = fetch(:sprints) { Client::Sprint.all(board) }
        option_prompt.select('Choose sprint?') do |menu|
          sort_sprint_by_state(sprints).each do |sprint|
            menu.choice sprint_choice_title(sprint), sprint
          end
        end
      end
    end

    def select_assignee
      fetch(:assignee) do
        users = fetch(:users) do
          if issue = get(:issue)
            Client::User.assignables_by_issue(issue)
          elsif board = get(:board)
            Client::User.assignables_by_board(board)
          elsif sprint = get(:sprint)
            Client::User.assignables_by_sprint(sprint)
          else
            users = Client::User.assignables_by_project(select_project)
          end
        end

        option_prompt.select('Choose assignee?', per_page: per_page(users)) do |menu|
          users.each { |user| menu.choice user_choice_title(user), user }
        end
      end
    end

    def select_issuetype
      fetch(:issuetype) do
        project = get(:issue).try(:project).try(:key)
        project ||= select_project
        if project.is_a? String
          project = Client::Project.find(project)
          set(:project, project)
        end

        option_prompt.select('Choose issue type?') do |menu|
          project.issuetypes.each do |issuetype|
            menu.choice issuetype.name, issuetype
          end
        end
      end
    end

    def select_issue_status
      fetch(:status) do
        statuses = fetch(:statuses) do
          project = if issue = get(:issue)
                      if issue.respond_to?(:project)
                        issue.project
                      else
                        set(:issue, Client::Issue.find(issue)).project
                      end
                    else
                      select_project
                    end
          Client::Status.all(project)
        end

        option_prompt.select('Choose status?') do |menu|
          statuses.each do |status|
            menu.choice status.name, status
          end
        end
      end
    end

    def select_priority
      fetch(:priority) do
        priorities = fetch(:priorities) { Terjira::Client::Priority.all }
        option_prompt.select('Choose priority?') do |menu|
          priorities.each do |priority|
            menu.choice priority.name, priority
          end
        end
      end
    end

    def select_resolution
      fetch(:resolution) do
        resolutions = fetch(:resolutions) { Terjira::Client::Resolution.all }
        option_prompt.select('Choose resolution?') do |menu|
          resolutions.each do |resolution|
            menu.choice resolution.name, resolution
          end
        end
      end
    end

    def write_epiclink_key
      fetch(:epiclink) do
        option_prompt.ask('Epic key?')
      end
    end

    def write_epic_name
      option_prompt.ask('Epic name?')
    end

    def write_comment
      fetch(:comment) do
        comment = Editor.editor_text
        comment = prompt_multiline('Comment') if !comment || comment.empty?

        comment
      end
    end

    def write_description
      fetch(:description) do
        desc = Editor.editor_text
        desc = prompt_multiline('Description') if !desc || desc.empty?

        desc
      end
    end

    def write_summary
      fetch(:summary) { option_prompt.ask('Summary?') }
    end

    def write_parent_issue_key
      fetch(:parent) { option_prompt.ask('Parent issue key?') }
    end

    private

    def prompt_multiline(prompt_for)
      result = option_prompt.multiline("#{prompt_for}? (Return empty line for finish)\n")
      result.join("") if result
    end

    def sprint_choice_title(sprint)
      "#{sprint.key_value} - #{sprint.name} (#{sprint.state.capitalize})"
    end

    def user_choice_title(user)
      "#{user.key_value} - #{user.displayName}"
    end

    def project_choice_title(project)
      "#{project.key_value} - #{project.name}"
    end

    def resource_store
      ResourceStore.instance
    end

    def option_prompt
      @option_prompt ||= TTY::Prompt.new
    end

    def per_page(objects)
      default_per_page = 10
      if objects.size < default_per_page
        objects.size
      else
        default_per_page
      end
    end
  end
end
