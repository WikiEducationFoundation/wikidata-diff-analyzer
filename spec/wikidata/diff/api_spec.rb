# frozen_string_literal: true

# spec/wikidata/diff/api_spec.rb

require './lib/wikidata/diff/api'
require 'rspec'

RSpec.describe Api do
    describe '.get_revision_contents' do
      let(:revision_ids) do
        [
          2266123021, 2266341034, 2266123060, 2266123123, 2266123148,
          2266123175, 2266123210, 2266123270, 2266123325, 2266123373,
          2266123418, 2266341148, 2266123442, 2266123459, 2266123479,
          2266123502, 2266123529, 2266123536, 2266123548, 2266123562,
          2266123568, 2266341782, 2266123581, 2266123596, 2266123602
        ]
      end

      it 'returns without raising an error and parses all revision ids passed into it' do
        @result = Api.get_revision_contents(revision_ids)
        expect {@result}.not_to raise_error
  
        expect(@result).to be_a(Hash)

        expect(@result.size).to eq(25)

      end

      it 'returns a truncation warning if query exceeds response size limit' do
        result = Api.fetch_revision_data(revision_ids)
  
        if result['warnings']
          expect(result['warnings']['result']['*']).to include(
            "This result was truncated because it would otherwise be larger than the limit of 12,582,912 bytes.")
        else
          expect(result).not_to be_nil
        end
      end

  end
end