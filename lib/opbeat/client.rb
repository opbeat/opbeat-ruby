require 'thread'
require 'opbeat/subscriber'
require 'opbeat/http_client'
require 'opbeat/worker'
require 'opbeat/transaction'
require 'opbeat/trace'
require 'opbeat/error_message'

module Opbeat
  class Client
    include Logging

    KEY = :__opbeat_transaction_key
    LOCK = Mutex.new

    class TransactionInfo
      def current
        Thread.current[KEY]
      end
      def current= transaction
        Thread.current[KEY] = transaction
      end
    end

    # life cycle

    def self.inst
      @instance
    end

    def self.start! config = nil
      return @instance if @instance

      LOCK.synchronize do
        return @instance if @instance
        @instance = new(config).start!
      end
    end

    def self.stop!
      LOCK.synchronize do
        return unless @instance
        @instance.kill_worker
        @instance.unregister!
        @instance = nil
      end
    end

    at_exit do
      stop!
    end

    def initialize config
      @config = config
      @subscriber = Subscriber.new config, self
      @transaction_info = TransactionInfo.new
      @http_client = HttpClient.new config

      @queue = Queue.new
    end

    attr_reader :config, :queue

    def start!
      info "Starting client"

      @subscriber.register!

      self
    end

    def unregister!
      @subscriber.unregister!
    end

    # metrics

    def current_transaction
      @transaction_info.current
    end

    def current_transaction= transaction
      @transaction_info.current = transaction
    end

    def transaction endpoint, kind = nil, result = nil
      if transaction = current_transaction
        return yield(transaction) if block_given?
        return transaction
      end

      transaction = Transaction.new self, endpoint, kind, result
      self.current_transaction = transaction

      return transaction unless block_given?

      begin
        result = yield transaction
      ensure
        transaction.done
        transaction.release
      end

      result
    end

    def trace *args, &block
      unless transaction = current_transaction
        return yield if block_given?
        return
      end

      transaction.trace(*args, &block)
    end

    def enqueue transaction
      start_worker

      if config.environment.to_sym == :development
        debug { Util::Inspector.new.transaction transaction }
      end

      @queue << transaction
    end

    def start_worker
      return if worker_running?

      info { "Starting worker in thread".freeze }

      @worker_thread = Thread.new do
        begin
          Worker.new(config, @queue, @http_client).run
        rescue => e
          fatal "Failed booting worker:\n#{e.inspect}"
          debug e.backtrace.join("\n")
          raise
        ensure
          config.logger.flush
        end
      end
    end

    def kill_worker
      return unless worker_running?
      @worker_thread.kill
      @worker_thread = nil
    end

    # errors

    def report exception, opts = {}
      return unless exception

      unless exception.backtrace
        exception.set_backtrace caller
      end

      begin
        error_message = ErrorMessage.from_exception(config, exception)
        data = DataBuilders::Error.new(config).build error_message
        @http_client.post '/errors/', data
      rescue => e
        fatal "Failed to report error: #{e.inspect}"
        debug "error_message:#{error_message}"
      end
    end

    def capture
      unless block_given?
        return Kernel.at_exit do
          if $!
            logger.debug "Caught a post-mortem exception: #{$!.inspect}"
            report($!)
          end
        end
      end

      begin
        yield
      rescue Error => e
        raise # Don't capture Opbeat errors
      rescue Exception => e
        report(e)
        raise
      end
    end

    # releases

    def release rel
      info "Sending release #{rel[:rev]}"
      @http_client.post '/releases/', rel
    end

    private

    def ensure_worker_running
      return if worker_running?

      LOCK.synchronize do
        return if worker_running?
        start_worker
      end
    end

    def worker_running?
      @worker_thread && @worker_thread.alive?
    end

  end
end
