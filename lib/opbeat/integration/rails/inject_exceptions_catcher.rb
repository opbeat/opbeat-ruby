module Opbeat
  module Integration
    module Rails
      module InjectExceptionsCatcher
        def self.included(cls)
          cls.send(:alias_method, :render_exception_without_opbeat, :render_exception)
          cls.send(:alias_method, :render_exception, :render_exception_with_opbeat)
        end

        def render_exception_with_opbeat(env, exception)
          begin
            Opbeat.report(exception, rack_env: env) if Opbeat.started?
          rescue
            ::Rails::logger.error "** [Opbeat] Error capturing or sending exception #{$!}"
            ::Rails::logger.debug $!.backtrace.join("\n")
          end

          render_exception_without_opbeat(env, exception)
        end
      end
    end
  end
end

