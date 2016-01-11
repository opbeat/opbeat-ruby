require 'opbeat/util'

module Opbeat
  class Transaction

    def initialize client, endpoint, kind = 'code.custom', result = nil
      @client = client
      @endpoint = endpoint
      @kind = kind
      @result = result

      @timestamp = Util.nearest_minute.to_i
      @start = Time.now.to_f

      @root_trace = Trace.new(self, endpoint, 'transaction', nil).start(@start)
      @traces = [@root_trace]
      @notifications = []
    end

    attr_accessor :endpoint, :kind, :result, :duration
    attr_reader :timestamp, :start, :traces, :notifications, :root_trace

    def endpoint= val
      @endpoint = @root_trace.signature = val
    end

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
    end

    def trace signature, kind = nil, parents = nil, extra = {}, &block
      trace = Trace.new self, signature, kind, [@root_trace.signature], extra
      traces << trace
      trace.start

      return trace unless block_given?

      begin
        result = yield trace
      ensure
        trace.done
      end

      result
    end

  end
end
