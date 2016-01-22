module Opbeat
  # @api private
  module Util
    def self.nearest_minute
      now = Time.now
      now - now.to_i % 60
    end

    def self.nanos
      now = Time.now
      now.to_i * 1_000_000_000 + now.usec * 1_000
    end
  end

  require 'opbeat/util/inspector'
end

# TODO: Maybe move this some place more explicit as we're extending
# a pretty widely used class. Or maybe don't extend at all.
if RUBY_VERSION.to_i <= 1
  class Struct
    def to_h
      Hash[self.each_pair.to_a]
    end
  end
end
