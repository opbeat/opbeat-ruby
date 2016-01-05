require 'spec_helper'

module Opbeat
  RSpec.describe Util::Inspector, start: true, mock_time: true do

    it "doesn't explode" do
      transaction = Opbeat.transaction 'Test' do
        travel 0.1
        Opbeat.trace 'test' do
          travel 0.1
        end
        travel 0.1
      end

      expect { Util::Inspector.new.transaction(transaction) }.to_not raise_error
    end

  end
end
