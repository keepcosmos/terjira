require_relative 'base'

module Terjira
  module Client
    class Project < Base
      class << self
        delegate :build, :all, :find, to: :resource

        def statuses(key)
          response = client.get("/rest/api/latest/project/#{key}/statuses")
          JSON.parse(response.body)
        end

        def users(key)
          result = build("key" => key).users
          result.reject { |u| u.name =~ /^addon/ }
        end
      end
    end
  end
end
