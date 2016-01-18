module Opbeat
  module TraceHelpers
    module ClassMethods
      def trace_class_method method, signature, kind
        __trace_method_on(singleton_class, method, signature, kind)
      end

      private

      def __trace_method_on(klass, method, signature, kind)
        klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          alias :"__without_opb_#{method}" :"#{method}"

          def #{method}(*args, &block)
            Opbeat.trace "#{signature}", "#{kind}" do
              __without_opb_#{method}(*args, &block)
            end
          end
        RUBY
      end
    end

    def self.included(kls)
      kls.class_eval do
        extend ClassMethods
      end
    end
  end
end
