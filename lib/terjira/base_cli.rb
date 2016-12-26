require 'thor'

require_relative 'option_supportable'
Dir[File.dirname(__FILE__) + '/presenters/*.rb'].each { |f| require f }
Dir[File.dirname(__FILE__) + '/client/*.rb'].each { |f| require f }

module Terjira
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

      def open_url(url)
        ostype = `echo $OSTYPE`
        open_cmd = case ostype
                   when /darwin/ then 'open'
                   when  /cygwin/ then 'cygstart'
                   when /linux/ then 'xdg-open'
                   when /msys/ then 'start ""'
                   else puts "Platform $OSTYPE not supported"
                   end
        `#{open_cmd} #{url}`
      end
    end
  end
end
