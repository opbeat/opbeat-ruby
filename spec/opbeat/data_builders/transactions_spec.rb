require 'spec_helper'

module Opbeat
  module DataBuilders
    RSpec.describe Transactions, mock_time: true do

      describe "#build" do
        subject do
          DataBuilders::Transactions.new Configuration.new
        end

        it "combines transactions by result" do
          transaction1 = Transaction.new(nil, 'endpoint', 'special.kind')
          transaction2 = Transaction.new(nil, 'endpoint', 'special.kind')
          transaction3 = Transaction.new(nil, 'endpoint', 'special.kind')
          travel 0.1
          transaction1.done 200
          transaction2.done 200
          transaction3.done 500

          transactions = [transaction1, transaction2, transaction3]

          result = subject.build transactions
          expect(result[:transactions].length).to be 2
          expect(result[:transactions].map { |t| t[:result] }).to eq [200, 500]

          expect(result[:traces].length). to be 1
          expect(result[:traces][0][:durations].length).to be 3
        end
      end

    end

  end
end
