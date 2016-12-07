require_relative 'base'

module Terjira
  module Client
    class Priority < Base
      class << self
        def all
          resp = api_get "priority"
          resp.map { |priority| build(priority) }
        end
      end
    end
  end
end
