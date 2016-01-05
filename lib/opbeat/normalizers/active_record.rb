require 'opbeat/sql_parser'

module Opbeat
  module Normalizers
    module ActiveRecord
      class SQL < Normalizer
        register 'sql.active_record'

        def initialize *args
          super(*args)
          adapter = ::ActiveRecord::Base.connection.adapter_name.downcase rescue nil
          @kind = "db.#{adapter || 'unknown'}.sql".freeze
          @sql_parser = SqlParser.new config
        end

        def normalize transaction, name, payload
          if %w{SCHEMA CACHE}.include? payload[:name]
            return :skip
          end

          signature =
            signature_for(payload[:sql]) || # SELECT FROM "users"
            payload[:name] ||               # Users load
            "SQL".freeze

          [signature, @kind, { sql: payload[:sql] }]
        end

        private

        def signature_for sql
          @sql_parser.signature_for(sql)
        end
      end
    end
  end
end
