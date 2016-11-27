require_relative '../ext/jira_ruby'
require_relative 'jql_query_builer'

module Terjira
  module Client
    # Abstract class to delegate jira-ruby resource class
    class Base
      extend JQLQueryBuilder

      class << self
        def client
          JIRA::Client.build
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
