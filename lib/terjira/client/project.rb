require_relative 'base'

module Terjira
  module Client
    # Project Client Baseed on jira-ruby gem
    class Project < Base
      class << self
        delegate :all, :find, :fetch, to: :resource

        def all
          expand = %w(description lead issueTypes url projectKeys)
          resp = api_get 'project', expand: expand.join(',')
          resp.map { |project| build(project) }
        end

        def all_by_board(board)
          resp = agile_api_get "board/#{board.key_value}/project"
          resp['values'].map do |project|
            build(project)
          end
        end
      end
    end
  end
end
