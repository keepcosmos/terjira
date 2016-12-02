require 'jira-ruby'
require 'tty-spinner'
require 'pastel'

# Extend jira-ruby for command line interface.
module JIRA
  class HttpClient
    alias_method  :origin_make_request, :make_request

    def make_request(http_method, path, body='', headers={})
      title = http_method.to_s.upcase + " " + URI.decode(path)
      title = Pastel.new.dim(title)
      spinner = TTY::Spinner.new ":spinner #{title}", format: :dots, clear: true

      spinner.start
      result = origin_make_request(http_method, path, body, headers)
      spinner.stop
      result
    end
  end

  # Board model is not defined in jira-ruby gem
  module Resource
    class BoardFactory < JIRA::BaseFactory # :nodoc:
    end

    class Board < JIRA::Base
      def self.key_attribute; :id; end
    end

    class User
      def self.key_attribute; :key; end
    end

    class Issuetype
      def self.key_attribute; :id; end
    end
  end

  class Client
    def Board # :nodoc:
      JIRA::Resource::BoardFactory.new(self)
    end
  end
end


class String
  alias_method :key_value, :to_s
end

class Integer
  def key_value; self.to_s; end
end
