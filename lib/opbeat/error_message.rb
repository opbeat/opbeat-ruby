require 'opbeat/line_cache'
require 'opbeat/error_message/exception'
require 'opbeat/error_message/stacktrace'
require 'opbeat/error_message/http'
require 'opbeat/error_message/user'

module Opbeat
  class ErrorMessage
    extend Logging

    DEFAULTS = {
      level: :error,
      logger: 'root'.freeze
    }.freeze

    def initialize config, message, attrs = {}
      @config = config

      @message = message
      @timestamp = Time.now.utc.to_i
      DEFAULTS.merge(attrs).each do |k,v|
        send(:"#{k}=", v)
      end
      @filter = Filter.new config

      yield self if block_given?
    end

    attr_reader :config
    attr_accessor :message
    attr_reader :timestamp
    attr_accessor :level
    attr_accessor :logger
    attr_accessor :culprit
    attr_accessor :machine
    attr_accessor :extra
    attr_accessor :param_message
    attr_accessor :exception
    attr_accessor :stacktrace
    attr_accessor :http
    attr_accessor :user

    def self.from_exception config, exception, opts = {}
      message = "#{exception.class}: #{exception.message}"

      if config.excluded_exceptions.include? exception.class.to_s
        info "Skipping excluded exception #{exception.class}"
        return nil
      end

      error_message = new(config, message) do |msg|
        msg.level = :error
        msg.exception = Exception.from(exception)
        msg.stacktrace = Stacktrace.from(config, exception)
      end

      if frames = error_message.stacktrace && error_message.stacktrace.frames
        if first_frame = frames[0]
          error_message.culprit = "#{first_frame.filename}:#{first_frame.lineno}:in `#{first_frame.function}'"
        end
      end

      if env = opts[:rack_env]
        error_message.http = HTTP.from_rack_env env, filter: @filter
        error_message.user = User.from_rack_env config, env
      end

      if extra = opts[:extra]
        error_message.extra = extra
      end

      error_message
    end
  end
end
