require 'pry'
require_relative 'terjira/ext/jira_ruby'
require_relative 'terjira/ext/tty_prompt'
require 'terjira/version'
require 'thor'

Dir[File.dirname(__FILE__) + "/terjira/*_cli.rb"].each { |f| require f }

ENV['PAGER'] ||= 'less'

# http://willschenk.com/making-a-command-line-utility-with-gems-and-thor/
module Terjira
  class CLI < Thor
    desc "login", "login your Jira"
    def login
      Client::Base.expire_auth_options
      Client::Base.build_auth_options
    end

    desc "logout", "logout your Jira"
    def logout
      Client::Base.expire_auth_options
    end

    desc "project SUBCOMMAND ...ARGS", "manage proejcts"
    subcommand "project", ProjectCLI

    desc "board SUBCOMMAND ...ARGS", "manage boards"
    subcommand "board", BoardCLI

    desc "sprint SUBCOMMAND ...ARGS", "manage sprints"
    subcommand "sprint", SprintCLI

    desc "issue SUBCOMMAND ...ARGS", "manage issues"
    subcommand "issue", IssueCLI
  end
end
