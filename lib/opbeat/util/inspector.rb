# encoding: utf-8

module Opbeat
  module Util
    class Inspector

      DEFAULTS = {
        width: 100
      }.freeze

      NEWLINE = "\n".freeze
      SPACE = " ".freeze

      def initialize config = {}
        @config = DEFAULTS.merge(config)
      end

      def transaction transaction, opts = {}
        w = @config[:width].to_f
        f = w / transaction.duration

        traces = transaction.traces

        traces = traces.reduce(Struct.new(:lines, :indent).new([], 0)) do |state, trace|
          descriptions = [
            "#{trace.signature} - #{trace.kind}",
            "transaction:#{trace.transaction.endpoint}"
          ]

          if opts[:include_parents]
            descriptions << "parents:#{trace.parents.map(&:signature).join(',')}"
          end

          indent = state.indent + (trace.relative_start * f).to_i

          longest_desc_length = descriptions.map(&:length).max
          desc_indent = [[indent, w - longest_desc_length].min, 0].max

          lines = descriptions.map do |desc|
            "#{SPACE * desc_indent}#{desc}"
          end

          if trace.duration
            span = (trace.duration * f).to_i
            lines << "#{SPACE * indent}+#{"-" * [(span - 2), 0].max}+"
          else
            lines << "#{SPACE * indent}UNFINISHED"
          end

          state.indent = indent
          state.lines << lines.join("\n")
          state
        end.lines.join("\n")

        <<-STR.gsub(/^\s{8}/, '')
        \n#{"=" * (w.to_i)}
        #{transaction.endpoint} - kind:#{transaction.kind} - #{transaction.duration}ms
        +#{"-" * (w.to_i - 2)}+
        #{traces}
        STR
      rescue => e
        puts e
        puts e.backtrace.join("\n")
        transaction.inspect
      end

    end
  end
end
