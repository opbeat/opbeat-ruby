require 'opbeat/normalizers'

module Opbeat
  # @api private
  class Subscriber
    include Logging

    def initialize config, client
      @config = config
      @client = client
      @normalizers = Normalizers.build config
    end

    attr_reader :config

    def register!
      unregister! if @subscription
      @subscription = ActiveSupport::Notifications.subscribe actions_regex, self
    end

    def unregister!
      ActiveSupport::Notifications.unsubscribe @subscription
      @subscription = nil
    end

    # AS::Notifications API

    class Notification
      def initialize id, trace
        @id = id
        @trace = trace
      end
      attr_reader :id, :trace
    end

    def start name, id, payload
      return unless transaction = @client.current_transaction

      normalized = @normalizers.normalize(transaction, name, payload)

      trace = nil

      unless normalized == :skip
        sig, kind, extra = normalized

        trace = Trace.new(transaction, sig, kind, transaction.running_traces, extra)
        offset = transaction.current_offset

        transaction.traces << trace

        trace.start offset
      end

      transaction.notifications << Notification.new(id, trace)
    end

    def finish name, id, payload
      return unless transaction = @client.current_transaction

      while notification = transaction.notifications.pop
        if notification.id == id
          if trace = notification.trace
            trace.done
          end
          return
        end
      end
    end

    private

    def actions_regex
      @actions_regex ||= Regexp.new(
        "(".freeze + @normalizers.keys.join("|".freeze) + ")".freeze
      )
    end

  end
end
