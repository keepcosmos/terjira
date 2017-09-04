# encoding: utf-8

module Terjira
  class Editor
    def self.editor_text
      editor = ENV['EDITOR']
      if editor.nil? || editor.empty?
        raise 'EDITOR environment variable not found. Please set a default editor.'
      end

      tmp_file = Tempfile.new('content')
      success = system "#{editor} #{tmp_file.path}"
      content = File.read(tmp_file.path) if success

      tmp_file.unlink

      raise 'Editor returned a non-zero exit code. Something must have gone wrong' unless success

      content
    end
  end
end
