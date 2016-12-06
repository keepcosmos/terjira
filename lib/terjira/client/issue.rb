require_relative 'base'

module Terjira::Client
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

      def current_my_issues
        jql("assignee = #{self.key_value} AND statusCategory != 'Done'")
      end

      def assign(issue, assignee)
        body = { name: assignee.key_value }.to_json
        resp = client.put("/rest/api/2/issue/#{issue.key_value}/assignee", body)
        resp.code.to_i < 300 && resp.code.to_i > 199
      end

      def write_comment(issue, message)
        resp = client.post("/rest/api/2/issue/#{issue.key_value}/comment", {body: message}.to_json)
        if resp.code.to_i < 300
          JSON.parse(resp.body)["id"]
        else
          false
        end
      end

      def create(options = {})
        params = { fields: convert_options_to_params(options) }
        if transition_param = convert_transition_param(options)
          params[:transition] = transition_param
        end
        resp = client.post("/rest/api/2/issue", params.to_json)
        result_id = JSON.parse(resp.body)["id"]
        find(result_id)
      end

      def trans(issue)
      end

      private

      def convert_options_to_params(options = {})
        opts = options.dup
        opts.delete(:status)
        params = {}

        [:summary, :description].each do |k, v|
          params[k] = opts.delete(k) if opts.key?(k)
        end

        params[:project] = { key: opts.delete(:project).key_value }

        opts.each do |k, v|
          params[k] = convert_param_key_value_hash(v)
        end
        params
      end

      def convert_transition_param(options = {})
        transition = options[:status] ? options[:status] : options[:transition]
        return unless transition
        convert_param_key_value_hash(transition)
      end

      def convert_param_key_value_hash(resource, options = {})
        default_string_key = options[:string_key] || :name

        if resource.respond_to? :key_with_key_value
          okey, ovalue = resource.key_with_key_value
          { okey => ovalue }
        elsif resource =~ /^\d+$/
          { id: resource.key_value }
        else
          { default_string_key => resource.key_value }
        end
      end
    end
  end
end
