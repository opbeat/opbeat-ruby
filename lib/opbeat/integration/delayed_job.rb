begin
  require 'delayed_job'
rescue LoadError
end

if defined?(Delayed)
  module Delayed
    module Plugins
      class Opbeat < Delayed::Plugin
        callbacks do |lifecycle|
          lifecycle.around(:invoke_job) do |job, *args, &block|
            begin
              block.call(job, *args)
            rescue ::Opbeat::Error
              raise # don't report Opbeat errors
            rescue Exception => exception
              ::Opbeat.report exception
              raise
            end
          end
        end
      end
    end
  end

  Delayed::Worker.plugins << Delayed::Plugins::Opbeat
end
