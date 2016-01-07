require 'opbeat/util'

module Opbeat
  class Trace

    def initialize transaction, signature, kind = 'code.custom'.freeze, parents = nil, extra = {}
      @transaction = transaction
      @signature = signature
      @kind = kind
      @parents = parents
      @extra = extra

      @timestamp = Util.nearest_minute.to_i
    end

    attr_accessor :signature, :kind, :parents, :extra
    attr_reader :transaction, :timestamp, :duration, :relative_start

    def start transaction_start = nil
      transaction_start ||= @transaction && @transaction.start

      unless transaction_start
        raise ArgumentError, "No transaction nor transaction_start set for trace"
      end

      @start_time = Time.now.to_f
      @relative_start = (@start_time - transaction_start) * 1000

      self
    end

    def done
      @duration = ((Time.now.to_f - @start_time) * 1000).round 4

      self
    end

    def done?
      !!duration
    end

  end
end
