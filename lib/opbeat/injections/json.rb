module Opbeat
  module Injections
    module JSON
      class Injector
        def install
          ::JSON.class_eval do
            include TraceHelpers

            trace_class_method :parse, 'JSON#parse', 'json.parse'
            trace_class_method :parse!, 'JSON#parse!', 'json.parse'
            trace_class_method :generate, 'JSON#generate', 'json.generate'
          end
        end
      end
    end

    register 'JSON', 'json', JSON::Injector.new
  end
end
