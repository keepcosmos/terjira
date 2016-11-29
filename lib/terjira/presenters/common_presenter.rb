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
  end
end
