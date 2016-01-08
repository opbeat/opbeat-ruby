require 'spec_helper'

module Opbeat
  RSpec.describe Client do

    let(:config) { Configuration.new }

    describe ".start!" do
      it "set's up an instance and only one" do
        first_instance = Client.start! config
        expect(Client.inst).to_not be_nil
        expect(Client.start! config).to be first_instance
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

    context "with a running client", start: true do
      subject { Client.inst }

      describe "#transaction" do
        it "returns a new transaction and sets it as current" do
          transaction = subject.transaction 'Test'
          expect(transaction).to_not be_nil
          expect(subject.current_transaction).to be transaction
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
          subject.current_transaction = nil
        end

        it "ignores when outside transaction" do
          blk = Proc.new {}
          allow(blk).to receive(:call)
          subject.trace { blk.call }
          expect(blk).to have_received(:call)
        end
      end

      describe "#submit_transaction" do
        it "doesn't send right away" do
          transaction = Transaction.new('Test', 'test')

          subject.submit_transaction transaction

          expect(subject.queue.length).to be 0
          expect(WebMock).to_not have_requested(:post, %r{/transactions/$})
        end

        it "sends if it's long enough ago that we sent last" do
          transaction = Transaction.new('Test', 'test')
          subject.instance_variable_set :@last_sent_transactions, Time.now - 61

          subject.submit_transaction transaction

          expect(subject.queue.length).to be 1
          expect(subject.queue.pop).to be_a Worker::PostRequest
        end
      end

      describe "#report" do
        it "builds and posts an exception" do
          exception = Exception.new('BOOM')

          subject.report exception

          expect(subject.queue.length).to be 1
          expect(subject.queue.pop).to be_a Worker::PostRequest
        end

        it "skips nil exceptions" do
          subject.report nil
          expect(WebMock).to_not have_requested(:post, %r{/errors/$})
        end
      end

      describe "#capture" do
        it "captures exceptions and sends them off then raises them again" do
          exception = Exception.new("BOOM")

          expect do
            subject.capture do
              raise exception
            end
          end.to raise_exception(Exception)

          expect(subject.queue.length).to be 1
          expect(subject.queue.pop).to be_a Worker::PostRequest
        end
      end

      describe "#release" do
        it "notifies Opbeat of a release" do
          release = { rev: "abc123", status: 'completed' }

          subject.release release

          expect(subject.queue.length).to be 1
          expect(subject.queue.pop).to be_a Worker::PostRequest
        end

        it "may send inline" do
          release = { rev: "abc123", status: 'completed' }

          subject.release release, inline: true

          expect(WebMock).to have_requested(:post, %r{/releases/$}).with(body: release)
        end
      end

    end
  end
end
