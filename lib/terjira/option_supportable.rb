require_relative 'option_support/option_selector'
require_relative 'option_support/resource_store'
require_relative 'option_support/shared_options'

module Terjira
  # For support CLI options.
  module OptionSupportable
    def self.included(klass)
      klass.class_eval do
        extend SharedOptions
        include OptionSelector
      end
    end

    OPTION_TO_SELECTOR = {
      project: :select_project,
      board: :select_board,
      sprint: :select_sprint,
      assignee: :select_assignee,
      issuetype: :select_issuetype
    }

    def suggest_options(opts = {})
      result = options.dup

      if opts[:required].is_a? Array
        opts[:required].each do |opt|
          result[opt] ||= opt.to_s
        end
      end

      if opts[:resouces].is_a? Hash
        opts[:resouces].each { |k, v| resource_store.set(k.to_sym, v) }
      end

      default_value_options = result.select { |k, v| k.to_s.downcase == v.to_s.downcase }

      default_value_options.each do |k, v|
        if selector_method = OPTION_TO_SELECTOR[k.to_sym]
          send(selector_method)
        end
      end

      default_value_options.each do |k, v|
        default_value_options[k] = resource_store.get(v)
      end

      result.merge! default_value_options
    end
  end
end
