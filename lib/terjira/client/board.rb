module Terjira
  module Client
    class Board < Base
      class << self
        delegate :build, to: :resource

        def all(options = {})
          params = options.slice(:type)
          path = "/rest/agile/latest/board"
          path += "?#{URI.encode_www_form(params)}" if params.present?
          resp = JSON.parse client.get(path).body
          resp["values"].map { |value| build(value) }
        end
      end
    end
  end
end
