require 'opbeat'
require 'rails'

module Opbeat
  class Railtie < Rails::Railtie

    config.opbeat = ActiveSupport::OrderedOptions.new
    # bootstrap options with the defaults
    Configuration::DEFAULTS.each { |k,v| config.opbeat[k] = v }

    initializer "opbeat.configure" do |app|
      config = Configuration.new app.config.opbeat do |conf|
        conf.logger = Rails.logger
        conf.view_paths = app.config.paths['app/views'].existent
      end

      if config.enabled_environments.include?(Rails.env)
        if Opbeat.start!(config)
          app.config.middleware.insert 0, Middleware
          Rails.logger.info "** [Opbeat] Client running"
        else
          Rails.logger.info "** [Opbeat] Failed to start"
        end
      else
        Rails.logger.info "** [Opbeat] Disabled in #{Rails.env} environment"
      end
    end

    config.after_initialize do
      require 'opbeat/integration/rails/inject_exceptions_catcher'
      if defined?(ActionDispatch::DebugExceptions)
        ActionDispatch::DebugExceptions.send(
          :include, Opbeat::Integration::Rails::InjectExceptionsCatcher)
      elsif defined?(::ActionDispatch::ShowExceptions)
        ::ActionDispatch::ShowExceptions.send(
          :include, Opbeat::Integration::Rails::InjectExceptionsCatcher)
      end
    end

    rake_tasks do
      require 'opbeat/tasks'
    end

  end
end
