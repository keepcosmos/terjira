require_relative 'base'

module Terjira
  module Client
    class Resolution < Base
      class << self
        def all
          resp = api_get("resolution")
          resp.map { |resolution| build(resolution) }
        end
      end
    end
  end
end
