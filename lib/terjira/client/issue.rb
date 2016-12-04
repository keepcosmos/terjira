require_relative 'base'

module Terjira
  module Client
    class Issue < Base
      class << self
        delegate :build, :find, to: :resource
        ISSUE_JQL_KEYS = [:sprint, :assignee, :reporter, :project, :issuetype, :priority, :status, :statusCategory]

        def all(options = {})
          opts = options.slice(*ISSUE_JQL_KEYS)
          return resource.all if options.blank?
          max_results = options.delete(:max_results) || 500
          resource.jql(build_jql_query(opts), max_results: max_results)
        end

        def current_my_issues
          jql("assignee = #{self.key_value} AND statusCategory != 'Done'")
        end

        def assign(issue, assignee)
          body = { name: assignee.key_value }.to_json
          resp = client.put("/rest/api/2/issue/#{issue.key_value}/assignee", body)
          resp.code.to_i < 300 && resp.code.to_i > 199
        end

        def trans(issue)

        end
      end
    end
  end
end
