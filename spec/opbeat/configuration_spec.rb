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

  end
end
