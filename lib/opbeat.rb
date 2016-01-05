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
  # Start the Opbeat client
  #
  # @param conf [Configuration] An Configuration object
  def self.start! conf
    Client.start! conf
  end

  # Stop the Opbeat client
  def self.stop!
    Client.stop!
  end

  def self.started?
    !!Client.inst
  end

  # Start a new transaction or return the currently running
  #
  # @param endpoint [String] A description of the transaction, eg `ExamplesController#index`
  # @param kind [String] The kind of the transaction, eg `app.request.get` or `db.mysql2.query`
  # @param result [Object] Result of the transaction, eq `200` for a HTTP server
  # @yield [Transaction] Optional block encapsulating transaction
  # @return [Transaction] Unless block given
  def self.transaction endpoint, kind = nil, result = nil, &block
    client.transaction endpoint, kind, result, &block
  end

  # Starts a new trace under the current Transaction
  #
  # @param signature [String] A description of the trace, eq `SELECT FROM "users"`
  # @param kind [String] The kind of trace, eq `db.mysql2.query`
  # @param parents [Array<String>] Signatures of parent traces
  # @param extra [Hash] Extra information about the trace
  # @yield [Trace] Optional block encapsulating trace
  # @return [Trace] Unless block given
  def self.trace signature, kind = nil, parents = nil, extra = {}, &block
    client.trace signature, kind, parents, extra, &block
  end

  # Send an exception to Opbeat
  #
  # @param exception [Exception]
  # @param opts [Hash]
  # @option opts [Hash] :rack_env A rack env object
  # @return [Net::HTTPResponse]
  def self.report exception, opts = {}
    client.report exception, opts
  end

  # Notify Opbeat of a release
  #
  # @param rel [Hash]
  # @option rel [String] :rev Revision
  # @option rel [String] :branch
  # @return [Net::HTTPResponse]
  def self.release rel
    client.release rel
  end

  private

  def self.client
    unless Client.inst
      raise Error.new("Opbeat client wasn't started")
    end

    Client.inst
  end
end
