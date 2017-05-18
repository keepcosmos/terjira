require 'tty-prompt'
require 'terjira/utils/file_cache'

module Terjira
  module Client
    module AuthOptionBuilder
      AUTH_CACHE_KEY = 'auth'.freeze

      def build_auth_options(options = {})
        cache_key = options[:cache_key] || AUTH_CACHE_KEY
        auth_file_cache.fetch cache_key do
          build_auth_options_by_tty(options)
        end
      end

      def build_auth_options_by_cached(options = {})
        cache_key = options[:cache_key] || AUTH_CACHE_KEY
        auth_file_cache.get(cache_key)
      end

      def expire_auth_options
        Terjira::FileCache.clear_all
      end

      def build_auth_options_by_tty(options = {})
        puts 'Login will be required...'
        prompt = TTY::Prompt.new

        result = prompt.collect do
          key(:site).ask('Site:', required: true)
          key(:context_path).ask('Context path:', default: '')
          key(:username).ask('Username:', required: true)
          key(:password).mask('Password:', required: true)

          if options['ssl-config']
            key(:use_ssl).yes?('Use SSL?')
            key(:ssl_verify_mode).select('Verify mode:') do |menu|
              menu.choice 'Verify peer', OpenSSL::SSL::VERIFY_PEER
              menu.choice 'Verify client once', OpenSSL::SSL::VERIFY_CLIENT_ONCE
              menu.choice 'Verify fail if no peer cert', OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
              menu.choice 'Verify none', OpenSSL::SSL::VERIFY_NONE
            end
          end

          if options['proxy-config']
            key(:proxy_address).ask("Proxy address: ", default: nil)
            key(:proxy_port).ask("Proxy port: ", default: nil)
          end
        end

        result[:auth_type] = :basic
        result[:use_ssl] ||= false if result[:site] =~ /http\:\/\//

        result
      end

      def auth_file_cache
        @auth_file_cache ||= Terjira::FileCache.new('profile')
      end
    end
  end
end
