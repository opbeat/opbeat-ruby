require 'spec_helper'

module Opbeat
  RSpec.describe ErrorMessage::Stacktrace do

    def real_exception
      1 / 0
    rescue => e
      e
    end

    let(:config) { Configuration.new }
    let(:exception) { real_exception }

    describe ".from" do
      it "initializes from an exception" do
        stacktrace = ErrorMessage::Stacktrace.from config, exception
        expect(stacktrace.frames).to_not be_empty

        # so meta
        last_frame = stacktrace.frames.first
        expect(last_frame.filename).to eq "opbeat/error_message/stacktrace_spec.rb"
        expect(last_frame.lineno).to be 7
        expect(last_frame.abs_path).to_not be_nil
        expect(last_frame.function).to eq "/"
        expect(last_frame.vars).to be_nil

        expect(last_frame.pre_context.last).to match(/def real_exception/)
        expect(last_frame.context_line).to match(/1 \/ 0/)
        expect(last_frame.post_context.first).to match(/rescue/)
      end

      context "when context lines are off" do
        let(:config) { Configuration.new context_lines: nil }
        it "initializes too" do
          stacktrace = ErrorMessage::Stacktrace.from config, exception
          expect(stacktrace.frames).to_not be_empty

          last_frame = stacktrace.frames.last
          expect(last_frame.pre_context).to be_nil
          expect(last_frame.context_line).to be_nil
          expect(last_frame.post_context).to be_nil
        end
      end
    end

    describe "#to_h" do
      it "is a hash" do
        hsh = ErrorMessage::Stacktrace.from(config, exception).to_h
        expect(hsh).to be_a Hash
        expect(hsh.keys).to eq [:frames]
      end
    end

  end
end
