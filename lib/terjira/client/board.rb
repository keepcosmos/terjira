module Terjira
  module Client
    class Board < Base
      class << self
        delegate :build, to: :resource

        def all(options = {})
          params = options.slice(:type)
          resp = agile_api_get('board', params)
          resp['values'].map { |value| build(value) }
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
