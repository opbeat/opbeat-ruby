module Opbeat
  module Normalizers

    class Normalizer
      def self.register name
        Normalizers.register name, self
      end

      def initialize config
        @config = config
      end

      attr_reader :config
    end

    class Default < Normalizer
      def normalize transaction, name, payload
        :skip
      end
    end

    DEFAULT = Default.new nil

    def self.register name, cls
      (@registered ||= {})[name] = cls
    end

    def self.build config
      normalizers = @registered.reduce({}) do |coll, kv|
        name, cls = kv
        coll[name] = cls.new config
        coll
      end

      Container.new(normalizers)
    end

    class Container
      def initialize normalizers
        @normalizers = normalizers
      end

      def keys
        @normalizers.keys
      end

      def normalizer_for name
        @normalizers[name] || DEFAULT
      end

      def normalize transaction, name, payload
        normalizer_for(name).normalize transaction, name, payload
      end
    end

    %w{
      action_controller
      active_record
      action_view
    }.each do |f|
      require "opbeat/normalizers/#{f}"
    end
  end
end
