# encoding: utf-8

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

    def username_with_email(user)
      if user.nil?
        "None"
      else
        "#{user.name}, #{user.displayName} <#{user.emailAddress}>"
      end
    end

    def screen_width
      TTY::Screen.width
    end

    def insert_new_line(str, length)
      str.split("\n").map do |line|
        if line.display_width < 1
          line
        else
          display_length = pastel.strip(line).display_width
          split_length = (line.length * length / display_length).to_i
          line.scan(/.{1,#{split_length}}/).join("\n")
        end
      end.join("\n")
    end
  end
end
