require 'tty-table'
require 'pastel'

module Terjira
  module CommonPresenter
    def pastel
      @pastel ||= Pastel.new
    end

    def formatted_date(date_str)
      return nil if date_str.nil? || date_str.empty?
      Time.parse(date_str).strftime("%c")
    end

    def screen_width
      TTY::Screen.width
    end

    def insert_new_line(str, length)
      split_length = (str.length * length / str.display_width).to_i
      str.scan(/.{1,#{split_length}}/).join("\n")
    end
  end
end
