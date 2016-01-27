require 'uri'
require 'net/http'
require 'json'

module Opbeat
  # @api private
  class HttpClient
    include Logging

    USER_AGENT = "opbeat-ruby/#{Opbeat::VERSION}".freeze

    attr_reader :state
    attr_reader :adapter

    def initialize(config)
      @config = config
      @adapter = HTTPAdapter.new(config)
      @state = ClientState.new config
    end

    attr_reader :config

    def post(resource, body)
      path = abs_path(resource)
      debug "POST #{resource}"

      unless state.should_try?
        info "Temporarily skipping sending to Opbeat due to previous failure."
        return
      end

      if body.is_a?(Hash) || body.is_a?(Array)
        body = JSON.dump(body)
      end

      request = adapter.post path do |req|
        req['Authorization'] = auth_header
        req['Content-Type'] = 'application/json'.freeze
        req['Content-Length'] = body.bytesize.to_s
        req['User-Agent'] = USER_AGENT
        req.body = body
      end

      begin
        response = adapter.perform_request request
        unless response.code.to_i.between?(200, 299)
          raise Error.new("Error from Opbeat server (#{response.code}): #{response.body}")
        end
      rescue
        debug { JSON.parse(body).inspect }
        @state.fail!
        raise
      end

      @state.success!

      response
    end

    private

    def auth_header
      "Bearer #{@config.secret_token}"
    end

    def abs_path path
      "/api/v1/organizations/#{@config.organization_id}" +
        "/apps/#{@config.app_id}#{path}"
    end

    def encode(event)
      event_hash = @filter.process_event_hash(event.to_hash)
      event_hash.to_json
    end

    class HTTPAdapter
      def initialize conf
        @config = conf
      end

      def post path
        req = Net::HTTP::Post.new path
        yield req if block_given?
        req
      end

      def perform_request req
        http.start do |http|
          http.request req
        end
      end

      private

      def http
        return @http if @http

        http = Net::HTTP.new server_uri.host, server_uri.port
        http.use_ssl = @config.use_ssl
        http.read_timeout = @config.timeout
        http.open_timeout = @config.open_timeout

        @http = http
      end

      def server_uri
        @uri ||= URI(@config.server)
      end
    end

    class ClientState
      def initialize(config)
        @config = config
        @retry_number = 0
        @last_check = Time.now
      end

      def should_try?
        return true if @status == :online

        interval = ([@retry_number, 6].min() ** 2) * @config.backoff_multiplier
        return true if Time.now - @last_check > interval

        false
      end

      def fail!
        @status = :error
        @retry_number += 1
        @last_check = Time.now
      end

      def success!
        @status = :online
        @retry_number = 0
        @last_check = nil
      end
    end
  end

end
