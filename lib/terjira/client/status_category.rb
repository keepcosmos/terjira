require_relative 'base'

module Terjira
  module Client
    class StatusCategory < Base
      class << self
        def all
          @all_statuscategory ||= file_cache.fetch("all") do
            resp = api_get "statuscategory"
            resp.map { |category| build(category) }
          end
        end

        def file_cache
          Terjira::FileCache.new("resource/statuscategory", 60 * 60 * 48)
        end
      end
    end
  end
end
