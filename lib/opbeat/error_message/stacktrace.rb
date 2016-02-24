module Opbeat
  class ErrorMessage
    class Stacktrace

      def initialize config, frames
        @config, @frames = config, frames
      end

      attr_reader :frames

      def self.from config, exception
        return unless exception.backtrace

        new(config, exception.backtrace.reverse.map do |line|
          Frame.from_line config, line
        end)
      end

      def to_h
        { frames: frames.map(&:to_h) }
      end

      private

      class Frame < Struct.new(:filename, :lineno, :abs_path, :function, :vars,
                               :pre_context, :context_line, :post_context)

        BACKTRACE_REGEX = /^(.+?):(\d+)(?::in `(.+?)')?$/.freeze

        class << self
          def from_line config, line
            _, abs_path, lineno, function = line.match(BACKTRACE_REGEX).to_a
            lineno = lineno.to_i
            filename = strip_load_path(abs_path)

            if lines = config.context_lines
              pre_context, context_line, post_context =
                get_contextlines(abs_path, lineno, lines)
            end

            new filename, lineno, abs_path, function, nil,
              pre_context, context_line, post_context
          end

          private

          def strip_load_path path
            prefix = $:
              .map(&:to_s)
              .select { |s| path.start_with?(s) }
              .sort_by { |s| s.length }
              .last

            return path unless prefix

            path[prefix.chomp(File::SEPARATOR).length + 1..-1]
          end

          def get_contextlines path, line, context
            lines = (2 * context + 1).times.map do |i|
              LineCache.find(path, line - context + i)
            end

            pre =  lines[0..(context-1)]
            line = lines[context]
            post = lines[(context+1)..-1]

            [pre, line, post]
          end
        end
      end

    end
  end
end
