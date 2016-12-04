require_relative 'base'

module Terjira::Client
  class Priority < Base
    class << self
      def all
        resp = get("/rest/api/2/priority")
        resp.map { |priority| build(priority) }
      end
    end
  end
end
