require_relative 'base_cli'

module Terjira
  class BoardCLI < BaseCLI
    default_task :active
    option "assignee", aliases: "-a", type: :string, desc: 'Assignee username. no option -> return only your issues, ALL -> issues of all assignees'
    desc "active", "show active sprint on the board"
    def active(board_id = nil)
      options[:assignee] = current_username unless options[:assignee]
      board_id = select_board(Client::Agile.boards) unless board_id
      sprint = Client::Agile.active_sprint(board_id)
      render_active_board sprint

      options[:sprint] ||= sprint["id"]
      issues = Client::Issue.all(options)
      render_divided_issues_by_status issues
    end

    desc "list", "show list of boards"
    map ls: :list
    def list
      boards = Client::Agile.boards
      render_boards_summary(boards.sort_by { |b| b["id"]})
    end
  end
end
