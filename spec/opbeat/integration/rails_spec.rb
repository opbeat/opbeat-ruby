require 'spec_helper'

require 'rails'
require 'action_controller/railtie'
require 'opbeat/integration/railtie'

describe 'Rails integration' do
  include Rack::Test::Methods

  def boot
    TinderButForHotDogs.initialize!
    TinderButForHotDogs.routes.draw do
      resources :users
    end
  end

  before :all do
    class TinderButForHotDogs < ::Rails::Application
      config.secret_key_base = '6LXCXKANDLAcK7U_xknVsyZNEEgop2ovYcjnVV_fFiI'

      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::DEBUG

      config.eager_load = false

      config.opbeat.app_id = 'APP_ID'
      config.opbeat.organization_id = 'ORGANIZATION_ID'
      config.opbeat.secret_token = 'SECRET_TOKEN'
    end

    class UsersController < ActionController::Base
      def index
        render text: 'HOT DOGS!'
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
  end

  it "doesn't explode" do
    get '/users'
  end

  it "adds an exception handler and handles exceptions" do
    get '/404'

    expect(WebMock).to have_requested(:post, %r{/errors/$}).with({
      body: %r{ActionController::RoutingError.*404}
    })
  end

  it "traces actions and enqueues transaction" do
    get '/users'

    expect(Opbeat::Client.inst.queue.length).to be 1
  end
end
