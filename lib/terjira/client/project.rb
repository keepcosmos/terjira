require_relative 'base'

module Terjira
  module Client
    class Project < Base
      class << self
        delegate :all, :find, to: :resource

        def statuses(key)
          response = client.get("/rest/api/latest/project/#{key}/statuses")
          JSON.parse(response.body)
        end
      end
    end
  end
end
