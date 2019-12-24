module Terjira
  module Client
    module JQLBuilder
      STRICT_KEYS = %w[sprint assignee issuetype priority project status statusCategory].freeze
      SEARCH_KEYS = %w[summary description].freeze

      def build_jql(options = {})
        search = options.select { |k, _v| SEARCH_KEYS.include?(k.to_s) }
        strict = options.select { |k, _v| STRICT_KEYS.include?(k.to_s) }

        query = [strict_matching(strict), search_matching(search)]
                .reject(&:blank?).join(' AND ')

        query
      end

      private

      def strict_matching(options = {})
        q_options = options.inject({}) do |memo, (k, v)|
          memo[k.to_s] = v
          memo
        end.slice(*STRICT_KEYS)

        query = q_options.map do |key, value|
          if value.is_a? Array
            values = value.map { |v| "\"#{v.key_value}\"" }.join(',')
            "#{key} IN (#{values})"
          else
            if value.key_value.to_s =~ /^\d+$/
              "#{key}=#{value.key_value}"
            else
              "#{key}=\"#{value.key_value}\""
            end
          end
        end.reject(&:blank?).join(' AND ')

        query
      end

      def search_matching(options = {})
        q_options = options.inject({}) do |memo, (k, v)|
          memo[k.to_s] = v
          memo
        end.slice(*SEARCH_KEYS)

        query = q_options.map do |key, value|
          "#{key}~\"#{value.key_value}\""
        end.reject(&:blank?).join(' AND ')

        query
      end
    end
  end
end
