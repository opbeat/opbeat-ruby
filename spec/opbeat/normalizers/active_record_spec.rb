require 'spec_helper'

module Opbeat
  RSpec.describe Normalizers::ActionView do

    let(:config) { Configuration.new view_paths: ['/var/www/app/views'] }
    let(:normalizers) { Normalizers.build config }

    describe Normalizers::ActiveRecord::SQL do
      subject { normalizers.normalizer_for 'sql.active_record' }

      it "registers" do
        expect(subject).to be_a Normalizers::ActiveRecord::SQL
      end

      describe "#normalize" do
        it "skips SCHEMA queries" do
          expect(normalize(name: 'SCHEMA')).to be :skip
        end

        it "skips CACHE queries" do
          expect(normalize(name: 'CACHE', sql: 'select * from tables')).to be :skip
        end

        it "normalizes SELECT queries" do
          signature, kind, extra = normalize(name: 'Users load', sql: 'select * from "hotdogs" where id = $1')
          expect(signature).to eq 'SELECT FROM "hotdogs"'
          expect(kind).to eq 'db.sql'
          expect(extra).to eq sql: 'select * from "hotdogs" where id = $1'
        end

        it "normalizes INSERT queries" do
          sig, _, _ = normalize(name: 'Users create',
                                sql: 'insert into "hotdogs" (kind, topping) values ($1, $2)')
          expect(sig).to eq 'INSERT INTO "hotdogs"'
        end

        def normalize payload
          subject.normalize nil, 'sql.active_record', payload
        end
      end
    end

  end
end
