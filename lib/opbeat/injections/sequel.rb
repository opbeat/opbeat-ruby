module Opbeat
  module Injections
    module Sequel
      class Injector
        def self.sql_parser
          @sql_parser ||= SqlSummarizer.new(nil)
        end

        def install
          require 'sequel/database/logging'

          ::Sequel::Database.class_eval do
            alias log_yield_without_opb log_yield

            def log_yield sql, args = nil, &block
              log_yield_without_opb(sql, *args) do
                sig = Opbeat::Injections::Sequel::Injector.sql_parser.signature_for(sql)
                Opbeat.trace(sig, 'sql.sequel', sql: sql) do
                  block.call
                end
              end
            end
          end
        end
      end
    end

    register 'Sequel', 'sequel', Sequel::Injector.new
  end
end
