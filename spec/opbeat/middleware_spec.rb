require 'spec_helper'
require 'opbeat'

module Opbeat
  describe Middleware do

    before { Opbeat.start! Configuration.new }
    after { Opbeat.stop! }

    it "surrounds the request in a transaction" do
      transaction = double('transaction', release: true, submit: true)
      allow(Opbeat).to receive(:transaction)
        .with('Rack', 'app.rack.request') { transaction }

      app = Middleware.new(lambda do |env|
        [200, {}, ['']]
      end)
      status, _, _ = app.call({})

      expect(status).to eq 200
      expect(transaction).to have_received(:submit)
      expect(transaction).to have_received(:release)
    end

    it "submits on exceptions" do
      transaction = double('transaction', submit: true, release: true)
      allow(Opbeat).to receive(:transaction)
        .with('Rack', 'app.rack.request') { transaction }

      app = Middleware.new(lambda do |env|
        raise Exception, "BOOM"
      end)

      expect { app.call({}) }.to raise_error(Exception)
      expect(transaction).to have_received(:submit).with(500)
      expect(transaction).to have_received(:release)

      expect(WebMock).to have_requested(:post, %r{/errors/$}).with({
        body: /{"message":"Exception: BOOM"/
      })
    end

  end
end
