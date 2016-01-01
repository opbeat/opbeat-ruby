require 'opbeat/filter'

module Opbeat
  module DataBuilders
    class Error < DataBuilder
      def build error_message
        h = {
          message: error_message.message,
          timestamp: error_message.timestamp,
          level: error_message.level,
          logger: error_message.logger,
          culprit: error_message.culprit,
          machine: error_message.machine,
          extra: error_message.extra,
          param_message: error_message.param_message
        }

        h[:exception] = error_message.exception.to_h if error_message.exception
        h[:stacktrace] = error_message.stacktrace.to_h if error_message.stacktrace
        h[:http] = error_message.http.to_h if error_message.http
        h[:user] = error_message.user.to_h if error_message.user

        h
      end
    end
  end
end
