require 'spec_helper'

module Opbeat
  RSpec.describe Normalizers::ActionController do

    let(:config) { Configuration.new }
    let(:normalizers) { Normalizers.build config }

    describe Normalizers::ActionController::ProcessAction do
      subject do
        normalizers.normalizer_for('process_action.action_controller')
      end

      it "registers" do
        expect(subject).to be_a Normalizers::ActionController::ProcessAction
      end

      describe "#normalize" do
        it "normalizes input and updates transaction" do
          transaction = Struct.new(:endpoint).new(nil)

          result = subject.normalize(transaction, 'process_action.action_controller', {
            controller: 'SomeController', action: 'index'
          })

          expect(transaction.endpoint).to eq 'SomeController#index'
          expect(result).to match ['SomeController#index', 'app.controller.action', nil]
        end
      end
    end
  end
end
