module Terjira
  module Client
    class Board < Base
      class << self
        delegate :build, to: :resource
        BASE_PATH = "/rest/agile/1.0/board"

        def all(options = {})
          params = options.slice(:type)
          path = BASE_PATH
          path += "?#{URI.encode_www_form(params)}" if params.present?
          resp = get(path)
          resp["values"].map { |value| build(value) }
        end

        def find(board_id)
          resp = get(BASE_PATH + "/#{board_id}")
          self.build(resp)
        end
      end
    end
  end
end
