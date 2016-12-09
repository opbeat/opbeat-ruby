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
        erb "I am an inline template!"
      end

      template :tmpl do
        "I am a template!"
      end

      get '/tmpl' do
        erb :tmpl
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

    it "traces templates" do
      get '/tmpl'

      transaction = Opbeat::Client.inst.pending_transactions.last
      expect(transaction.traces.last.signature).to eq 'tmpl'
    end

    it "traces inline templates" do
      get '/'

      transaction = Opbeat::Client.inst.pending_transactions.last
      expect(transaction.traces.last.signature).to eq 'Inline erb'
    end

  end


  RSpec.describe "sinatra integration without perfomance" do
    include Rack::Test::Methods

    def config
      @config ||= Opbeat::Configuration.new do |c|
        c.app_id = 'X'
        c.organization_id = 'Y'
        c.secret_token = 'Z'
        c.disable_worker = true
        c.disable_performance = true
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
        erb "I am an inline template!"
      end
    end

    def app
      TestApp
    end

    it "wraps routes in transactions" do
      get '/'
      expect(Opbeat::Client.inst.pending_transactions.last).to be_nil
    end

  end

end
