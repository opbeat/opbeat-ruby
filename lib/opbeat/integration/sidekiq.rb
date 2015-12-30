begin
  require 'sidekiq'
rescue LoadError
end

if defined? Sidekiq
  module Opbeat
    module Integration
      class Sidekiq
        def call worker, msg, queue
          begin
            yield
          rescue Exception => exception
            if [Interrupt, SystemExit, SignalException].include? exception.class
              raise exception
            end

            Opbeat.report exception

            raise
          end
        end
      end
    end
  end

  Sidekiq.configure_server do |config|
    if Sidekiq::VERSION.to_i < 3
      config.server_middleware do |chain|
        chain.add Opbeat::Integration::Sidekiq
      end
    else
      config.error_handlers << lambda do |exception|
        Opbeat.report exception
      end
    end
  end
end
