# frozen_string_literal: true
# spec/wikidata/diff/analyzer_spec.rb

require './lib/wikidata/diff/analyzer'
require 'rspec'

# testcase testing get_revision_content
# https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=123456&rvslots=main&rvprop=content&format=json
# only works with a valid revision id
# only works having one revision object
RSpec.describe Wikidata::Diff::Analyzer do
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

# testcases for claim count
RSpec.describe Wikidata::Diff::Analyzer do
  describe '.count_claims' do
    it 'returns the number of claims in the revision content' do
      revision_id = 1234567890
      api_url = 'https://www.wikidata.org/w/api.php'
    
      client = instance_double(MediawikiApi::Client)
      response = instance_double(MediawikiApi::Response)
      allow(MediawikiApi::Client).to receive(:new).with(api_url).and_return(client)
      allow(client).to receive(:action).with(
        'query',
        prop: 'revisions',
        revids: revision_id,
        rvslots: 'main',
        rvprop: 'content',
        format: 'json'
      ).and_return(response)
    
      page_id = '123'
      revisions = [
        {
          'slots' => {
            'main' => {
                '*' => '{"claims":{"P31":[{"mainsnak":{"snaktype":"value","property":"P31","hash":"ad7d38a03cdd40cdc373de0dc4e7b7fcbccb31d9","datavalue":{"value":{"entity-type":"item","numeric-id":5,"id":"Q5"},"type":"wikibase-entityid"}},"type":"statement","id":"Q111269579$480c779b-4c0e-f9a8-f670-a92ecc122c22","rank":"normal"}]}}'
            }
          }
        }
      ]
      allow(response).to receive(:data).and_return({
        'pages' => {
          page_id => {
            'revisions' => revisions
          }
        }
      })
    
      content = Wikidata::Diff::Analyzer.get_revision_content(revision_id)
      expect(Wikidata::Diff::Analyzer.count_claims(content)).to eq(1)
    end

    it 'returns 0 if the revision content has no claims' do
      content = {
        'foo' => 'bar'
      }
      expect(Wikidata::Diff::Analyzer.count_claims(content)).to eq(0)
    end
  end
end

# test cases for count_references_recursive
RSpec.describe '.count_references' do
  it 'returns the number of references in the revision content' do
    revision_id = 1234567890
    api_url = 'https://www.wikidata.org/w/api.php'

    client = instance_double(MediawikiApi::Client)
    response = instance_double(MediawikiApi::Response)
    allow(MediawikiApi::Client).to receive(:new).with(api_url).and_return(client)
    allow(client).to receive(:action).with(
      'query',
      prop: 'revisions',
      revids: revision_id,
      rvslots: 'main',
      rvprop: 'content',
      format: 'json'
    ).and_return(response)

    page_id = '123'
    revisions = [
      {
        'slots' => {
          'main' => {
            '*' => '{"claims":{"P31":[{"mainsnak":{"snaktype":"value","property":"P31","hash":"ad7d38a03cdd40cdc373de0dc4e7b7fcbccb31d9","datavalue":{"value":{"entity-type":"item","numeric-id":5,"id":"Q5"},"type":"wikibase-entityid"}},"type":"statement","id":"Q111269579$480c779b-4c0e-f9a8-f670-a92ecc122c22","rank":"normal","references":[{"hash":"d8d7d6d5d4d3d2d1d0","snaks":{"P248":[{"snaktype":"value","property":"P248","hash":"a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0","datavalue":{"value":{"entity-type":"item","numeric-id":36906466,"id":"Q36906466"},"type":"wikibase-entityid"}}]},"snaks-order":["P248"]}]}]}}'
          }
        }
      }
    ]
    allow(response).to receive(:data).and_return({
      'pages' => {
        page_id => {
          'revisions' => revisions
        }
      }
    })

    content = Wikidata::Diff::Analyzer.get_revision_content(revision_id)
    expect(Wikidata::Diff::Analyzer.count_references_recursive(content)).to eq(1)
  end
end

# test cases for count_references_recursive when references count is zero
RSpec.describe '.count_references' do
  it 'returns the number of references in the revision content' do
    revision_id = 1234567890
    api_url = 'https://www.wikidata.org/w/api.php'

    client = instance_double(MediawikiApi::Client)
    response = instance_double(MediawikiApi::Response)
    allow(MediawikiApi::Client).to receive(:new).with(api_url).and_return(client)
    allow(client).to receive(:action).with(
      'query',
      prop: 'revisions',
      revids: revision_id,
      rvslots: 'main',
      rvprop: 'content',
      format: 'json'
    ).and_return(response)

    page_id = '123'
    revisions = [
      {
        'slots' => {
          'main' => {
            '*' => '{"claims":{}}'
          }
        }
      }
    ]
    allow(response).to receive(:data).and_return({
      'pages' => {
        page_id => {
          'revisions' => revisions
        }
      }
    })

    content = Wikidata::Diff::Analyzer.get_revision_content(revision_id)
    expect(Wikidata::Diff::Analyzer.count_references_recursive(content)).to eq(0)
  end
end

