module Terjira::Client
  class User < Base
    class << self
      def assignables_by_project(project)
        fetch_assignables("/rest/api/2/user/assignable/search?project=#{project.key_value}")
      end

      def assignables_by_issue(issue)
        fetch_assignables("/rest/api/2/user/assignable/search?issueKey=#{issue.key_value}")
      end

      def all

      end

      private

      def fetch_assignables(url)
        resp = get(url)
        resp.map { |user| build(user) }.
          reject { |user| user.key_value =~ /^addon/ }
      end
    end
  end
end
