require 'spec_helper'

module Opbeat
  describe Trace, mock_time: true do

    describe "#initialize" do
      it "has a timestamp" do
        trace = Trace.new nil, 'test'
        expect(trace.timestamp).to eq Time.now.utc.to_i
      end
    end

    describe "#start" do
      it "has a relative and absolute start time with a transaction" do
        transaction = Transaction.new(nil, 'Test')
        travel 400
        trace = transaction.trace 'test-1' do
          travel 100
          transaction.trace 'test-2' do |t|
            travel 100
            t
          end
        end

        expect(trace.signature).to eq 'test-2'
        expect(trace.relative_start).to eq 100_000_000
      end
    end

    describe "#done" do
      it "sets duration" do
        transaction = Transaction.new nil, 'Test'
        trace = Trace.new(transaction, 'test').start transaction.start_time
        travel 100
        trace.done

        expect(trace.duration).to eq 100_000_000
        expect(trace).to be_done
      end
    end

  end
end
