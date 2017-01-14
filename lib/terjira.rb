require_relative 'terjira/ext/jira_ruby'
require 'terjira/version'
require 'thor'

Dir[File.dirname(__FILE__) + '/terjira/*_cli.rb'].each { |f| require f }

ENV['PAGER'] ||= 'less'

# http://willschenk.com/making-a-command-line-utility-with-gems-and-thor/
module Terjira
  # Main CLI
  class CLI < Thor
    desc 'login', 'login your Jira'
    option "ssl-config", type: :boolean
    option "proxy-config", type: :boolean
    def login
      pastel = Pastel.new
      Client::Base.expire_auth_options
      Client::Base.build_auth_options(options)

      # for touch base resource
      Client::Field.all
      puts pastel.blue("Login successful")
    rescue JIRA::HTTPError => e
      puts pastel.red(e.message)
      Client::Base.expire_auth_options
    rescue => e
      Client::Base.expire_auth_options
      raise e
    end

    desc 'logout', 'logout your Jira'
    def logout
      Client::Base.expire_auth_options
    end

    desc 'project SUBCOMMAND ...ARGS', 'Manage projects'
    subcommand 'project', ProjectCLI

    desc 'board SUBCOMMAND ...ARGS', 'Manage boards'
    subcommand 'board', BoardCLI

    desc 'sprint SUBCOMMAND ...ARGS', 'Manage sprints'
    subcommand 'sprint', SprintCLI

    desc 'issue SUBCOMMAND ...ARGS', 'Manage issues'
    subcommand 'issue', IssueCLI
  end
end
