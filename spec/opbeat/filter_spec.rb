require 'spec_helper'

module Opbeat
  RSpec.describe Filter do
    let(:config) do 
      Configuration.new filter_parameters: [/password/, 'pwd', :_secret, :int_secret, 'non_existing']
    end

    subject do
      Filter.new config
    end

    describe "#apply" do
      it "filters a string" do
        data = "password=SECRET&foo=bar&_secret=abc&pwd=de1&int_secret=123"
        filtered_data = "password=[FILTERED]&foo=bar&_secret=[FILTERED]&pwd=[FILTERED]&int_secret=[FILTERED]"
        expect(subject.apply data).to eq filtered_data
      end

      it "filters a hash" do
        data = { password: 'SECRET', foo: :bar, _secret: 'abc', pwd: 'de1', int_secret: 123 }
        filtered_data = { password: '[FILTERED]', 
                          foo: :bar, 
                          _secret: '[FILTERED]', 
                          pwd: '[FILTERED]', 
                          int_secret: '[FILTERED]'}
        expect(subject.apply data).to eq filtered_data
      end
    end
  end
end
