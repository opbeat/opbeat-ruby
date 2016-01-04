module Opbeat
  class ErrorMessage
    class Exception < Struct.new(:type, :value, :module)
      def self.from exception
        new exception.class.to_s, exception.message,
          exception.class.to_s.split('::')[0...-1].join('::')
      end
    end
  end
end
