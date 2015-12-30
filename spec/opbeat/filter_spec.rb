require 'spec_helper'

module Opbeat
  RSpec.describe Filter do
    let(:config) { Configuration.new filter_parameters: [/password/, 'passwd'] }

    subject do
      Filter.new config
    end

    describe "#apply" do
      it "filters a string" do
        filtered = subject.apply "password=SECRET&foo=bar"
        expect(filtered).to eq 'password=[FILTERED]&foo=bar'
      end

      it "filters a hash" do
        filtered = subject.apply({ passwd: 'SECRET' })
        expect(filtered).to eq({ passwd: '[FILTERED]' })
      end
    end
  end
end
