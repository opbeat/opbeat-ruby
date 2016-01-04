require 'active_support/notifications'
require 'opbeat/normalizers'

module Opbeat
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
      def initialize name, trace
        @name = name
        @trace = trace
      end
      attr_reader :name, :trace
    end

    def start name, id, payload
      return unless transaction = @client.current_transaction

      normalized = @normalizers.normalize(transaction, name, payload)

      trace = nil

      unless normalized == :skip
        sig, kind, extra = normalized
        trace = Trace.new(transaction, sig, kind, nil, extra).start(transaction.start)
        # debug "                       start:#{sig}"
      end

      notification = Notification.new(name, trace)
      transaction.notifications << notification
    end

    def finish name, id, payload
      return unless transaction = @client.current_transaction

      while notification = transaction.notifications.pop
        if notification.name == name
          if trace = notification.trace
            # debug "                      finish:#{trace.signature}"
            trace.parents = parents_for(transaction)
            transaction.traces << trace.done
          end
          return
        end
      end
    end

    private

    def parents_for transaction
      transaction.notifications.select(&:trace).map { |n| n.trace.signature }
    end

    def actions_regex
      @actions_regex ||= Regexp.new("(" + @normalizers.keys.join("|") + ")")
    end

  end
end
