require 'thor'

require_relative 'option_supportable'
Dir[File.dirname(__FILE__) + '/presenters/*.rb'].each { |f| require f }

module Terjira
  # Jira client based on jira-ruby gem
  module Client
    %w(Base Field Issuetype Project Board Sprint Issue User
       Status Resolution Priority RapidView Agile).each do |klass|
      autoload klass, "terjira/client/#{klass.gsub(/(.)([A-Z](?=[a-z]))/,'\1_\2').downcase}"
    end
  end

  class BaseCLI < Thor
    include OptionSupportable

    include CommonPresenter
    include IssuePresenter
    include ProjectPresenter
    include BoardPresenter
    include SprintPresenter

    def self.banner(command, _namespace = nil, _subcommand = false)
      "#{basename} #{subcommand_prefix} #{command.usage}"
    end

    def self.subcommand_prefix
      self.name.gsub(%r{.*::}, '').gsub("CLI", '').gsub(%r{^[A-Z]}) { |match| match[0].downcase }.gsub(%r{[A-Z]}) { |match| "-#{match[0].downcase}" }
    end

    no_commands do
      def current_username
        @current_username ||= Client::Base.username
      end
    end
  end
end
