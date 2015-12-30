begin
  require 'resque'
rescue LoadError
end

if defined? Resque
  module Opbeat
    module Integration
      class Resque < Resque::Failure::Base
        def save
          Opbeat.report exception
        end
      end
    end
  end
end
