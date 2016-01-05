module Opbeat
  module Util
    def self.nearest_minute
      now = Time.now
      now - now.to_i % 60
    end

    class Inspector

      DEFAULTS = {
        width: 100
      }.freeze

      NEWLINE = "\n".freeze
      SPACE = " ".freeze

      def initialize config = {}
        @config = DEFAULTS.merge(config)
      end

      def transaction transaction, include_parents: false
        w = @config[:width].to_f
        f = w / transaction.duration

        traces = transaction.traces.dup.sort_by do |trace|
          trace.relative_start
        end

        traces = traces.map do |trace|
          descriptions = [trace.signature || ""]

          if include_parents
            parents_sig = trace.parents.join(' ')
            descriptions << parents_sig
          end

          indent = (trace.relative_start * f).to_i

          desc_lengths = descriptions.map { |d| w - d.length }
          desc_indent = [0, ([indent] + desc_lengths).min].max

          span = (trace.duration * f).to_i

          descriptions.map do |desc|
            "#{SPACE * desc_indent}#{desc}"
          end + ["#{" " * indent}+#{"-" * [(span - 2), 0].max}+"]
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
