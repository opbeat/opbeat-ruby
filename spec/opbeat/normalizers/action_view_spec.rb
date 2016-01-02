require 'spec_helper'

module Opbeat
  RSpec.describe Normalizers::ActionView do

    let(:config) { Configuration.new view_paths: ['/var/www/app/views'] }
    let(:normalizers) { Normalizers.build config }

    shared_examples_for :a_render_normalizer do |key|
      describe "#normalize" do
        it "normalizes an unknown template" do
          expect(normalize key, {}).to eq ['Unknown template', described_class.const_get(:KIND), nil]
        end

        it "returns a local template" do
          path = 'somewhere/local.html.erb'
          expect(normalize(key, identifier: path)[0]).to eq 'somewhere/local.html.erb'
        end

        it "looks up a template in config.view_paths" do
          path = '/var/www/app/views/users/index.html.erb'
          expect(normalize(key, identifier: path)[0]).to eq 'users/index.html.erb'
        end

        it "truncates gem path" do
          path = Gem.path[0] + '/some/template.html.erb'
          expect(normalize(key, identifier: path)[0]).to eq '$GEM_PATH/some/template.html.erb'
        end

        it "returns absolute if not found in known dirs" do
          path = '/somewhere/else.html.erb'
          expect(normalize(key, identifier: path)[0]).to eq 'Absolute path'
        end

        def normalize key, payload
          subject.normalize nil, key, payload
        end
      end
    end

    describe Normalizers::ActionView::RenderTemplate do
      subject do
        normalizers.normalizer_for 'render_template.action_view'
      end

      it "registers" do
        expect(subject).to be_a Normalizers::ActionView::RenderTemplate
      end

      it_should_behave_like :a_render_normalizer
    end

    describe Normalizers::ActionView::RenderPartial do
      subject do
        normalizers.normalizer_for 'render_partial.action_view'
      end

      it "registers" do
        expect(subject).to be_a Normalizers::ActionView::RenderPartial
      end

      it_should_behave_like :a_render_normalizer
    end

    describe Normalizers::ActionView::RenderCollection do
      subject do
        normalizers.normalizer_for 'render_collection.action_view'
      end

      it "registers" do
        expect(subject).to be_a Normalizers::ActionView::RenderCollection
      end

      it_should_behave_like :a_render_normalizer
    end
  end
end
