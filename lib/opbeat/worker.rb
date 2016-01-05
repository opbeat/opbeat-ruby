require 'opbeat/data_builders'

module Opbeat
  # @api private
  class Worker
    include Logging

    def initialize config, queue, http_client
      @config = config
      @queue = queue
      @http_client = http_client

      @data_builder = DataBuilders::Transactions.new(config).freeze
    end

    attr_reader :config

    def run
      loop do
        info "Sending pending transactions: #{@queue.length}"
        send_transactions
        sleep config.transaction_post_interval
      end

      at_exit do
        send_transactions
      end
    end

    def send_transactions
      return if @queue.empty?

      transactions = []

      until @queue.empty?
        transactions << @queue.shift
      end

      info "Post #{transactions.length} transactions"
      begin
        data = @data_builder.build(transactions)
        # debug { JSON.pretty_generate(data) }
        @http_client.post('/transactions/', JSON.dump(data))
      rescue => e
        info "Failed POST #{e.inspect}"
        debug e.backtrace.join("\n")
      end
    end

  end
end
