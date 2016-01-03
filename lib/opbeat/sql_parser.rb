module Opbeat
  class SqlParser
    CACHE = {}
    TBL = "[^ ]+".freeze
    REGEXES = {
      /^SELECT .* FROM (#{TBL})/i => lambda { |m| "SELECT FROM #{m[1]}" },
      /^INSERT INTO (#{TBL})/i => lambda { |m| "INSERT INTO #{m[1]}" },
      /^UPDATE (#{TBL})/i => lambda { |m| "UPDATE #{m[1]}" },
      /^DELETE FROM (#{TBL})/i => lambda { |m| "DELETE FROM #{m[1]}" }
    }

    def initialize config
      @config = config
    end

    def signature_for sql
      return CACHE[sql] if CACHE[sql]

      REGEXES.find do |regex, sig|
        if match = sql.match(regex)
          break sig.call(match)
        end
      end
    end
  end
end
