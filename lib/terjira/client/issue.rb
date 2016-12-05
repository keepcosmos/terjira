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
        convert_options_to_params(options)
      end

      def trans(issue)

      end

      private

      def convert_options_to_params(options = {})
        opts = options.dup
        params = opts.slice(:summary, :comment)
        opts.each do |key, value|
          opts[key] = if value.respond_to? :key_with_key_value
                        okey, ovalue = value.key_with_key_value
                        { okey => ovalue}
                      elsif value =~ /^\d+$/
                        { id: Integer(value) }
                      else
                        { name: value }
                      end
        end
        opts
      end

      def find_string_value_param_key(resource_key)
        @param_key_mapping ||= {
          project: :key,
          issuetype: :name,
          priority: :name,
          status: :name,
          assignee: :key
        }
        @param_key_mapping[resource_key.to_sym]
      end
    end
  end
end
