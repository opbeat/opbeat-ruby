require 'opbeat'
require 'rails'

module Opbeat
  class Railtie < Rails::Railtie

    config.opbeat = ActiveSupport::OrderedOptions.new
    config.opbeat.enabled_environments = Configuration::DEFAULTS[:enabled_environments]

    initializer "opbeat.configure" do |app|
      config = Configuration.new app.config.opbeat do |conf|
        # Rails specifics
        conf.logger = Rails.logger
        conf.view_paths = app.config.paths['app/views'].existent
      end

      if !config.enabled_environments.include?(Rails.env)
        # :nocov:
        Rails.logger.info "** [Opbeat] Not running in #{Rails.env} mode"
        # :nocov:
      elsif !Opbeat.start!(config)
        # :nocov:
        Rails.logger.info "** [Opbeat] Failed to start"
        # :nocov:
      else
        Rails.logger.info "** [Opbeat] Client running"
        app.config.middleware.insert 0, Middleware, config: config
      end
    end

    config.after_initialize do
      if defined?(ActionDispatch::DebugExceptions)
        require 'opbeat/integration/rails/inject_exceptions_catcher'
        ActionDispatch::DebugExceptions.send(
          :include, Opbeat::Integration::Rails::InjectExceptionsCatcher)
      end
    end

    # :nocov:
    rake_tasks do
      require 'opbeat/tasks'
    end
    # :nocov:

  end
end
