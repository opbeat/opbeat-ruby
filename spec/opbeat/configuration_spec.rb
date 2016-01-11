require 'spec_helper'

module Opbeat
  RSpec.describe Configuration do

    it "has defaults" do
      conf = Configuration.new
      expect(conf.timeout).to be 100
    end

    it "can initialize with a hash" do
      conf = Configuration.new timeout: 1000
      expect(conf.timeout).to be 1000
    end

    it "yields itself to a given block" do
      conf = Configuration.new do |c|
        c.timeout = 1000
      end
      expect(conf.timeout).to be 1000
    end

    describe "#validate" do
      let(:auth_opts) { { app_id: 'x', organization_id: 'y', secret_token: 'z' } }
      it "is true when all auth options are set" do
        expect(Configuration.new(auth_opts).validate!).to be true
      end
      it "is true" do
        expect(Configuration.new(auth_opts).validate!).to be true
      end
      it "needs an app_id" do
        auth_opts.delete(:app_id)
        expect(Configuration.new(auth_opts).validate!).to be false
      end
      it "needs an organization_id" do
        auth_opts.delete(:organization_id)
        expect(Configuration.new(auth_opts).validate!).to be false
      end
      it "needs a secret token" do
        auth_opts.delete(:secret_token)
        expect(Configuration.new(auth_opts).validate!).to be false
      end
    end

  end
end
