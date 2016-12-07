require_relative 'jql_query_builer'
require_relative 'auth_option_builder'

module Terjira
  module Client
    # Abstract class to delegate jira-ruby resource class
    class Base
      extend JQLQueryBuilder
      extend AuthOptionBuilder

      DEFAULT_CACHE_SEC = 60
      DEFAULT_API_PATH = "/rest/api/2/"
      AGILE_API_PATH = "/rest/agile/1.0/"

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

        # define `#api_get(post, put, delete)` and `#agile_api_get(post, put, delete)`
        { DEFAULT_API_PATH => "api_",
          AGILE_API_PATH => "agile_api_"
        }.each do |url_prefix, method_prefix|

          [:get, :delete].each do |http_method|
            method_name = "#{method_prefix}#{http_method}"
            define_method(method_name) do |path, params = {}, headers = {}|
              url = url_prefix + path
              if params.present?
                params.reject! { |k, v| v.blank? }
                url += "?#{URI.encode_www_form(params)}"
              end
              parse_body client.send(http_method, url, headers)
            end
          end

          [:post, :put].each do |http_method|
            method_name = "#{method_prefix}#{http_method}"
            define_method(method_name) do |path, body = '', headers = {}|
              url = url_prefix + path
              parse_body client.send(http_method, url, body, headers)
            end
          end
        end

        def parse_body(response)
          JSON.parse(response.body) if response.body.present?
        end
      end
    end
  end
end
