require_relative 'base'

module Terjira
  module Client
    class Issue < Base
      class << self
        delegate :build, :find, to: :resource

        def all(options = {})
          return resource.all if options.blank?
          max_results = options.delete(:max_results) || 500
          resource.jql(build_query(options), max_results: max_results)
        end

        def current_my_issues
          jql("assignee = #{self.username} AND statusCategory != 'Done'")
        end

        private

        def priority_query(priority)
          priority.blank? ? nil : "priority = #{priority}"
        end

        def issuetype_query(issuetype)
          issuetype.blank? ? nil : "issuetype = #{issuetype}"
        end

        def project_query(project)
          project.blank? ? nil : "project = #{project}"
        end

        def status_category_query(status)
          if status.blank?
            "statusCategory != 'Done'"
          elsif status.downcase != "all"
            "statusCategory = #{status}"
          end
        end

        def assignee_query(assignee)
          if assignee.blank?
            "assignee = currentuser()"
          elsif assignee.downcase != "all"
            "assignee = #{assignee}"
          end
        end
      end
    end
  end
end
