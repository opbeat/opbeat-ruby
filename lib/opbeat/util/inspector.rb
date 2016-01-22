# encoding: utf-8

module Opbeat
  module Util
    class Inspector

      DEFAULTS = {
        width: 120
      }.freeze

      NEWLINE = "\n".freeze
      SPACE = " ".freeze

      def initialize config = {}
        @config = DEFAULTS.merge(config)
      end

      def ms nanos
        nanos.to_f / 1_000_000
      end

      def transaction transaction, opts = {}
        w = @config[:width].to_f
        f = w / ms(transaction.duration)

        traces = transaction.traces

        traces = traces.reduce([]) do |state, trace|
          descriptions = [
            "#{trace.signature} - #{trace.kind}",
            "transaction:#{trace.transaction.endpoint}"
          ]

          if opts[:include_parents]
            descriptions << "parents:#{trace.parents.map(&:signature).join(',')}"
          end

          descriptions << "duration:#{ms trace.duration}ms - rel:#{ms trace.relative_start}ms"

          start_diff = ms(trace.start_time) - ms(transaction.start_time)
          indent = (start_diff.floor * f).to_i

          longest_desc_length = descriptions.map(&:length).max
          desc_indent = [[indent, w - longest_desc_length].min, 0].max

          lines = descriptions.map do |desc|
            "#{SPACE * desc_indent}#{desc}"
          end

          if trace.duration
            span = (ms(trace.duration) * f).ceil.to_i
            lines << "#{SPACE * indent}+#{"-" * [(span - 2), 0].max}+"
          else
            lines << "#{SPACE * indent}UNFINISHED"
          end

          state << lines.join("\n")
          state
        end.join("\n")

        <<-STR.gsub(/^\s{8}/, '')
        \n#{"=" * (w.to_i)}
        #{transaction.endpoint} - kind:#{transaction.kind} - #{transaction.duration.to_f / 1_000_000}ms
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
