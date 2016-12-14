# encoding: utf-8

require 'tty-table'
require 'pastel'

module Terjira
  module CommonPresenter
    def render(text)
      if text.is_a? Array
        puts text.join("\n")
      else
        puts text
      end
    end

    def pastel
      @pastel ||= Pastel.new
    end

    def bold(text)
      pastel.bold(text)
    end

    def formatted_date(date_str, date_format = '%c')
      return nil if date_str.nil? || date_str.empty?
      Time.parse(date_str).strftime(date_format)
    end

    def username_with_email(user)
      if user.nil?
        'None'
      else
        title = "#{user.name}, #{user.displayName}"
        title += " <#{user.emailAddress}>" if user.respond_to?(:emailAddress)
        title
      end
    end

    def screen_width
      TTY::Screen.width
    end

    # Insert new line(`\n`)
    # when string display length is longger than length argument
    def insert_new_line(str, length)
      str.split(/\r\n|\n/).map do |line|
        line.strip!
        if line.display_width < 1
          line
        else
          display_length = pastel.strip(line).display_width
          split_length = (line.length * length / display_length).to_i
          line.scan(/.{1,#{split_length}}/).join("\n") rescue line
        end
      end.join("\n")
    end
  end
end
