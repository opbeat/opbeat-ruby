module Opbeat
  # @api private
  class Filter

    MASK = '[FILTERED]'.freeze

    def initialize config
      @config = config
      @params = rails_filters || config.filter_parameters
    end

    attr_reader :config

    def apply data, opts = {}
      case data
      when String
        apply_to_string data, opts = {}
      when Hash
        apply_to_hash data
      end
    end

    def apply_to_string str, opts = {}
      sep = opts[:separator] || '&'.freeze
      kv_sep = opts[:kv_separator] || '='.freeze

      str.split(sep).map do |kv|
        key, value = kv.split(kv_sep)
        [key, kv_sep, sanitize(key, value)].join
      end.join(sep)
    end

    def apply_to_hash hsh
      hsh.inject({}) do |filtered, kv|
        key, value = kv
        filtered[key] = sanitize(key, value)
        filtered
      end
    end

    def sanitize key, value
      return value unless value.is_a?(String)

      if should_filter?(key)
        return MASK
      end

      value
    end

    private

    def should_filter? key
      @params.any? do |param|
        case param
        when String
          key.to_s == param.to_s
        when Regexp
          param.match(key)
        end
      end
    end

    def rails_filters
      if defined?(::Rails) && Rails.application
        if filters = ::Rails.application.config.filter_parameters
          filters.any? ? filters : nil
        end
      end
    end

  end
end
