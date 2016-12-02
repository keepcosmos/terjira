require_relative 'base'

module Terjira
  module Client
    class Issue < Base
      class << self
        delegate :build, :find, to: :resource

        def all(options = {})
          return resource.all if options.blank?
          max_results = options.delete(:max_results) || 500
          resource.jql(build_jql_query(options), max_results: max_results)
        end

        def current_my_issues
          jql("assignee = #{self.key_value} AND statusCategory != 'Done'")
        end
      end
    end
  end
end
