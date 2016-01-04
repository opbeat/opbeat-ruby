module Opbeat
  module Logging
    PREFIX = "** [Opbeat] "

    module Methods
      %w{fatal error info debug}.each do |name|
        define_method name.to_sym do |*args, &block|
          return unless respond_to?(:config) && config && config.logger
          msg = block && block.call || args.first
          config.logger.send(name, "#{PREFIX}#{msg}")
        end
      end

      # Explicitly override Kernel.warn
      def warn *args, &block
        return unless respond_to?(:config) && config && config.logger
        msg = block_given? && block.call || args.first
        config.logger.warn("#{PREFIX}#{msg}")
      end
    end

    # Both at instance ...
    include Methods
    # and class level
    extend Methods
  end
end
