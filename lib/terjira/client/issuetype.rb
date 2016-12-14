require_relative 'base'

module Terjira
  module Client
    class Issuetype < Base
      class << self
        def all
          resp = api_get("issuetype")
          resp.map { |issuetype| build(issuetype) }
        end

        def subtask_issuetypes
          all.select(&:subtask)
        end
      end
    end
  end
end
