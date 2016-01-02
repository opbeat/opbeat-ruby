module Opbeat
  module Normalizers
    module ActiveRecord
      class SQL < Normalizer
        register 'sql.active_record'
        KIND = 'db.sql'.freeze

        def initialize *args
          super(*args)
          @sql_parser = SqlParser.new config
        end

        def normalize transaction, name, payload
          if %w{SCHEMA CACHE}.include? payload[:name]
            return :skip
          end

          signature = signature_for(payload[:sql]) || payload[:name] || "SQL".freeze

          [signature, KIND, { sql: payload[:sql] }]
        end

        private

        def signature_for sql
          @sql_parser.signature_for(sql)
        end
      end
    end
  end

  class SqlParser
    CACHE = {}
    REGEXES = {
      /^SELECT (\*|[a-z,\s]+) FROM ([^\s]+)/i => lambda { |m| "SELECT FROM #{m[2]}" },
      /^INSERT INTO ([\w"']+)/i => lambda { |m| "INSERT INTO #{m[1]}" }
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
