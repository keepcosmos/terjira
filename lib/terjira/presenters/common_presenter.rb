require 'tty-table'
require 'pastel'
require 'unicode/display_width/string_ext'

module Terjira
  module CommonPresenter
    extend Forwardable

    def_delegators :pastel, :bold, :dim

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

    def dim_none
      dim('None')
    end

    def formatted_date(date_str, date_format = '%c')
      return nil if date_str.nil? || date_str.empty?
      Time.parse(date_str).strftime(date_format)
    end

    def username(user)
      if user.nil?
        dim_none
      else
        begin
          "#{user.displayName} (#{user.name})"
        rescue NoMethodError
          user.displayName.to_s
        end
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
