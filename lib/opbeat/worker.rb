module Opbeat
  # @api private
  class Worker
    include Logging

    class PostRequest < Struct.new(:path, :data)
      # require all parameters
      def initialize path, data
        super(path, data)
      end
    end

    def initialize config, queue, http_client
      @config = config
      @queue = queue
      @http_client = http_client
    end

    attr_reader :config

    def run
      loop do
        process_queue
      end
    end

    private

    def process_queue
      while req = @queue.pop
        process_request req
      end
    end

    def process_request req
      debug "Worker processing #{req.path}"

      unless config.validate!
        info "Invalid config - Skipping posting to Opbeat"
        return
      end

      begin
        @http_client.post(req.path, req.data)
      rescue => e
        fatal "Failed POST: #{e.inspect}"
        debug e.backtrace.join("\n")
      end
    end

  end
end
