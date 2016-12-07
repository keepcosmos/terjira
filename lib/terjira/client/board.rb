module Terjira
  module Client
    class Board < Base
      class << self
        delegate :build, to: :resource

        def all(options = {})
          params = options.slice(:type)
          resp = agile_api_get("board", params)
          resp["values"].map { |value| build(value) }
        end

        def find(board_id)
          resp = agile_api_get("board/#{board_id}")
          self.build(resp)
        end
      end
    end
  end
end
