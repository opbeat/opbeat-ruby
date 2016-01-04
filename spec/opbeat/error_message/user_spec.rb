require 'spec_helper'

module Opbeat
  RSpec.describe ErrorMessage::User do

    let(:config) { Configuration.new }

    class Controller
      def current_user
        Struct.new(:id, :email, :username).new(1, 'john@example.com', 'leroy')
      end
    end

    describe ".from_rack_env" do
      it "initializes from rack env" do
        env = Rack::MockRequest.env_for '/', {
          'action_controller.instance' => Controller.new
        }
        user = ErrorMessage::User.from_rack_env config, env

        expect(user.id).to be 1
        expect(user.email).to eq 'john@example.com'
        expect(user.username).to eq 'leroy'
      end
    end

  end
end
