require_relative 'base'

module Terjira
  module Client
    class Issue < Base
      class << self
        delegate :build, :find, to: :resource
        ISSUE_JQL_KEYS = [:sprint, :assignee, :reporter, :project, :issuetype, :priority, :status, :statusCategory]

        def all(options = {})
          opts = options.slice(*ISSUE_JQL_KEYS)
          return resource.all if options.blank?
          max_results = options.delete(:max_results) || 500
          resource.jql(build_jql_query(opts), max_results: max_results)
        end

        def find(issue, options = {})
          resp = api_get("issue/#{issue.key_value}", options)
          build(resp)
        end

        def current_my_issues
          jql("assignee = #{self.key_value} AND statusCategory != 'Done'")
        end

        def assign(issue, assignee)
          body = { name: assignee.key_value }.to_json
          api_put("issue/#{issue.key_value}/assignee", body)
        end

        def write_comment(issue, message)
          resp = api_post("issue/#{issue.key_value}/comment", { body: message }.to_json)
          find(issue)
        end

        def create(options = {})
          params = extract_to_fields_params(options)
          if transition_param = extract_to_transition_param(options)
            params.merge!(transition_param)
          end

          resp = api_post "issue", params.to_json
          result_id = resp["id"]
          find(result_id)
        end

        def update(issue, options = {})
          params = extract_to_fields_params(options)
          api_put "issue/#{issue.key_value}", params.to_json
          find(issue)
        end

        def trans(issue, options = {})
          params = extract_to_transition_param(options)
          params.merge!(extract_to_update_params(options))
          params.merge!(extract_to_fields_params(options))
          api_post "issue/#{issue.key_value}/transitions", params.to_json
          find(issue)
        end

        private

        def extract_to_update_params(options = {})
          params = {}
          if comment = options.delete(:comment)
            params[:comment] = [{ add: { body: comment } }]
          end
          { update: params }
        end

        def extract_to_transition_param(options = {})
          transition = options.delete(:status)
          transition ||= options.delete(:transition)
          return unless transition
          { transition: convert_param_key_value_hash(transition) }
        end

        def extract_to_fields_params(options = {})
          opts = options.dup
          params = {}

          custom_fields = options.keys.select { |k| k.to_s =~ /^customfield/ }
          (custom_fields + [:summary, :description]).each do |k, v|
            params[k] = opts.delete(k) if opts.key?(k)
          end

          if opts.key?(:project)
            params[:project] = { key: opts.delete(:project).key_value }
          end

          opts.each do |k, v|
            params[k] = convert_param_key_value_hash(v)
          end
          { fields: params }
        end

        def convert_param_key_value_hash(resource)
          if resource.respond_to? :key_with_key_value
            okey, ovalue = resource.key_with_key_value
            { okey => ovalue }
          elsif resource =~ /^\d+$/
            { id: resource.key_value }
          else
            { name: resource.key_value }
          end
        end
      end
    end
  end
end
