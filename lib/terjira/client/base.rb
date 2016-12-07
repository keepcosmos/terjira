require_relative 'jql_query_builer'
require_relative 'auth_option_builder'

module Terjira
  module Client
    # Abstract class to delegate jira-ruby resource class
    class Base
      extend JQLQueryBuilder
      extend AuthOptionBuilder

      DEFAULT_CACHE_SEC = 60

      class << self

        delegate :build, to: :resource

        def client
          @@client ||= JIRA::Client.new(build_auth_options)
        end

        def resource
          client.send(class_name) if client.respond_to?(class_name)
        end

        def username
          client.options[:username]
        end

        def class_name
          self.to_s.split("::").last
        end

        def cache(options = {})
          options[:expiry] ||= DEFAULT_CACHE_SEC
          @cache ||= Terjira::FileCache.new(class_name, expiry)
        end

        def get(url)
          JSON.parse client.get(url).body
        end
      end
    end
  end
end
