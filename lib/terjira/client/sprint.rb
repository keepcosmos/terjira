require_relative 'base'

module Terjira
  module Client
    class Sprint < Base
      class << self
        delegate :build, to: :resource

        def all(board, options = {})
          url = "/rest/agile/1.0/board/#{board.key_value}/sprint"
          params = options.slice(:state, :maxResults)
          url += "?#{URI.encode_www_form(params)}" if params.present?
          resp = client.get(url).body
          result = JSON.parse(resp)
          result["values"].map { |value| build(value) }
        end

        def find(sprint)
          resp = client.get("/rest/agile/1.0/sprint/#{sprint.key_value}").body
          build JSON.parse(resp)
        end

        def find_active(board)
          resp = client.get("/rest/agile/1.0/board/#{board.key_value}/sprint?state=active").body
          result = JSON.parse(resp)
          result["values"].map { |value| build(value) }.first
        end
      end
    end
  end
end
