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

      @root_trace = Trace.new(self, ROOT_TRACE_NAME, ROOT_TRACE_NAME)
      @traces = [@root_trace]
      @notifications = []

      @start_time = Util.nanos
      @root_trace.start @start_time
    end

    attr_accessor :endpoint, :kind, :result, :duration
    attr_reader :timestamp, :start_time, :traces, :notifications, :root_trace

    def release
      @client.current_transaction = nil
    end

    def done result = nil
      @result = result

      @root_trace.done Util.nanos
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

    def trace signature, kind = nil, extra = nil, &block
      trace = Trace.new(self, signature, kind, running_traces, extra)

      rel_time = current_offset

      traces << trace

      trace.start rel_time

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

    def current_trace
      traces.reverse.find(&:running?)
    end

    def current_offset
      if curr = current_trace
        return curr.start_time
      end

      start_time
    end

    def inspect
      info = %w{endpoint kind result duration timestamp start_time}
      <<-TEXT
<Transaction #{info.map { |m| "#{m}:#{send(m).inspect}" }.join(' ')}>
  #{traces.map(&:inspect).join("\n  ")}"
      TEXT
    end

  end
end
