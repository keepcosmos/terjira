require_relative '../ext/jira_ruby'
require_relative 'jql_query_builer'
require_relative 'auth_option_builder'

module Terjira
  module Client
    # Abstract class to delegate jira-ruby resource class
    class Base
      extend JQLQueryBuilder
      extend AuthOptionBuilder

      class << self
        def client
          JIRA::Client.new(build_auth_options)
        end

        def resource
          client_name = self.to_s.split("::").last
          client.send(client_name) if client.respond_to?(client_name)
        end

        def username
          client.options[:username]
        end

        # delegate to jira client
        def method_missing(method_name, *arguments, &block)
          if(resource.respond_to?(method_name))
            resource.send(method_name, *arguments, &block)
          else
            super(method_name, *arguments, &block)
          end
        end
      end
    end
  end
end
