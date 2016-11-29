module Terjira
  module OptionHelper
    SHARED_OPTIONS = {
      assignee: {
        type: :string,
        aliases: "-a",
        desc: 'Assignee username. no option -> return only your issues, ALL -> issues of all assignees'
      },
      "include-closed": {
        type: :boolean,
        desc: 'Default: false, Including closed',
        default: true
      },
      "status-category": {
        type: :string,
        aliases: '-s',
        desc: 'Status categories, if no option return all issues without `Done`'
      },
      state: {
        type: :array
      },
      status: {
        type: :string,
        aliases: '-S',
        desc: 'status'
      },
      project: {
        type: :string,
        aliases: '-p',
        desc: 'project key'
      },
      type: {
        type: :string,
        aliases: '-t',
        desc: 'Issue type'
      },
      priority: {
        type: :string,
        desc: 'priority'
      },
      comment: {
        type: :string,
        aliases: '-m',
        desc: 'comment'
      },
      board: {
        type: :integer,
        desc: 'board id'
      },
      sprint: {
        type: :integer,
        desc: 'sprint id'
      }
    }

    def jira_options(*keys)
      keys.each { |key| jira_option(key) }
    end

    def jira_option(key, options = {})
      method_option(key, (SHARED_OPTIONS[key.to_sym] || {}).merge(options))
    end
  end
end
