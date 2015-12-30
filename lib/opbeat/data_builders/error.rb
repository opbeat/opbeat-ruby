require 'opbeat/filter'

module Opbeat
  module DataBuilders
    class Error < DataBuilder
      def build error_message
        return {
          message: error_message.message,
          timestamp: error_message.timestamp,
          level: error_message.level,
          logger: error_message.logger,
          culprit: error_message.culprit,
          machine: error_message.machine,
          extra: error_message.extra,
          param_message: error_message.param_message,
          exception: error_message.exception.to_h,
          stacktrace: error_message.stacktrace.to_h,
          http: error_message.http.to_h,
          user: error_message.user.to_h
        }
      end
    end
  end
end
