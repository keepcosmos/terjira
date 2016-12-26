require 'terjira/utils/file_cache'

module Terjira
  VERSION = '0.2.6'.freeze

  class VersionChecker
    VERSION_CHECK_DURATION = (60 * 60 * 24 * 5).freeze

    class << self
      def check_version
        version_alert_cache.fetch :alert do
          if new_version_exists?
            puts "* New version of terjira was released! Run `gem update terjira` if you want to update"
          end
          'checked!'
        end
      end

      def new_version_exists?
        current = Terjira::VERSION.split(".").map(&:to_i)
        remote = parse_remote_version

        (current[0] < remote[0]) ||
          ((current[0] == remote[0]) && (current[1] < remote[1])) ||
          ((current[0] == remote[0]) && (current[1] == remote[1]) && (current[2] < remote[2]))
      rescue => e
        puts "Can not check new version of terjira, #{e.message}"
        false
      end

      private

      def parse_remote_version
        remote_version = search_remote_version
        (remote_version.scan(/(?<=terjira\s\()\d+\.\d+\.\d+/).first || '0.0.0').split(".").map(&:to_i)
      end

      def search_remote_version
        @remote_version_str ||= `gem search terjira`
      end

      def version_alert_cache
        @version_alert_cache ||= Terjira::FileCache.new("version", VERSION_CHECK_DURATION)
      end
    end

  end
end
