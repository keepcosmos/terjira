require_relative 'base'

module Terjira::Client
  class Project < Base
    class << self
      delegate :all, :find, :fetch, to: :resource

      def all
        expand = %w[description lead issueTypes url projectKeys]
        resp = get("/rest/api/2/project?expand=#{expand.join(",")}")
        resp.map { |project| build(project) }
      end

      def all_by_board(board)
        resp = get("/rest/agile/1.0/board/#{board.key_value}/project")
        resp["values"].map do |project|
          build(project)
        end
      end

      def users(key)
        result = build("key" => key).users
        result.reject { |u| u.name =~ /^addon/ }
      end
    end
  end
end
