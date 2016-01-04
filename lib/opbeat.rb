require 'opbeat/version'
require 'opbeat/configuration'

require 'opbeat/logging'
require 'opbeat/client'
require 'opbeat/error'

require 'opbeat/middleware'

require 'opbeat/integration/railtie' if defined?(Rails)

module Opbeat
  class << self
    extend Forwardable

    def_delegators :client, :transaction, :trace, :report, :release

    # Here for the delegator
    def client
      Client.inst
    end
  end

  def self.start! *args
    Client.start!(*args)
  end

  def self.stop!
    Client.stop!
  end
end
