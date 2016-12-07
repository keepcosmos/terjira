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
      issuetype: :select_issuetype,
      status: :select_issue_status,
      priority: :select_priority,
      comment: :write_comment,
      summary: :write_summary,
      description: :write_description
    }

    def suggest_options(opts = {})
      origin = options.dup

      origin.reject! { |k, v| v.to_s =~ /^all$/i }

      if opts[:required].is_a? Array
        opts[:required].inject(origin) { |memo, opt| memo[opt] ||= opt.to_s; memo }
      end

      origin.reject { |k, v| k.to_s.downcase == v.to_s.downcase }.each do |k, v|
        resource_store.set(k.to_sym, v)
      end

      (opts[:resources] || {}).each { |k, v| resource_store.set(k.to_sym, v) }

      default_value_options = origin.select { |k, v| k.to_s.downcase == v.to_s.downcase }

      default_value_options.each do |k, _v|
        if selector_method = OPTION_TO_SELECTOR[k.to_sym]
          send(selector_method)
        end
      end

      default_value_options.each do |k, _v|
        default_value_options[k] = resource_store.get(k)
      end

      origin.merge! default_value_options
    end

    def resource_store
      ResourceStore.instance
    end
  end
end
