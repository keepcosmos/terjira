# encoding: utf-8

module Terjira
  class Editor
    def self.editor_text
      tmp_file = Tempfile.new('content')
      success = system "$EDITOR #{tmp_file.path}"
      content = File.read(tmp_file.path) if success

      tmp_file.unlink
      content
    end
  end
end
