module Opbeat
  module DataBuilders
    class Transactions < DataBuilder
      def build transactions
        reduced = transactions.reduce({ transactions: {}, traces: {} }) do |data, transaction|
          key = [transaction.endpoint, transaction.result, transaction.timestamp]

          if data[:transactions][key].nil?
            data[:transactions][key] = build_transaction(transaction)
          else
            data[:transactions][key][:durations] << transaction.duration
          end

          combine_traces transaction.traces, data[:traces]

          data
        end.reduce({}) do |data, kv|
          key, collection = kv
          data[key] = collection.values
          data
        end

        reduced[:traces].each do |trace|
          # traces' start time is average across collected
          trace[:start_time] = trace[:start_time].reduce(0, :+) / trace[:start_time].length
        end

        # preserve root
        root = reduced[:traces].shift
        # remove parentless traces
        reduced[:traces].delete_if { |t| t[:parents].empty? }
        # re-add root
        reduced[:traces].unshift root

        reduced
      end

      private

      def combine_traces traces, into
        traces.each do |trace|
          key = [trace.transaction.endpoint, trace.signature, trace.timestamp]

          if into[key].nil?
            into[key] = build_trace(trace)
          else
            into[key][:durations] << [trace.duration, trace.transaction.duration]
            into[key][:start_time] << trace.relative_start
          end
        end
      end

      def build_transaction transaction
        {
          transaction: transaction.endpoint,
          result: transaction.result,
          kind: transaction.kind,
          timestamp: transaction.timestamp,
          durations: [transaction.duration]
        }
      end

      def build_trace trace
        {
          transaction: trace.transaction.endpoint,
          signature: trace.signature,
          durations: [[trace.duration, trace.transaction.duration]],
          start_time: [trace.relative_start],
          kind: trace.kind,
          timestamp: trace.timestamp,
          parents: trace.parents && trace.parents.map(&:signature) || [],
          extra: trace.extra
        }
      end
    end
  end
end
