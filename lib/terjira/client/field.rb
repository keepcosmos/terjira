require_relative 'base'

module Terjira
  module Client
    class Field < Base
      CACHE_PATH = "resource/fields".freeze

      class << self
        def all
          @all_fields ||= file_cache.fetch("all") do
            resource.all
          end
        end

        def find_by_key(key)
          all.find { |field| field.key == key }
        end

        def find_by_name(name)
          all.find { |field| field.name == name }
        end

        def epic_name
          find_by_name('Epic Name')
        end

        def epic_link
          find_by_name('Epic Link')
        end

        def story_points
          find_by_name('Story Points')
        end

        def file_cache
          Terjira::FileCache.new(CACHE_PATH, 60 * 60 * 24)
        end
      end
    end
  end
end
