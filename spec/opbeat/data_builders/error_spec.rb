require 'spec_helper'

module Opbeat
  module DataBuilders
    RSpec.describe Error do

      let(:config) { Configuration.new }

      subject do
        Error.new config
      end

      def real_exception
        1 / 0
      rescue => e
        e
      end

      describe "#build" do
        it "builds an error dict from an exception" do
          error_message = ErrorMessage.from_exception config, real_exception
          expect(subject.build error_message).to match({
            message: String,
            timestamp: Integer,
            level: :error,
            logger: 'root',
            culprit: "opbeat/data_builders/error_spec.rb:14:in `/'",
            machine: nil,
            extra: nil,
            param_message: nil,
            exception: Hash,
            stacktrace: Hash
          })
        end
        it "converts to json just fine" do
          error_message = ErrorMessage.from_exception config, real_exception
          expect { JSON.dump subject.build(error_message) }.to_not raise_error
        end
      end

    end
  end
end
