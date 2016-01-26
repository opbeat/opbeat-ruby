require 'spec_helper'
require 'opbeat'

module Opbeat
  describe Transaction, mock_time: true do

    describe "#initialize" do
      it "has a root trace, timestamp and start time" do
        transaction = Transaction.new nil, 'Test'
        expect(transaction.traces.length).to be 1
        expect(transaction.timestamp).to eq 694224000
        expect(transaction.start_time).to eq 694224000000000000
      end
    end

    describe "#release" do
      it "sets clients current transaction to nil" do
        client = Struct.new(:current_transaction).new(1)
        transaction = Transaction.new client, 'Test'
        transaction.release
        expect(client.current_transaction).to be_nil
      end
    end

    describe "#done" do
      it "it sets result, durations and ends root trace" do
        transaction = Transaction.new nil, 'Test'

        travel 100
        transaction.done(200)

        expect(transaction.result).to be 200
        expect(transaction.traces.first).to be_done
        expect(transaction.duration).to eq 100_000_000
      end
    end

    describe "#submit" do
      it "ends transaction and submits it to the client" do
        client = double('client', submit_transaction: true, :current_transaction= => true)
        transaction = Transaction.new client, 'Test'

        travel 100
        transaction.submit 200

        expect(transaction.result).to be 200
        expect(transaction).to be_done
        expect(client).to have_received(:current_transaction=)
        expect(client).to have_received(:submit_transaction).with transaction
      end
    end

    describe "#running_traces" do
      it "returns running traces" do
        transaction = Transaction.new nil, 'Test'

        transaction.trace 'test' do
          travel 100
        end

        running_trace = transaction.trace 'test2'
        travel 100

        expect(transaction.running_traces).to eq [transaction.root_trace, running_trace]
      end
    end

    describe "#trace" do
      subject do
        transaction = Transaction.new nil, 'Test'

        travel 100

        transaction.trace 'test' do
          travel 100
        end

        transaction.done
      end
      it "creates a new trace" do
        expect(subject.traces.length).to be 2
      end
      it "has root as a parent" do
        expect(subject.traces.last.parents).to eq [subject.traces.first]
      end
      it "has a duration" do
        expect(subject.traces.last.duration).to eq 100_000_000
      end
      it "has a relative start" do
        expect(subject.traces.last.relative_start).to eq 100_000_000
      end
      it "has a total duration" do
        expect(subject.duration).to eq 200_000_000
      end
    end

  end
end
