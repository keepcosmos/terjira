require_relative 'base'

module Terjira
  module Client
    class Agile < Base
      class << self
        delegate :all, :get_sprints, :backlog_issues, to: :resource

        def boards
          all["values"]
        end

        def active_sprint(board_id)
          resp = client.get("/rest/agile/latest/board/#{board_id}/sprint?state=active")
          sprints = JSON.parse(resp.body)["values"]
          sprints.first if sprints.is_a? Array
        end

        def sprints(board_id, options = {})
          sprints = get_sprints(board_id)["values"]
          sprints.sort_by do |sprint|
            if sprint["state"] == 'active'
              [0, sprint["id"]]
            elsif sprint["state"] == 'future'
              [1, sprint["id"]]
            elsif sprint["state"] == 'closed'
              [2, sprint["id"] * -1]
            else
              [3, 0]
            end
          end
        end

        def backlog_issues(board_id)
          get_backlog_issues(board_id)
        end

        def sprint_issues(board_id)

        end
      end
    end
  end
end
