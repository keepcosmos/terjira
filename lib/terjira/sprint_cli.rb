require_relative 'base_cli'

module Terjira
  class SprintCLI < BaseCLI
    desc "active [BOARD_ID]", "show active sprint and issues on the board"
    map a: :active
    jira_option(:assignee)
    def active(board_id = nil)
      board_id = select_board(Client::Board.all(type: 'scrum')) if board_id.nil?
      sprint = Client::Sprint.find_active(board_id)
      show(sprint.id)
    end

    desc "show [SPRINT_ID]", "show sprint"
    jira_option(:assignee)
    def show(sprint_id = nil)
      unless sprint_id
        board_id = select_board(Client::Board.all(type: 'scrum'))
        sprints = Client::Sprint.all(board_id)
        sprint_id = select_sprint(sprints)
      end
      options[:assignee] = current_username unless options[:assignee]
      sprint = Client::Sprint.find(sprint_id)
      unless sprint.nil?
        options[:sprint] ||= sprint.id
        issues = Client::Issue.all(options)
        render_sprint_detail sprint
        render_divided_issues_by_status issues
      end
    end

    desc "list(ls) [BOARD_ID]", "list all sprint in BOARD"
    jira_option :state, aliases: '-s', default: ['active', 'future'], enum: ['active', 'future', 'closed'], desc: 'states of sprint'
    map ls: :list
    def list(board_id = nil)
      board_id = select_board(Client::Board.all(type: 'scrum')) if board_id.nil?
      options[:state] = options[:state].join(",")
      sprints = Client::Sprint.all(board_id, options)
      render_sprints_summary sprints
    end
  end
end
