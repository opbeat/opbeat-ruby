require 'opbeat/version'
require 'opbeat/configuration'

require 'opbeat/logging'
require 'opbeat/client'
require 'opbeat/error'
require 'opbeat/trace_helpers'

require 'opbeat/middleware'

require 'opbeat/integration/railtie' if defined?(Rails)

require 'opbeat/injections'
require 'opbeat/injections/net_http'
require 'opbeat/injections/redis'
require 'opbeat/injections/sinatra'
require 'opbeat/injections/sequel'

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
    unless client
      return yield if block_given?
      return nil
    end

    client.transaction endpoint, kind, result, &block
  end

  # Starts a new trace under the current Transaction
  #
  # @param signature [String] A description of the trace, eq `SELECT FROM "users"`
  # @param kind [String] The kind of trace, eq `db.mysql2.query`
  # @param extra [Hash] Extra information about the trace
  # @yield [Trace] Optional block encapsulating trace
  # @return [Trace] Unless block given
  def self.trace signature, kind = nil, extra = nil, &block
    unless client
      return yield if block_given?
      return nil
    end

    client.trace signature, kind, extra, &block
  end

  def self.flush_transactions
    unless client
      return yield if block_given?
      return nil
    end

    client.flush_transactions
  end

  # Sets context for future errors
  #
  # @param context [Hash]
  def self.set_context context
    return nil unless client
    client.set_context context
  end

  # Updates context for errors within the block
  #
  # @param context [Hash]
  # @yield [Trace] Block in which the context is used
  def self.with_context context, &block
    unless client
      return yield if block_given?
      return nil
    end

    client.context context, &block
  end

  # Send an exception to Opbeat
  #
  # @param exception [Exception]
  # @param opts [Hash]
  # @option opts [Hash] :rack_env A rack env object
  # @return [Net::HTTPResponse]
  def self.report exception, opts = {}
    unless client
      return yield if block_given?
      return nil
    end

    client.report exception, opts
  end

  # Send an exception to Opbeat
  #
  # @param message [String]
  # @param opts [Hash]
  # @return [Net::HTTPResponse]
  def self.report_message message, opts = {}
    unless client
      return yield if block_given?
      return nil
    end

    client.report_message message, opts
  end

  # Captures any exceptions raised inside the block
  #
  def self.capture &block
    unless client
      return yield if block_given?
      return nil
    end

    client.capture(&block)
  end

  # Notify Opbeat of a release
  #
  # @param rel [Hash]
  # @option rel [String] :rev Revision
  # @option rel [String] :branch
  # @return [Net::HTTPResponse]
  def self.release rel, opts = {}
    unless client
      return yield if block_given?
      return nil
    end

    client.release rel, opts
  end

  private

  def self.client
    Client.inst
  end
end
