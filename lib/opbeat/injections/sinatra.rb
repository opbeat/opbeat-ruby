module Opbeat
  module Injections
    module Sinatra
      class Injector
        def install
          ::Sinatra::Base.class_eval do
            alias dispatch_without_opb! dispatch!
            alias compile_template_with_opb compile_template

            def dispatch!(*args, &block)
              dispatch_without_opb!(*args, &block).tap do
                if route = env['sinatra.route']
                  Opbeat.transaction(nil).endpoint = route
                end
              end
            end

            def compile_template engine, data, opts, *args, &block
              case data
              when Symbol
                opts[:__opbeat_template_sig] = data.to_s
              else
                opts[:__opbeat_template_sig] = "Inline #{engine}"
              end

              compile_template_with_opb(engine, data, opts, *args, &block)
            end
          end
        end
      end
    end

    module Tilt
      class Injector
        KIND = 'template.view'

        def install
          ::Tilt::Template.class_eval do
            alias render_without_opb render

            def render(*args, &block)
              sig = options[:__opbeat_template_sig] || 'Unknown template'.freeze

              Opbeat.trace sig, KIND do
                render_without_opb(*args, &block)
              end
            end
          end
        end
      end
    end

    register 'Sinatra::Base', 'sinatra/base', Sinatra::Injector.new
    register 'Tilt::Template', 'tilt/template', Tilt::Injector.new
  end
end
