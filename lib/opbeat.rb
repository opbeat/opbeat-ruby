require 'opbeat/version'
require 'opbeat/configuration'

require 'opbeat/logging'
require 'opbeat/client'
require 'opbeat/error'

require 'opbeat/middleware'

require 'opbeat/integration/railtie' if defined?(Rails)

require 'opbeat/injections'
require 'opbeat/injections/net_http'

require 'opbeat/integration/delayed_job'
require 'opbeat/integration/sidekiq'
require 'opbeat/integration/resque'

module Opbeat
  class << self
    extend Forwardable

    def_delegators :client, :transaction, :trace, :report, :release

    def client
      unless client = Client.inst
        raise Error.new("Opbeat client wasn't started")
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

  def self.started?
    !!Client.inst
  end
end
