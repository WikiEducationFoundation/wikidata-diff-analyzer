# frozen_string_literal: true
# spec/wikidata/diff/analyzer_spec.rb

require './lib/wikidata/diff/analyzer'
require 'rspec'

# It is a testcase testing
# https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=123456&rvslots=main&rvprop=content&format=json
# only works with a valid revision id
# only works having one revision object
describe Wikidata::Diff::Analyzer do
  describe '.get_revision_content' do
    it 'returns the content of a revision' do
      content = Wikidata::Diff::Analyzer.get_revision_content(123456)
      # puts content.inspect
      expect(content).to be_a(Hash)
      expect(content['id']).to eq('Q1631')
      expect(content['labels']).to be_a(Hash), "Expected 'labels' to be a Hash, but got #{content['labels'].inspect}"
      expect(content['labels']['fr']['value']).to eq('Édith Piaf'), "Expected 'value' to be 'Édith Piaf', but got #{content['labels']['fr']['value'].inspect}"
      expect(content['descriptions']).to be_a(Hash), "Expected 'descriptions' to be a Hash, but got #{content['descriptions'].inspect}"
      expect(content['descriptions']['fr']['value']).to eq('Chanteuse française'), "Expected 'value' to be 'Chanteuse française', but got #{content['descriptions']['fr']['value'].inspect}"
      expect(content['aliases']).to be_a(Array), "Expected 'aliases' to be an Array, but got #{content['aliases'].inspect}"
      expect(content['claims']).to be_a(Array), "Expected 'claims' to be an Array, but got #{content['claims'].inspect}"
      expect(content['sitelinks']).to be_a(Hash), "Expected 'sitelinks' to be a Hash, but got #{content['sitelinks'].inspect}"
      expect(content['sitelinks']['frwiki']['title']).to eq('Édith Piaf'), "Expected 'title' to be 'Édith Piaf', but got #{content['sitelinks']['frwiki']['title'].inspect}"
    end
  end
end