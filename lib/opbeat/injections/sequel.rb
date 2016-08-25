module Opbeat
  module Injections
    module Sequel
      class Injector
        KIND = 'db.sequel.sql'.freeze

        def self.sql_parser
          @sql_parser ||= SqlSummarizer.new(nil)
        end

        def install
          require 'sequel/database/logging'

          log_method = ::Sequel::Database.method_defined?(:log_connection_yield) ?
            'log_connection_yield' : 'log_yield'

          ::Sequel::Database.class_eval <<-end_eval
            alias #{log_method}_without_opb #{log_method}

            def #{log_method} sql, *args, &block
              #{log_method}_without_opb(sql, *args) do
                sig = Opbeat::Injections::Sequel::Injector.sql_parser.signature_for(sql)
                Opbeat.trace(sig, KIND, sql: sql) do
                  block.call
                end
              end
            end
          end_eval
        end
      end
    end

    register 'Sequel', 'sequel', Sequel::Injector.new
  end
end
