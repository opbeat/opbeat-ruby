require 'spec_helper'

module Opbeat
  RSpec.describe Worker do

    let(:queue) { Queue.new }
    let(:config) { Configuration.new }

    subject do
      Worker.new config, queue, HttpClient.new(config)
    end

    describe "#run" do
      it "loops and sleeps" do
        expect(subject).to receive(:loop).and_yield
        expect(subject).to receive(:send_transactions)
        expect(subject).to receive(:sleep)
        subject.run
      end
    end

    describe "#send_transactions" do
      it "turns all the transaction in the queue into a combined req" do
        transaction = Transaction.new(nil, 'Test').done(200)
        queue << transaction

        subject.send_transactions

        expect(queue).to be_empty
        expect(WebMock).to have_requested(:post, %r{/transactions/$}).with({
          body: DataBuilders::Transactions.new(config).build([transaction])
        })
      end
    end

  end
end
