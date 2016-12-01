require_relative 'base'

module Terjira::Client
  class Project < Base
    class << self
      delegate :all, :find, to: :resource

      def statuses(key)
        get("/rest/api/s/project/#{key}/statuses")
      end

      def users(key)
        result = build("key" => key).users
        result.reject { |u| u.name =~ /^addon/ }
      end
    end
  end
end
