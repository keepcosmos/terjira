require 'tty-prompt'
require_relative 'editor'
require_relative 'resource_store'

module Terjira
  module OptionSelector
    delegate :get, :set, :fetch, to: :resource_store

    def with_editor=(with_editor = false)
      @with_editor = with_editor
    end

    def with_editor?
      @with_editor || false
    end

    def select_project
      fetch :project do
        projects = fetch(:projects) { Client::Project.all }
        selected_project =
          option_select_prompt.select('Choose project?', per_page: per_page(projects)) do |menu|
            projects.each { |project| menu.choice project_choice_title(project), project }
          end

        Client::Project.find(selected_project.id)
      end
    end

    def select_board(type = nil)
      fetch(:board) do
        boards = fetch(:boards) { Client::Board.all(type: type) }
        option_select_prompt.select('Choose board?', per_page: per_page(boards)) do |menu|
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
        option_select_prompt.select('Choose sprint?') do |menu|
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

        option_select_prompt.select('Choose assignee?', per_page: per_page(users)) do |menu|
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

        option_select_prompt.select('Choose issue type?') do |menu|
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

        option_select_prompt.select('Choose status?') do |menu|
          statuses.each do |status|
            menu.choice status.name, status
          end
        end
      end
    end

    def select_priority
      fetch(:priority) do
        priorities = fetch(:priorities) { Terjira::Client::Priority.all }
        option_select_prompt.select('Choose priority?') do |menu|
          priorities.each do |priority|
            menu.choice priority.name, priority
          end
        end
      end
    end

    def select_resolution
      fetch(:resolution) do
        resolutions = fetch(:resolutions) { Terjira::Client::Resolution.all }
        option_select_prompt.select('Choose resolution?') do |menu|
          resolutions.each do |resolution|
            menu.choice resolution.name, resolution
          end
        end
      end
    end

    def write_epiclink_key
      fetch(:epiclink) do
        option_prompt.ask('Epic Key?')
      end
    end

    def write_epic_name
      option_prompt.ask('Epic Name?')
    end

    def write_comment
      fetch(:comment) do
        if with_editor?
          Editor.editor_text
        else
          prompt_multiline('Comment')
        end
      end
    end

    def update_comment
      fetch(:editable_comment) do
        selected_comment = user_comment

        if selected_comment.present?
          new_content = Editor.editor_text(selected_comment.body)

          { 'selected_comment' => selected_comment, 'new_content' => new_content }
        end
      end
    end

    def write_description
      fetch(:description) do
        if with_editor?
          Editor.editor_text
        else
          prompt_multiline('Description')
        end
      end
    end

    def write_summary
      fetch(:summary) { option_prompt.ask('Summary?') }
    end

    def write_parent_issue_key
      fetch(:parent) { option_prompt.ask('Parent Issue Key?') }
    end

    private

    def user_comment
      comment_id = get(:comment_id)

      if comment_id.present?
        user_comments.detect do |c|
          c.id == comment_id && c.author['name'] == current_username
        end
      else
        user_comments.reverse.detect do |c|
          c.author['name'] == current_username
        end
      end
    end

    def user_comments
      issue = Client::Issue.find(get(:issue))

      unless issue.comments.empty?
        issue
          .comments
          .reverse
          .select { |c| c.author['name'] == current_username }
      end || []
    end

    def prompt_multiline(prompt_for)
      result = option_prompt.multiline("#{prompt_for}?")
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
      @option_prompt ||= TTY::Prompt.new(help_color: :cyan)
    end

    def option_select_prompt
      return @_option_select_prompt if @_option_select_prompt
      @_option_select_prompt = TTY::Prompt.new(help_color: :cyan)
      @_option_select_prompt.on(:keypress) do |event|
        # emacs key binding
        { "\u000E" => :keydown, "\u0010" => :keyup }.each do |key, action|
          @_option_select_prompt.trigger(action) if event.value == key
        end
        # vim key binding
        { 'j' => :keydown, 'k' => :keyup, 'h' => :keyleft, 'l' => :keyright }.each do |key, action|
          @_option_select_prompt.trigger(action) if event.value == key
        end
      end
      @_option_select_prompt
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
