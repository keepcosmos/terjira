class MockResource
  class << self
    def projects
      load_response("projects").map do |project|
        Terjira::Client::Project.build(project)
      end
    end

    def boards
      load_response("boards")["values"].map do |board|
        Terjira::Client::Board.build(board)
      end
    end

    def sprints
      load_response("sprints")["values"].map do |sprint|
        Terjira::Client::Sprint.build(sprint)
      end
    end

    def issues
      load_response("issues")["issues"].map do |issue|
        Terjira::Client::Issue.build(issue)
      end
    end

    def statuses
      itypes = load_response("statuses")
      json = itypes.map { |issuetype| issuetype["statuses"] }.flatten.uniq
      json.map do |status|
        Terjira::Client::Status.build(status)
      end
    end

    def load_response(path)
      path += ".json" unless path =~ /\.json/
      json_path = File.join(File.dirname(__FILE__), "mock_responses/" + path)
      JSON.parse(File.read(json_path))
    end
  end
end
