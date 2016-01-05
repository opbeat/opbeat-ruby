module Opbeat
  module DataBuilders
    class DataBuilder
      def initialize config
        @config = config
      end

      attr_reader :config
    end

    %w{
      transactions
      error
    }.each do |f|
      require "opbeat/data_builders/#{f}"
    end
  end
end
