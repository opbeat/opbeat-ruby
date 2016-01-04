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

          expect(subject.build transactions).to eq({
            transactions: [{
              transaction: 'endpoint',
              kind: 'special.kind',
              result: 200,
              timestamp: 694220400,
              durations: [100.0, 100.0]
            }, {
              transaction: 'endpoint',
              result: 500,
              kind: 'special.kind',
              timestamp: 694220400,
              durations: [100.0]
            }],
            traces: [{
              transaction: 'endpoint',
              signature: 'endpoint',
              durations: [[100.0, 100.0], [100.0, 100.0], [100.0, 100.0]],
              start_time: 0.0,
              kind: 'transaction',
              timestamp: 694220400,
              parents: [],
              extra: {}
            }]
          })
        end
      end

    end

  end
end
