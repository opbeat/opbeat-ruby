module Opbeat
  # @api private
  class SqlSummarizer
    CACHE = {}
    TBL = "[^ ]+".freeze
    REGEXES = {
      /^SELECT .* FROM (#{TBL})/i => "SELECT FROM ".freeze,
      /^INSERT INTO (#{TBL})/i => "INSERT INTO ".freeze,
      /^UPDATE (#{TBL})/i => "UPDATE ".freeze,
      /^DELETE FROM (#{TBL})/i => "DELETE FROM ".freeze
    }.freeze

    def initialize config
      @config = config
    end

    def signature_for sql
      return CACHE[sql] if CACHE[sql]

      REGEXES.find do |regex, sig|
        if match = sql.match(regex)
          break sig + match[1]
        end
      end
    end
  end
end
