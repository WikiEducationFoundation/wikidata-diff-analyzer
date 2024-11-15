# frozen_string_literal: true

# spec/wikidata/diff/api_spec.rb

require './lib/wikidata/diff/api'
require 'rspec'

RSpec.describe Api do
  let(:revision_ids) do
    [
      2266123021, 2266341034, 2266123060, 2266123123, 2266123148,
      2266123175, 2266123210, 2266123270, 2266123325, 2266123373,
      2266123418, 2266341148, 2266123442, 2266123459, 2266123479,
      2266123502, 2266123529, 2266123536, 2266123548, 2266123562,
      2266123568, 2266341782, 2266123581, 2266123596, 2266123602
    ]
  end

  describe '.mediawiki_request' do
    it 'returns a truncation warning since query exceeds response size limit' do
      client = Api.api_client
      query = Api.get_query_parameters(revision_ids)
      
      response = Api.mediawiki_request(client, 'query', query)

      expect(response['warnings']).not_to be_nil
      expect(response['warnings']['result']['*']).to include(
        "This result was truncated because it would otherwise be larger than the limit of 12,582,912 bytes."
      )
    end
  end

  describe '.get_revision_contents' do
    it 'returns the correct result and handles the warning' do
      result = Api.get_revision_contents(revision_ids)
      
      expect { result }.not_to raise_error
      expect(result).to be_a(Hash)
      expect(result.size).to eq(25)
    end
  end
end