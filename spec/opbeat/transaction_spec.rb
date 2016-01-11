require 'spec_helper'
require 'opbeat'

module Opbeat
  describe Transaction, mock_time: true do

    describe "#initialize" do
      it "has a root trace, timestamp and start time" do
        transaction = Transaction.new nil, 'Test'
        expect(transaction.traces.length).to be 1
        expect(transaction.timestamp).to eq Time.new(1992, 1, 1).to_i
        expect(transaction.start).to eq Time.now.to_f
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

        travel 0.1
        transaction.done(200)

        expect(transaction.result).to be 200
        expect(transaction.traces.first).to be_done
        expect(transaction.duration.round 4).to eq 100.0
      end
    end

    describe "#submit" do
      it "ends transaction and submits it to the client" do
        client = double('client', submit_transaction: true, :current_transaction= => true)
        transaction = Transaction.new client, 'Test'

        travel 0.1
        transaction.submit 200

        expect(transaction.result).to be 200
        expect(transaction).to be_done
        expect(client).to have_received(:current_transaction=)
        expect(client).to have_received(:submit_transaction).with transaction
      end
    end

    describe "#trace" do
      subject do
        transaction = Transaction.new nil, 'Test'

        travel 0.1

        transaction.trace 'test' do
          travel 0.1
        end

        transaction.done
      end
      it "creates a new trace" do
        expect(subject.traces.length).to be 2
      end
      it "has root as a parent" do
        expect(subject.traces.last.parents).to eq [subject.traces.first.signature]
      end
      it "has a duration" do
        expect(subject.traces.last.duration.round 4).to eq 100.0
      end
      it "has a relative start" do
        expect(subject.traces.last.relative_start.round 2).to eq 100.0
      end
      it "has a total duration" do
        expect(subject.duration.round 4).to eq 200.0
      end
    end

    describe "#endpoint=" do
      it "renames root trace signature when renaming transaction" do
        transaction = Transaction.new nil, 'Test'
        transaction.endpoint = 'tseT'
        expect(transaction.endpoint).to eq 'tseT'
        expect(transaction.traces.first.signature).to eq 'tseT'
      end
    end

  end
end
