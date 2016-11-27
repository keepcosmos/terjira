require 'tty-table'
require 'pastel'

module Terjira
  module CommonPresenter
    def pastel
      @pastel ||= Pastel.new
    end

    def formatted_date(date_str)
      Time.parse(date_str).strftime("%c")
    end
  end
end
