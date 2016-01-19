require 'opbeat/sql_summarizer'

module Opbeat
  module Normalizers
    module ActiveRecord
      class SQL < Normalizer
        register 'sql.active_record'

        def initialize *args
          super(*args)
          adapter = ::ActiveRecord::Base.connection.adapter_name.downcase rescue nil
          @kind = "db.#{adapter || 'unknown'}.sql".freeze
          @sql_parser = SqlSummarizer.new config
        end

        def normalize transaction, name, payload
          if %w{SCHEMA CACHE}.include? payload[:name]
            return :skip
          end

          signature =
            signature_for(payload[:sql]) || # SELECT FROM "users"
            payload[:name] ||               # Users load
            "SQL".freeze

          if signature == 'SELECT FROM "schema_migrations"'
            return :skip
          end

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
