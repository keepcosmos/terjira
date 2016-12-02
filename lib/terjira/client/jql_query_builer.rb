module Terjira
  module Client
    module JQLQueryBuilder
      JQL_KEYS = %w(board sprint assignee issuetype priority project status statusCategory).freeze

      def build_jql_query(options = {})
        q_options = options.inject({}) do |memo,(k,v)|
          memo[k.to_s] = v
          memo
        end.slice(*JQL_KEYS)

        q_options.map do |key, value|
          if value.is_a? Array
            "#{key} IN (#{value.map { |v| "\"#{v.key_value}\""}.join(",")})"
          else
            "#{key} = #{value.key_value}"
          end
        end.reject(&:blank?).join(" AND ")
      end
    end
  end
end
