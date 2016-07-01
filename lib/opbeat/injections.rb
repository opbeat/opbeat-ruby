require 'opbeat/util/constantize'

module Opbeat
  # @api private
  module Injections
    class Registration
      def initialize const_name, require_paths, injector
        @const_name = const_name
        @require_paths = Array(require_paths)
        @injector = injector
      end

      attr_reader :const_name, :require_paths, :injector

      def install
        injector.install
      end
    end

    def self.require_hooks
      @require_hooks ||= {}
    end

    def self.installed
      @installed ||= {}
    end

    def self.register(*args)
      registration = Registration.new(*args)

      if const_defined?(registration.const_name)
        installed[registration.const_name] = registration
        registration.install
      else
        register_require_hook registration
      end
    end

    def self.register_require_hook registration
      registration.require_paths.each do |path|
        require_hooks[path] = registration
      end
    end

    def self.hook_into name
      return unless registration = lookup(name)

      if const_defined?(registration.const_name)
        installed[registration.const_name] = registration
        registration.install

        registration.require_paths.each do |path|
          require_hooks.delete path
        end
      end
    end

    def self.lookup require_path
      require_hooks[require_path]
    end

    def self.const_defined? const_name
      const = Util.constantize(const_name) rescue nil
      !!const
    end
  end
end

# @api private
module ::Kernel
  alias require_without_op require

  def require name
    res = require_without_op name

    begin
      Opbeat::Injections.hook_into name
    rescue Exception
    end

    res
  end
end
