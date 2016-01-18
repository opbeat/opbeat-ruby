require 'spec_helper'
require 'json'

RSpec.describe "JSON integration", start_without_worker: true do

  if false # turned off for now
    describe "#parse" do
      it "adds a trace to current transaction" do
        transaction = Opbeat.transaction 'JSON' do
          JSON.parse('[{"something":1}]')
        end.done(true)

        expect(transaction.traces.length).to be 2
        expect(transaction.traces.last.signature).to eq "JSON#parse"
      end
    end

    describe "#parse" do
      it "adds a trace to current transaction" do
        transaction = Opbeat.transaction 'JSON' do
          JSON.parse!('[{"something":1}]')
        end.done(true)

        expect(transaction.traces.length).to be 2
        expect(transaction.traces.last.signature).to eq "JSON#parse!"
      end
    end

    describe "#generate" do
      it "adds a trace to current transaction" do
        transaction = Opbeat.transaction 'JSON' do
          JSON.generate([{something: 1}])
        end.done(true)

        expect(transaction.traces.length).to be 2
        expect(transaction.traces.last.signature).to eq "JSON#generate"
      end
    end
  end

end
