require_relative 'base'

module Terjira
  module Client
    class Status < Base
      class << self
        def all(project)
          resp = get("/rest/api/2/project/#{project.key_value}/statuses")
          statuses_json = resp.map { |issuetype| issuetype["statuses"] }.flatten.uniq
          statuses_json.map { |status| build(status) }
        end
      end
    end
  end
end
