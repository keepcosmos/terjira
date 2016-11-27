require_relative 'base_cli'

module Terjira
  class IssueCLI < BaseCLI
    default_task :show

    desc 'KEY', 'Show detail of the issue'
    def show(key = nil)
      return invoke(:help) unless key
      issue = Client::Issue.find(key)
      render_issue_detail(issue)
    rescue => e
      puts e.message
    end

    desc "ls", "List of isseus"
    option "assignee", aliases: "-a", type: :string, desc: 'Assignee username. no option -> return only your issues, ALL -> issues of all assignees'
    option "status", aliases: '-s', desc: 'Status categories, if no option return all issues without `Done`'
    option "project", type: :string, aliases: '-p', desc: "Project key"
    option "type", type: :string, aliases: '-t', desc: "Issue type"
    option "priority", type: :string, desc: "priority"
    map ls: :list
    def list
      options[:statusCategory] = ["To Do", "In Progress"] unless options[:status]
      options[:assignee] = current_username unless options[:assignee]
      options[:issuetype] = options.delete(:type) if options[:type]

      issues = Client::Issue.all(options)
      render_issues(issues)
    end

    desc 'transition', 'Update status of the issue'
    map t: :transition
    def transition(issue, status = nil)

    end

    desc 'priority', 'Update priority of the issue'
    map p: :priority
    def priority(issue, priority = nil)
    end
  end
end
