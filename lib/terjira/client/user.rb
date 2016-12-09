require_relative 'base'

module Terjira
  module Client
    class User < Base
      class << self
        def assignables_by_project(project)
          if project.is_a? Array
            keys = project.map(&:key_value).join(",")
            fetch_assignables "user/assignable/multiProjectSearch", {projectKeys: keys }
          else
            fetch_assignables "user/assignable/search", { project: project.key_value }
          end
        end

        def assignables_by_board(board)
          projects = Client::Project.all_by_board(board)
          assignables_by_project(projects)
        end

        def assignables_by_sprint(sprint)
          board_id = if sprint.respond_to? :originBoardId
                       sprint.originBoardId
                     else
                       Client::Sprint.find(sprint).originBoardId
                     end
          assignables_by_board(board_id)
        end

        def assignables_by_issue(issue)
          fetch_assignables "user/assignable/search", {issueKey: issue.key_value }
        end

        private

        def fetch_assignables(path, params)
          resp = api_get(path, params)
          resp.map { |user| build(user) }.
            reject { |user| user.key_value =~ /^addon/ }
        end
      end
    end
  end
end
