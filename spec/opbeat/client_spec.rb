require 'spec_helper'

module Opbeat
  RSpec.describe Client do

    let(:config) { Configuration.new }
    subject { Client.new config }

    before do
      Client.stop! # clean up any booted instances
    end

    describe ".start!" do
      it "set's up an instance" do
        expect_any_instance_of(Subscriber).to receive(:register!)
        expect_any_instance_of(Client).to receive(:start_worker)

        Client.start! config

        expect(Client.inst).to_not be_nil
      end
    end

    describe ".stop!" do
      it "kills the instance" do
        Client.start! config
        expect(Client.inst).to receive(:kill_worker)
        expect(Client.inst).to receive(:unregister!)
        Client.stop!
        expect(Client.inst).to be_nil
      end
    end

    describe "#transaction" do
      it "returns a new transaction and sets it as current" do
        transaction = subject.transaction 'Test'
        expect(transaction).to_not be_nil
        expect(subject.current_transaction).to eq transaction
      end
      it "returns the current transaction if present" do
        transaction = subject.transaction 'Test'
        expect(subject.transaction 'Test').to eq transaction
      end
      context "with a block" do
        it "yields transaction" do
          blck = lambda { |*args| }
          allow(blck).to receive(:call)
          subject.transaction('Test') { |t| blck.(t) }
          expect(blck).to have_received(:call).with(Transaction)
        end
      end
    end

    describe "#trace" do
      it "delegates to current transaction" do
        subject.current_transaction = double('transaction', trace: true)
        subject.trace 1, 2, 3
        expect(subject.current_transaction).to have_received(:trace).with(1, 2, 3)
      end
    end

    describe "#enqueue" do
      it "adds to the queue" do
        subject.enqueue Transaction.new(subject, 'Test').done(200)
        expect(subject.queue.length).to be 1
      end
    end

    describe "#report" do
      it "builds and posts an exception" do
        exception = Exception.new('BOOM')

        subject.report exception

        expect(WebMock).to have_requested(:post, %r{/errors/$}).with({
          body: /{"message":"Exception: BOOM/
        })
      end
    end

  end
end
