require 'spec_helper'

if defined?(Redis)
  RSpec.describe "Redis integration", start_without_worker: true do

    let(:redis) { Redis.new }

    describe "#call" do
      it "adds a trace to current transaction" do
        transaction = Opbeat.transaction 'Redis' do
          redis.lrange("some:where", 0, -1)
        end

        expect(transaction.traces.length).to be 2
        expect(transaction.traces.last.signature).to eq 'lrange'
      end
    end

  end
end
