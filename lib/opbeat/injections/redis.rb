module Opbeat
  module Injections
    module Redis
      class Injector
        def install
          ::Redis::Client.class_eval do
            alias call_without_opbeat call

            def call(command, &block)
              signature = command[0]

              Opbeat.trace signature.to_s, 'cache.redis'.freeze do
                call_without_opbeat(command, &block)
              end
            end
          end
        end
      end
    end

    register 'Redis', 'redis', Redis::Injector.new
  end
end
