module Opbeat
  # @api private
  module Util
    def self.nearest_minute
      now = Time.now
      now - now.to_i % 60
    end
  end

  require 'opbeat/util/inspector'
end

if RUBY_VERSION.to_i <= 1
  class Struct
    def to_h
      Hash[self.each_pair.to_a]
    end
  end
end
