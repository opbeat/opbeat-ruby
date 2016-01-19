require 'opbeat/util'

module Opbeat
  class Transaction

    ROOT_TRACE_NAME = 'transaction'.freeze

    def initialize client, endpoint, kind = 'code.custom', result = nil
      @client = client
      @endpoint = endpoint
      @kind = kind
      @result = result

      @timestamp = Util.nearest_minute.to_i
      @start = Time.now.to_f

      @root_trace = Trace.new(self, ROOT_TRACE_NAME, ROOT_TRACE_NAME, []).start
      @traces = [@root_trace]

      @notifications = []
    end

    attr_accessor :endpoint, :kind, :result, :duration
    attr_reader :timestamp, :start, :traces, :notifications, :root_trace

    def release
      @client.current_transaction = nil
    end

    def done result = nil
      @result = result

      @root_trace.done
      @duration = @root_trace.duration

      self
    end

    def done?
      @root_trace.done?
    end

    def submit result = nil
      done result

      release

      @client.submit_transaction self

      self
    end

    def trace signature, kind = nil, parents = nil, extra = nil, &block
      parents = running_traces

      trace = Trace.new self, signature, kind, parents, extra
      trace.start(parents.last ? parents.last.start_time : transaction.start)

      traces << trace

      return trace unless block_given?

      begin
        result = yield trace
      ensure
        trace.done
      end

      result
    end

    def running_traces
      traces.select(&:running?)
    end

    def running_trace_leaf
      traces.reverse.find(&:running?)
    end

    def inspect
      info = %w{endpoint kind result duration timestamp start}
      <<-TEXT
<Transaction #{info.map { |m| "#{m}:#{send(m).inspect}" }.join(' ')}>
  #{traces.map(&:inspect).join("\n  ")}"
      TEXT
    end

  end
end
