module Opbeat
  class Configuration
    DEFAULTS = {
      server: "https://intake.opbeat.com",
      context_lines: 3,
      enabled_environments: %w{development production},
      environment: ENV['RACK_ENV'] || ENV['RAILS_ENV'],
      excluded_exceptions: [],
      timeout: 100,
      open_timeout: 100,
      backoff_multiplier: 2,
      use_ssl: true,
      current_user_method: :current_user,
      async: false,
      filter_parameters: [/(authorization|password|passwd|secret)/i]
    }.freeze

    attr_accessor :server
    attr_accessor :secret_token
    attr_accessor :organization_id
    attr_accessor :app_id
    attr_accessor :logger
    attr_accessor :context_lines
    attr_accessor :enabled_environments
    attr_accessor :excluded_exceptions
    attr_accessor :filter_parameters
    attr_accessor :timeout
    attr_accessor :open_timeout
    attr_accessor :backoff_multiplier
    attr_accessor :use_ssl
    attr_accessor :current_user_method
    attr_accessor :environment
    attr_accessor :async
    attr_accessor :view_paths

    def initialize opts = {}
      DEFAULTS.merge(opts).each do |k, v|
        self.send("#{k}=", v)
      end

      if block_given?
        yield self
      end
    end
  end
end
