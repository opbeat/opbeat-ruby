require 'spec_helper'
require 'opbeat'

module Opbeat
  describe Middleware do

    before { Opbeat.start! Configuration.new }
    after { Opbeat.stop! }

    it "surrounds the request in a transaction" do
      app = Middleware.new(lambda do |env|
        [200, {}, ['']]
      end)
      status, _, _ = app.call({})

      expect(status).to eq 200
      expect(Opbeat::Client.inst.queue.length).to be 1
      expect(Opbeat::Client.inst.current_transaction).to be_nil
    end

    it "submits on exceptions" do
      app = Middleware.new(lambda do |env|
        raise Exception, "BOOM"
      end)

      expect { app.call({}) }.to raise_error(Exception)
      expect(Opbeat::Client.inst.queue.length).to be 1
      expect(Opbeat::Client.inst.current_transaction).to be_nil

      expect(WebMock).to have_requested(:post, %r{/errors/$}).with({
        body: /{"message":"Exception: BOOM"/
      })
    end

  end
end
