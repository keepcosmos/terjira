require_relative 'base'

module Terjira
  module Client
    class Agile < Base
      class << self
        delegate :all, :get_sprints, :backlog_issues, to: :resource

        def project_by_board(board_id)
          agile_api_get("board/#{board_id}/project")
        end

        def boards
          all['values']
        end

        def sprints(board_id)
          sprints = get_sprints(board_id)['values']
          sprints.sort_by do |sprint|
            if sprint['state'] == 'active'
              [0, sprint['id']]
            elsif sprint['state'] == 'future'
              [1, sprint['id']]
            elsif sprint['state'] == 'closed'
              [2, sprint['id'] * -1]
            else
              [3, 0]
            end
          end
        end

        def backlog_issues(board_id)
          get_backlog_issues(board_id)
        end
      end
    end
  end
end
