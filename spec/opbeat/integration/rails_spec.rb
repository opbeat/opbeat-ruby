require 'spec_helper'

require 'rails'
require 'action_controller/railtie'
require 'opbeat/integration/railtie'

describe 'Rails integration' do
  include Rack::Test::Methods

  def boot
    TinderButForHotDogs.initialize!
    TinderButForHotDogs.routes.draw do
      get 'error', to: 'users#error'
      get 'json', to: 'users#other'
      root to: 'users#index'
    end
  end

  before :all do
    class TinderButForHotDogs < ::Rails::Application
      config.secret_key_base = '__secret_key_base'

      config.logger = Logger.new(nil)
      config.logger.level = Logger::DEBUG

      config.eager_load = false

      config.opbeat.app_id = 'APP_ID'
      config.opbeat.organization_id = 'ORGANIZATION_ID'
      config.opbeat.secret_token = 'SECRET_TOKEN'
      config.opbeat.disable_worker = true
    end

    class UsersController < ActionController::Base
      def index
        render text: 'HOT DOGS!'
      end

      def other
        json = Opbeat.trace('JSON.dump') { sleep 0.1; { result: :ok } }
        render json: json
      end

      def error
        raise Exception.new("NO KETCHUP!")
      end
    end

    boot
  end

  after :all do
    Object.send(:remove_const, :TinderButForHotDogs)
    Object.send(:remove_const, :UsersController)
    Rails.application = nil
    Opbeat.stop!
  end

  def app
    @app ||= Rails.application
  end

  before :each do
    Opbeat::Client.inst.queue.clear
    Opbeat::Client.inst.instance_variable_set :@pending_transactions, []
  end

  it "adds an exception handler and handles exceptions" do
    get '/error'

    expect(Opbeat::Client.inst.queue.length).to be 1
  end

  it "traces actions and enqueues transaction" do
    get '/'

    expect(Opbeat::Client.inst.pending_transactions.length).to be 1
  end

  it "logs when failing to report error" do
    allow(Opbeat::Client.inst).to receive(:report).and_raise
    allow(Rails.logger).to receive(:error)

    get '/404'

    expect(Rails.logger).to have_received(:error).with(/\*\* \[Opbeat\] Error capturing/)
  end
end
