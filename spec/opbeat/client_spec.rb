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

          expect(WebMock).to have_requested(:post, %r{/errors/$}).with({
            body: /{"message":"Exception: BOOM"/
          })
        end
      end

      describe "#release" do
        it "notifies Opbeat of a release" do
          release = { rev: "abc123", status: 'completed' }

          subject.release release

          expect(WebMock).to have_requested(:post, %r{/releases/$}).with({
            body: '{"rev":"abc123","status":"completed"}'
          })
        end
      end

    end
  end
end
