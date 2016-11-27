require 'tty-prompt'
require 'terjira/utils/file_cache'

module Terjira::Client
  module AuthOptionBuilder
    AUTH_CACHE_KEY = "auth".freeze

    def build_auth_options(cache_key = AUTH_CACHE_KEY)
      auth_file_cache.get_or_set cache_key do
        build_auth_options_by_tty
      end
    end

    def build_auth_options_by_cached(cache_key = AUTH_CACHE_KEY)
      auth_file_cache.get(cache_key)
    end

    def expire_auth_options(cache_key = AUTH_CACHE_KEY)
      auth_file_cache.delete(cache_key)
    end

    def build_auth_options_by_tty
      puts "Login will be required..."
      prompt = TTY::Prompt.new

      result = prompt.collect do
        key(:site).ask("Site:", required: true)
        key(:context_path).ask("Context path:", default: '')
        key(:username).ask("Username:", required: true)
        key(:password).mask("Password:", required: true)
      end
      result[:auth_type] = :basic
      result
    end

    def auth_file_cache
      @auth_file_cache ||= Terjira::FileCache.new('profile')
    end
  end
end
