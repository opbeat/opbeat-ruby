module Opbeat
  module Normalizers
    module ActiveRecord
      class SQL < Normalizer
        register 'sql.active_record'
        KIND = 'db.sql'.freeze
        SIG_REGEX = /^(\w+).*(FROM "\w+")/.freeze

        def normalize transaction, name, payload
          if %w{SCHEMA CACHE}.include? payload[:name]
            return :skip
          end

          signature = signature_for payload[:sql]

          [signature, KIND, { sql: payload[:sql] }]
        end

        private

        def signature_for sql
          if match = sql.match(SIG_REGEX)
            "#{match[1]} #{match[2]}"
          else
            sql
          end
        end
      end
    end
  end
end
