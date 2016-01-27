require 'spec_helper'
require 'sinatra'

module Opbeat
  RSpec.describe "sinatra integration" do
    include Rack::Test::Methods

    def config
      @config ||= Opbeat::Configuration.new do |c|
        c.app_id = 'X'
        c.organization_id = 'Y'
        c.secret_token = 'Z'
        c.disable_worker = true
      end
    end

    around do |example|
      Opbeat.start! config
      example.call
      Opbeat.stop!
    end

    class TestApp < ::Sinatra::Base
      disable :show_exceptions
      use Opbeat::Middleware

      get '/' do
        "I am a template!"
      end
    end

    def app
      TestApp
    end

    it "wraps routes in transactions" do
      get '/'

      transaction = Opbeat::Client.inst.pending_transactions.last
      expect(transaction.endpoint).to eq 'GET /'
    end

  end
end
