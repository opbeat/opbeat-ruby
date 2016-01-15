require 'opbeat/util'

module Opbeat
  class Trace

    def initialize transaction, signature, kind = nil, parents = nil, extra = nil
      @transaction = transaction
      @signature = signature
      @kind = kind || 'code.custom'.freeze
      @parents = parents || []
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
      @relative_start = (@start_time - transaction_start) * 1000.0

      self
    end

    def done
      @duration = ((Time.now.to_f - @start_time) * 1000.0)

      self
    end

    def done?
      !!duration
    end

    def running?
      !done?
    end

    def inspect
      info = %w{signature kind parents extra timestamp duration relative_start}
      "<Trace #{info.map { |m| "#{m}:#{send(m).inspect}" }.join(' ')}>"
    end
  end
end
