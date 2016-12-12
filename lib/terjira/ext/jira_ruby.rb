require 'jira-ruby'
require 'tty-screen'
require 'tty-spinner'
require 'pastel'

module JIRA
  # Extend jira-ruby for command line interface.
  class HttpClient
    alias origin_make_request make_request

    def make_request(http_method, path, body = '', headers = {})
      title = http_method.to_s.upcase
      title = Pastel.new.dim(title)
      spinner = TTY::Spinner.new ":spinner #{title}", format: :dots, clear: true
      result = nil

      spinner.run do
        result = origin_make_request(http_method, path, body, headers)
      end

      result
    end
  end

  # Board model is not defined in jira-ruby gem
  class Base
    def key_with_key_value
      [self.class.key_attribute, key_value]
    end
  end

  module Resource
    class BoardFactory < JIRA::BaseFactory # :nodoc:
    end

    class Board < JIRA::Base
      def self.key_attribute; :id; end
    end

    class User
      def self.key_attribute; :name; end
    end

    class Issue
      def self.key_attribute; :key; end
    end

    class Issuetype
      def self.key_attribute; :name; end
    end

    class Resolution
      def self.key_attribute; :name; end
    end
  end

  class Client
    def Board # :nodoc:
      JIRA::Resource::BoardFactory.new(self)
    end
  end
end

class String
  def key_value; self.strip; end
end

class Integer
  def key_value; self.to_s; end
end
