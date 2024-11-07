# frozen_string_literal: true

# spec/wikidata/diff/api_spec.rb

require './lib/wikidata/diff/api'
require 'rspec'

# Test case for the Api.get_revision_contents method
# Some API responses may include a `page` entry that does not have a 'revisions' property.
# Example: The course with course_id 10023, has 2 pages that do not have a 'revisions' property as seen below:
# API Response: {"pageid": 188280, "ns": 0, "title": "Q189784"}, {"pageid": 265881, "ns": 0, "title": "Q274897"}
# In contrast, pages with revisions have responses such as: 
# {"pageid": 54252, "ns": 0, "title": "Q52053", "revisions": [...]}

RSpec.describe Api do
    describe '.get_revision_contents' do
      let(:revision_ids) do
        [
          # A batch of 50 revision IDs associated with a course (course_id: 10023).
          # This batch includes pages (pageid: 18820 and 265881) known to lack the 'revisions' property.
          2266122608, 2266122618, 2266122626, 2266122646, 2266122666, 2266122683, 
          2266122709, 2266122730, 2266122739, 2266122747, 2266122763, 2266122777, 
          2266122783, 2266122790, 2266122808, 2266122817, 2266122829, 2266122850, 
          2266122880, 2266122931, 2266122949, 2266122973, 2266122994, 2266123011, 
          2266123017, 2266123021, 2266341034, 2266123060, 2266123123, 2266123148, 
          2266123175, 2266123210, 2266123270, 2266123325, 2266123373, 2266123418, 
          2266341148, 2266123442, 2266123459, 2266123479, 2266123502, 2266123529, 
          2266123536, 2266123548, 2266123562, 2266123568, 2266341782, 2266123581, 
          2266123596, 2266123602
        ]
      end
  
      it 'returns without raising an error when an API response has a page with no revisions.' do
        expect {
          Api.get_revision_contents(revision_ids)
        }.not_to raise_error
      end
    end
  end