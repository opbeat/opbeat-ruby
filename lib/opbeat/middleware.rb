module Opbeat
  class Middleware
    def initialize app, opts = {}
      @app = app
      @opts = opts
    end

    def call env
      begin
        transaction = Opbeat.transaction "Rack", "app.rack.request"
        resp = @app.call env
        transaction.submit(resp.first)
      rescue Error
        raise # Don't report Opbeat errors
      rescue Exception => e
        Opbeat.report e, rack_env: env
        transaction.submit(500) if transaction
        raise
      ensure
        transaction.release if transaction
      end

      if error = env['rack.exception'] || env['sinatra.error']
        Opbeat.report error, rack_env: env
      end

      resp
    end
  end
end
