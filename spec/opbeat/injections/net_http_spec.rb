require 'spec_helper'

require 'open-uri'

module Opbeat
  RSpec.describe 'net/http integration', start: true do

    it "is installed" do
      reg = Opbeat::Injections.installed['Net::HTTP']
      expect(reg).to_not be_nil
    end

    it "traces http calls" do
      Opbeat::Injections.installed['Net::HTTP'].install

      WebMock.stub_request :get, 'http://example.com:80'

      transaction = Opbeat.transaction 'Test'
      Net::HTTP.start('example.com') do |http|
        http.get '/'
      end

      expect(WebMock).to have_requested(:get, 'http://example.com')
      expect(transaction.traces.length).to be 2

      http_trace = transaction.traces.last
      expect(http_trace.signature).to eq 'HTTP/GET'
    end

  end
end
