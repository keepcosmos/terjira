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
      summary: :write_summary,
      description: :write_description,
      sprint: :select_sprint,
      issuetype: :select_issuetype,
      assignee: :select_assignee,
      status: :select_issue_status,
      priority: :select_priority,
      resolution: :select_resolution,
      epiclink: :write_epiclink_key,
      comment: :write_comment
    }.freeze

    # Transforming and clening options
    # and suggest list of option values
    def suggest_options(opts = {})
      origin = options.dup

      if opts[:required].is_a? Array
        opts[:required].inject(origin) do |memo, opt|
          memo[opt] ||= opt.to_s
          memo
        end
      end

      # Store assigned options
      origin.reject { |k, v| k.to_s.casecmp(v.to_s).zero? }.each do |k, v|
        resource_store.set(k.to_sym, v)
      end

      # Store given options from arguments
      (opts[:resources] || {}).each do |k, v|
        resource_store.set(k.to_sym, v)
      end

      # Select options that are not assigned value from user
      default_value_options = origin.select do |k, v|
        k.to_s.casecmp(v.to_s).zero?
      end

      # Sort order for suggest option values
      default_value_options = default_value_options.sort do |hash|
        OPTION_TO_SELECTOR.keys.index(hash[0].to_sym) || 999
      end
      default_value_options = Hash[default_value_options]

      # Suggest option values and save to resource store
      default_value_options.each do |k, _v|
        selector_method = OPTION_TO_SELECTOR[k.to_sym]
        send(selector_method) if selector_method
      end

      # Fetch selected values from resource store
      default_value_options.each do |k, _v|
        default_value_options[k] = resource_store.get(k)
      end

      origin.merge! default_value_options
    end

    def suggest_related_value_options(opts = {})
      if opts[:issuetype]
        if opts[:issuetype].key_value.casecmp('epic').zero?
          # Suggest epic name
          epic_name_field = Client::Field.epic_name
          opts[epic_name_field.key] ||= write_epic_name
        else
          subtask_issuetypes = Client::Issuetype.subtask_issuetypes.map(&:name)
          if subtask_issuetypes.include? opts[:issuetype].key_value
            # Suggest parent issue
            opts[:parent] ||= write_parent_issue_key
          end
        end
      end

      if opts[:epiclink]
        epiclink_field = Client::Field.epic_link
        opts[epiclink_field.key] ||= opts.delete(:epiclink)
      end

      opts
    end

    def resource_store
      ResourceStore.instance
    end
  end
end
