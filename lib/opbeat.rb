require 'opbeat/version'
require 'opbeat/configuration'

require 'opbeat/logging'
require 'opbeat/client'
require 'opbeat/error'

require 'opbeat/middleware'

require 'opbeat/integration/railtie' if defined?(Rails)
require 'opbeat/integration/delayed_job'
require 'opbeat/integration/sidekiq'

module Opbeat
  class << self
    extend Forwardable

    def_delegators :client, :transaction, :trace, :report, :release

    # Here for the delegator
    def client
      unless client = Client.inst
        puts "Opbeat client wasn't started"
      end

      client
    end
  end

  def self.start! *args
    Client.start!(*args)
  end

  def self.stop!
    Client.stop!
  end
end
