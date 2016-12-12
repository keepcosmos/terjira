require_relative 'base'

module Terjira
  module Client
    class Sprint < Base
      class << self
        delegate :build, to: :resource

        def all(board, options = {})
          params = options.slice(:state, :maxResults)
          resp = agile_api_get "board/#{board.key_value}/sprint", params
          resp['values'].map { |value| build(value) }
        end

        def find(sprint)
          resp = agile_api_get "sprint/#{sprint.key_value}"
          build resp
        end

        def find_active(board)
          params = { state: 'active' }
          resp = agile_api_get "board/#{board.key_value}/sprint", params
          resp['values'].map { |value| build(value) }
        end
      end
    end
  end
end
