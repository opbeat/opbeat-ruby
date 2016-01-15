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

        trace = Trace.new(transaction, sig, kind, parents_for(transaction), extra)
        trace.start(transaction.start)

        transaction.traces << trace
      end

      transaction.notifications << name
    end

    def finish name, id, payload
      return unless transaction = @client.current_transaction

      while notification = transaction.notifications.pop
        if notification == name
          transaction.traces.select(&:running?).last.done
          return
        end
      end
    end

    private

    def parents_for transaction
      transaction.traces.select(&:running?).map(&:signature)
    end

    def actions_regex
      @actions_regex ||= Regexp.new(
        "(".freeze + @normalizers.keys.join("|".freeze) + ")".freeze
      )
    end

  end
end
