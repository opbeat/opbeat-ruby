require 'spec_helper'

module Opbeat
  describe HttpClient do

    let(:configuration) do
      Configuration.new do |c|
        c.secret_token = 'TOKEN'
        c.organization_id = 'ORG'
        c.app_id = 'APP'
      end
    end
    let(:http_client) do
      HttpClient.new(configuration)
    end

    describe "#post" do
      let(:data) { { message: "BEEF" } }

      subject do
        http_client.post "/events/", data
      end

      it "makes a post request" do
        subject

        expect(WebMock).to have_requested(:post, %r{/events/$}).with({
          body: data,
          headers: {
            "Authorization" => 'Bearer TOKEN',
            "Content-Type" => 'application/json',
            "Content-Length" => data.to_json.bytesize,
            "User-Agent" => HttpClient::USER_AGENT
          }
        })
      end

      it "doesn't post when state is failed" do
        http_client.state.fail!
        subject
        expect(WebMock).to_not have_requested(:any, /.*/)
      end

      it "raises when server returns error" do
        stub_request(:post, /.*/).and_return(status: 500)
        expect { subject }.to raise_error(Error)
      end
    end

    describe "#state" do
      subject { http_client.state }

      it "should try" do
        expect(subject.should_try?).to be true
      end

      it "shouldn't try when state is failed" do
        subject.fail!
        expect(subject.should_try?).to be false
      end
    end

  end
end
