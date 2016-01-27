module Opbeat
  module Injections
    module Sinatra
      class Injector
        def install
          ::Sinatra::Base.class_eval do
            alias dispatch_without_opb! dispatch!

            def dispatch!(*args, &block)
              dispatch_without_opb!(*args, &block).tap do
                if route = env['sinatra.route']
                  Opbeat.transaction(nil).endpoint = route
                end
              end
            end
          end
        end
      end
    end

    register 'Sinatra::Base', 'sinatra/base', Sinatra::Injector.new
  end
end
