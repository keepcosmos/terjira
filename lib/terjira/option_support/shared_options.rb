module Terjira
  module SharedOptions
    OPTIONS = {
      'assignee' => {
        type: :string,
        aliases: '-a'
      },
      'board' => {
        type: :numeric,
        aliases: '-b',
        banner: 'BOARD_ID',
        lazy_default: 'board'
      },
      'description' => {
        type: :string,
        aliases: '-d'
      },
      'epiclink' => {
        type: :string,
        aliases: '-e'
      },
      'editor' => {
        type: :boolean,
        aliases: '-E'
      },
      'comment' => {
        type: :string,
        aliases: '-m'
      },
      'project' => {
        type: :string,
        aliases: '-p'
      },
      'priority' => {
        type: :string,
        aliases: '-P'
      },
      'resolution' => {
        type: :string,
        aliases: '-r'
      },
      'state' => {
        type: :array,
        aliases: '-s',
        default: %w[Active Future],
        lazy_default: %w[Active Future],
        enum: %w[Active Future Closed]
      },
      'status' => {
        type: :string,
        aliases: '-s',
      },
      'summary' => {
        type: :string,
        aliases: '-S'
      },
      'issuetype' => {
        type: :string,
        aliases: '-t'
      },
      'sprint' => {
        type: :numeric,
        banner: 'SPRINT_ID',
        lazy_default: 'sprint'
      }
    }.freeze

    def jira_options(*keys)
      keys.each { |key| jira_option(key) }
    end

    def jira_option(key, opts = {})
      method_option(key, (OPTIONS[key.to_s] || {}).merge(opts))
    end
  end
end
