# frozen_string_literal: true
# spec/wikidata/diff/analyzer_spec.rb

require './lib/wikidata/diff/analyzer'

# unit test
# uses a mock response saved in the spec/json_test directory

RSpec.describe Wikidata::Diff::Analyzer do
  describe '.get_revision_item_json' do
    let(:item_id) { 'Q42' }  # Item ID of "Douglas Adams"
    let(:revision_id) { '123456789' }  # Revision ID of the specific revision
    let(:expected_json) do
      {
        'slots' => {
          'main' => {
            '*' => '{"type":"item","id":"Q42","labels":{"en":{"language":"en","value":"Douglas Adams"}}}',
            'contentformat' => 'application/json',
            'contentmodel' => 'wikibase-item'
          }
        }
      }
    end


    before do
      allow(URI).to receive(:open).and_return(File.open('spec/json_test/get_revision_response.json'))
    end

    it 'returns the JSON representation of the item for a specific revision' do
      actual_json = described_class.get_revision_item_json(item_id, revision_id)
      expect(actual_json).to eq(expected_json)
      puts "Actual JSON: #{actual_json}"
    end
  end
end

# integration test
# makes a real API request
RSpec.describe Wikidata::Diff::Analyzer do
  describe '.get_revision_item_json' do
    let(:item_id) { 'Q42' }  # Item ID of "Douglas Adams"
    let(:revision_id) { '123456789' }  # Revision ID of the specific revision
  
    it 'makes a real API request and returns the JSON representation of the item for a specific revision' do
      actual_json = described_class.get_revision_item_json(item_id, revision_id)
      # Perform assertions on the actual JSON response
      expect(actual_json).to have_key('slots')
      expect(actual_json['slots']['main']).to have_key('*')
      # ... add more assertions as needed
      puts "Actual JSON: #{actual_json}"
    end
  end
end
