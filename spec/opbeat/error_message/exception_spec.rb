require 'spec_helper'

module Opbeat
  RSpec.describe ErrorMessage::Exception do

    class ::Thing
      class Error < StandardError
      end
    end

    describe ".from" do
      it "initializes an object from an actual exception" do
        exception = Thing::Error.new "BOOM"
        obj = ErrorMessage::Exception.from(exception)
        expect(obj.type).to eq "Thing::Error"
        expect(obj.value).to eq "BOOM"
        expect(obj.module).to eq "Thing"
      end
    end

  end
end
