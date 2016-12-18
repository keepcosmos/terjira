require_relative 'base'

module Terjira
  module Client
    class Field < Base
      class << self
        def all
          @all_fields ||= file_cache.fetch("all") do
            resource.all
          end
        end

        def find_by_key(key)
          all.find { |field| field.key == key }
        end

        def epic_name
          all.find { |field| field.name == 'Epic Name' }
        end

        def epiclink
          all.find { |field| field.name == 'Epic Link' }
        end

        def file_cache
          Terjira::FileCache.new("resource/fields", 60 * 60 * 24)
        end
      end
    end
  end
end
