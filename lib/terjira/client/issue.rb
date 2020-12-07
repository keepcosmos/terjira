require_relative 'base'

module Terjira
  module Client
    class Issue < Base
      class << self
        delegate :jql, :find, to: :resource

        def all(options = {})
          return resource.all if options.blank?
          max_results = options.delete(:max_results) || 500
          jql(build_jql(options), max_results: max_results)
        end

        def all_epic_issues(epic)
          resp = agile_api_get("epic/#{epic.key}/issue")
          resp["issues"].map { |issue| build(issue) }
        end

        def find(issue, options = {})
          resp = agile_api_get("issue/#{issue.key_value}", options)
          build(resp)
        end

        def search(options = {})
          resource.jql(build_jql(options))
        end

        def delete(issue)
          api_delete("issue/#{issue.key_value}")
        end

        def priority(issue, newPriority)
          body = {"update":{"priority":[{"set":{"id":newPriority}}]}}
          api_put("issue/#{issue.key_value}", body)
        end

        def assign(issue, assignee)
          body = { name: assignee.key_value }.to_json
          api_put("issue/#{issue.key_value}/assignee", body)
        end

        def attach_file(issue, file)
          attachment = JIRA::Resource::Attachment.new(client, issue: find(issue))
          attachment.save!('file' => file)
          find(issue)
        end

        def write_comment(issue, message)
          api_post("issue/#{issue.key_value}/comment", { body: message }.to_json)
          find(issue)
        end

        def edit_comment(issue, comment_id, message)
          api_put("issue/#{issue.key_value}/comment/#{comment_id}", { body: message }.to_json)
          find(issue)
        end

        def create(options = {})
          params = extract_to_fields_params(options)
          resp = api_post 'issue', params.to_json
          find(resp['id'])
        end

        def update(issue, options = {})
          params = extract_to_update_params(options)
          params.merge!(extract_to_fields_params(options))
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

          (custom_fields + [:summary, :description]).each_entry do |k, _v|
            params[k] = opts.delete(k) if opts.key?(k)
          end

          [:project, :parent].each do |resource|
            params[resource] = { key: opts.delete(resource).key_value } if opts.key?(resource)
          end

          opts.each { |k, v| params[k] = convert_param_key_value_hash(v) }

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
