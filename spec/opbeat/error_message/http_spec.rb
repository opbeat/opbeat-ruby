require 'spec_helper'

module Opbeat
  RSpec.describe ErrorMessage::HTTP do

    describe ".from_rack_env" do
      it "initializes with a rack env" do
        env = Rack::MockRequest.env_for '/nested/path?a=1', {
          'HTTP_COOKIE' => 'user_id=1',
          'REMOTE_ADDR' => '1.2.3.4',
          'HTTP_USER_AGENT'  => 'test-agent 1.2/3',
          'HTTP_FOO' => 'bar'
        }
        http = ErrorMessage::HTTP.from_rack_env env

        expect(http.url).to eq 'http://example.org/nested/path'
        expect(http.method).to eq 'GET'
        expect(http.query_string).to eq 'a=1'
        expect(http.cookies).to eq('user_id=1')
        expect(http.remote_host).to eq '1.2.3.4'
        expect(http.http_host).to eq 'example.org:80'
        expect(http.user_agent).to eq 'test-agent 1.2/3'

        expect(http.headers).to eq({
          'Cookie' => 'user_id=1',
          'User-Agent' => 'test-agent 1.2/3',
          'Foo' => 'bar'
        })
        expect(http.env).to eq(env.select do |k,v|
          !k.match(/(^HTTP_|[a-z])/) # starting with HTTP_ or lower case
        end)
      end

      it "adds form data" do
        env = Rack::MockRequest.env_for '/', {
          'REQUEST_METHOD' => 'POST',
          input: 'thing=hotdog&accept=1'
        }
        http = ErrorMessage::HTTP.from_rack_env env

        expect(http.data).to eq({
          'thing' => 'hotdog',
          'accept' => '1'
        })
      end

      it "adds body" do
        env = Rack::MockRequest.env_for '/', {
          'REQUEST_METHOD' => 'POST',
          'CONTENT_TYPE' => 'application/json',
          input: { thing: 'hotdog' }.to_json
        }
        http = ErrorMessage::HTTP.from_rack_env env

        expect(http.data).to eq('{"thing":"hotdog"}')
      end
    end

  end
end
