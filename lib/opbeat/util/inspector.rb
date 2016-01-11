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

        traces = transaction.traces.dup.sort_by do |trace|
          trace.relative_start
        end

        traces.shift # root

        traces = traces.map do |trace|
          descriptions = ["#{trace.signature} - #{trace.kind}"[0...w]]

          if opts[:include_parents]
            parents_sig = trace.parents.join(' ')[0...w]
            descriptions << parents_sig
          end

          indent = (trace.relative_start * f).to_i

          longest_desc = descriptions.map(&:length).max
          desc_indent = [[indent, w - longest_desc].min, 0].max

          span = (trace.duration * f).to_i

          lines = descriptions.map do |desc|
            "#{SPACE * desc_indent}#{desc}"
          end

          lines << "#{SPACE * indent}+#{"-" * [(span - 2), 0].max}+"

          lines
        end.join(NEWLINE)

        <<-STR.gsub(/^\s{10}/, '')
          \n#{"=" * (w.to_i)}
        #{transaction.endpoint} - kind:#{transaction.kind} - #{transaction.duration}ms
          +#{"-" * (w.to_i - 2)}+
        #{traces}
        STR
      end

    end
  end
end
