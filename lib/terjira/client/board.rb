require_relative 'base'

module Terjira
  module Client
    class Board < Base
      class << self
        delegate :build, to: :resource

        def all(options = {})
          boards_resp = agile_api_get('board')['values']
          boards_resp = boards_resp.select { |board| board["type"] == options[:type] } if options[:type].present?
          boards_resp.map { |board| build(board) }
        end

        def find(board_id)
          resp = agile_api_get("board/#{board_id}")
          build(resp)
        end

        def backlog(board_id, options = {})
          jql = build_jql(options)
          resp = if jql.present?
                  agile_api_get("board/#{board_id}/backlog", jql: jql)
                 else
                   agile_api_get("board/#{board_id}/backlog")
                 end
          resp["issues"].map { |issue| Issue.build(issue) }
        end
      end
    end
  end
end
