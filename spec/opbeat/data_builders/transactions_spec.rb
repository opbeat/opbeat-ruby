require 'spec_helper'

module Opbeat
  module DataBuilders
    RSpec.describe Transactions, mock_time: true, start_without_worker: true do

      describe "#build" do
        subject do
          transaction1 = Transaction.new(nil, 'endpoint', 'special.kind')
          transaction2 = Transaction.new(nil, 'endpoint', 'special.kind')
          transaction3 = Transaction.new(nil, 'endpoint', 'special.kind')
          travel 0.1
          transaction1.done 200
          transaction2.done 200
          transaction3.done 500

          transaction4 = Opbeat.transaction('endpoint', 'special.kind') do
            travel 0.1
            Opbeat.trace 'things' do
              travel 0.1
            end
            Opbeat.trace 'things' do
              travel 0.1
            end
          end.done(500)

          transactions = [transaction1, transaction2, transaction3, transaction4]

          DataBuilders::Transactions.new(Configuration.new).build transactions
        end

        it "combines transactions by result" do
          data = subject
          expect(data[:transactions].length).to be 2
          expect(data[:transactions].map { |t| t[:result] }).to eq [200, 500]
          expect(data[:transactions].map { |t| t[:durations] }.flatten).to eq [100.0, 100.0, 100.0, 300.0]
        end

        it "combines traces" do
          data = subject
          expect(data[:traces].length). to be 2
          expect(data[:traces].first[:durations].length).to be 4
          expect(data[:traces].last[:durations].flatten).to eq [100.0, 300.0, 100.0, 300.0]
          expect(data[:traces].last[:start_time].round).to eq 150
        end
      end

    end

  end
end
