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
        desc: 'board_id'
      },
      "sprint" => {
        type: :numeric,
        desc: 'sprint id'
      },
      "assignee" => {
        type: :string,
        aliases: "-a",
        desc: 'Assignee username. no option -> return only your issues, ALL -> issues of all assignees'
      },
      "state" => {
        type: :array,
        aliases: '-s',
        default: ['active', 'future'],
        enum: ['active', 'future', 'closed'],
        desc: 'states of sprint'
      },
      "status" => {
        type: :string,
        aliases: '-s',
        desc: 'status'
      },
      "issuetype" => {
        type: :string,
        aliases: '-t',
        desc: 'Issue type'
      },
      "priority" => {
        type: :string,
        aliases: '-P',
        desc: 'priority'
      },
      "summary" => {
        type: :string,
        aliases: '-S',
        desc: "Issue summary"
      },
      "comment" => {
        type: :string,
        aliases: '-m',
        desc: 'comment'
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
