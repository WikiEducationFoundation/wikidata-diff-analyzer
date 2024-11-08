# frozen_string_literal: true

# spec/wikidata/diff/api_spec.rb

require './lib/wikidata/diff/api'
require 'mediawiki_api'
require 'rspec'

# Test case for the Api.get_revision_contents method
# The MediaWiki API responses may get truncated for large queries, causing the `revisions` property to be omitted.
# This is not because pages lack revisions, but rather due to response size limits imposed by the MediaWiki API.
# As a result, only a subset of the requested revisions is returned, making some pages appear to have no revisions.
# Example of a truncated response: {"pageid": 188280, "ns": 0, "title": "Q189784"}
# In contrast, a complete response includes: {"pageid": 54252, "ns": 0, "title": "Q52053", "revisions": [...]}
# To mitigate this issue temporarily, we've added a guard statement to skip pages without revisions.
# A proper solution will involve logic to handle truncated responses effectively.

RSpec.describe Api do
    describe '.get_revision_contents' do
      let(:revision_ids) do
        [
          # A batch of 25 revision IDs associated with course_id: 10023.
          # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=2266123021|2266341034|2266123060|2266123123|2266123148|2266123175|2266123210|2266123270|2266123325|2266123373|2266123418|2266341148|2266123442|2266123459|2266123479|2266123502|2266123529|2266123536|2266123548|2266123562|2266123568|2266341782|2266123581|2266123596|2266123602&rvslots=main&rvprop=content|ids|comment&format=json
          # This query exceeds the MediaWiki API's response size limit of 12,582,912 bytes, resulting in a truncated response.
          # The response includes a 'warnings' section and only a subset of requested revisions.
          # Warnings: "This result was truncated because it would otherwise be larger than the limit of 12,582,912 bytes."
          # This truncation causes pages (pageid: 18820 and 265881) to appear to lack the 'revisions' property.
          2266123021, 2266341034, 2266123060, 2266123123, 2266123148,
          2266123175, 2266123210, 2266123270, 2266123325, 2266123373,
          2266123418, 2266341148, 2266123442, 2266123459, 2266123479,
          2266123502, 2266123529, 2266123536, 2266123548, 2266123562,
          2266123568, 2266341782, 2266123581, 2266123596, 2266123602
        ]
      end

      it 'returns without raising an error and handles both cases where revisions are present or absent' do
        expect {
          Api.get_revision_contents(revision_ids)
        }.not_to raise_error
      end

      it 'returns a truncation warning if query exceeds response size limit' do
        API_URL = 'https://www.wikidata.org/w/api.php'
        client = MediawikiApi::Client.new(API_URL)

        response = Api.fetch_revision_data(client, revision_ids)

        expect(response.warnings)

        expect(response.warnings).to include("This result was truncated because it would otherwise be larger than the limit of 12,582,912 bytes.")
      end
    end
  end