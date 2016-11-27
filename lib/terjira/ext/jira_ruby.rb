require 'jira-ruby'
require 'tty-spinner'
require 'pastel'

# Extend jira-ruby for command line interface.
module JIRA
  class Client
    class << self
      def build
        @@login_options = {
        }
        JIRA::Client.new(@@login_options)
      end

      private

      def build_by_profile
      end

      def build_by_tty
      end

      def save_profile
      end
    end
  end

  class HttpClient
    alias_method  :origin_make_request, :make_request

    def make_request(http_method, path, body='', headers={})
      title = http_method.to_s.upcase + " " + URI.decode(path)
      title = Pastel.new.dim(title)
      spinner = TTY::Spinner.new ":spinner #{title}", format: :dots

      spinner.start
      result = origin_make_request(http_method, path, body, headers)
      spinner.stop
      result
    end
  end
end
