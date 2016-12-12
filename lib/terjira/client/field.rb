require_relative 'base'

module Terjira
  module Client
    class Field < Base
      class << self
        def all
          @all_fields ||= resource.all
        end

        def epic_name
          all.find { |field| field.name == 'Epic Name' }
        end
      end
    end
  end
end
