module Opbeat
  # @api private
  module Logging
    PREFIX = "** [Opbeat] "

    def debug *args, &block
      config.logger.debug(log_message(*args, &block)) if has_logger?
    end

    def info *args, &block
      config.logger.info(log_message(*args, &block)) if has_logger?
    end

    def warn *args, &block
      config.logger.warn(log_message(*args, &block)) if has_logger?
    end

    def error *args, &block
      config.logger.error(log_message(*args, &block)) if has_logger?
    end

    def fatal *args, &block
      config.logger.fatal(log_message(*args, &block)) if has_logger?
    end

    private

    def has_logger?
      respond_to?(:config) && config && config.logger
    end

    def log_message *args, &block
      msg = block_given? && block.call || args.first
      "#{PREFIX}#{msg}"
    end
  end
end
