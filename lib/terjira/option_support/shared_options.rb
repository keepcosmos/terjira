module Terjira
  module SharedOptions
    OPTIONS = {
      "project" => {
        type: :string,
        aliases: '-p',
        desc: 'project key'
      },
      "board" => {
        type: :numeric,
        aliases: '-b',
        banner: 'BOARD_ID',
        lazy_default: 'board',
      },
      "sprint" => {
        type: :numeric,
        banner: 'SPRINT_ID',
        lazy_default: 'sprint'
      },
      "assignee" => {
        type: :string,
        aliases: "-a"
      },
      "state" => {
        type: :array,
        aliases: '-s',
        default: ['Active', 'Future'],
        lazy_default: ['Active', 'Future'],
        enum: ['Active', 'Future', 'Closed', 'ALL']
      },
      "status" => {
        type: :string,
        aliases: '-s',
        desc: 'status'
      },
      "resolution" => {
        type: :string,
        aliases: '-r'
      },
      "issuetype" => {
        type: :string,
        aliases: '-t'
      },
      "priority" => {
        type: :string,
        aliases: '-P'
      },
      "summary" => {
        type: :string,
        aliases: '-S'
      },
      "description" => {
        type: :string,
        aliases: '-d'
      },
      "comment" => {
        type: :string,
        aliases: '-m'
      }
    }

    def jira_options(*keys)
      keys.each { |key| jira_option(key) }
    end

    def jira_option(key, opts = {})
      method_option(key, (OPTIONS[key.to_s] || {}).merge(opts))
    end
  end
end
