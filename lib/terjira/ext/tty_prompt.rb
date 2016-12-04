require 'tty-prompt'
# Fix some unexpected result
module TTY
  class Prompt
    class Question
      # Decide how to handle input from user
      #
      # @api private
      def process_input
        @input = read_input
        if Utils.blank?(@input)
          @input = default? ? default : nil
        end

        if @input.is_a? String
          @input = encode_input(@input)
        elsif @input.is_a? Array
          @input = @input.map { |input| encode_input(input) }
        end

        @evaluator.(@input)
      end

      # Encod input
      #
      # @return [Boolean]
      #
      # @api private
      def encode_input(line)
        line.codepoints.to_a.pack('C*').force_encoding('utf-8')
      end
    end
  end
end
