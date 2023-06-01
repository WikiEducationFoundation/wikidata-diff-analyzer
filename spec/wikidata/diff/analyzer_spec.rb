# frozen_string_literal: true
# spec/wikidata/diff/analyzer_spec.rb

require './lib/wikidata/diff/analyzer'
require 'rspec'

# testcases for get_revision_content

# Individual Revision Id: 123456
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=123456&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=123456
# this test case explores the structure of the JSON response to ensure that the content is being retrieved correctly
 RSpec.describe WikidataDiffAnalyzer do
  describe '.get_revision_content' do
    it 'returns the content of a revision' do
      content = WikidataDiffAnalyzer.get_revision_content(123456)
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

# testcases for claim count(Acutal API request)
# Individual Revision Id: 1596238100
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596238100

# parent id of the above revision id: 1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596236983&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596236983
RSpec.describe WikidataDiffAnalyzer do
  describe '.count_claims' do
    # this test case expects the claim count to be 11 because the revision content has 11 claims in the API request
    it 'returns the number of claims in the revision content' do
      revision_id = 1596238100
      content = WikidataDiffAnalyzer.get_revision_content(revision_id)
      expect(WikidataDiffAnalyzer.count_claims(content)).to eq(11)
    end

    it 'returns the number of claims in the revision content' do
      revision_id = 1596236983
      content = WikidataDiffAnalyzer.get_revision_content(revision_id)
      expect(WikidataDiffAnalyzer.count_claims(content)).to eq(10)
    end
  end
end

# testcases for claim count (sanity check, not Actual API request)
RSpec.describe 'count_claims' do
  it 'returns 0 when content is nil' do
    expect(WikidataDiffAnalyzer.count_claims(nil)).to eq(0)
  end

  it 'returns 0 when content is an empty hash' do
    expect(WikidataDiffAnalyzer.count_claims({})).to eq(0)
  end

  it 'returns 0 when content has no claims' do
    content = {
      'foo' => 'bar'
    }
    expect(WikidataDiffAnalyzer.count_claims(content)).to eq(0)
  end

  it 'returns the correct count when content has claims' do
    content = {
      'claims' => {
        'P123' => [
          {
            'mainsnak' => {
              'snaktype' => 'value',
              'property' => 'P123',
              'datavalue' => {
                'value' => 'foo',
                'type' => 'string'
              }
            }
          },
          {
            'mainsnak' => {
              'snaktype' => 'value',
              'property' => 'P123',
              'datavalue' => {
                'value' => 'bar',
                'type' => 'string'
              }
            }
          }
        ],
        'P456' => [
          {
            'mainsnak' => {
              'snaktype' => 'value',
              'property' => 'P456',
              'datavalue' => {
                'value' => 'baz',
                'type' => 'string'
              }
            }
          }
        ]
      }
    }
    expect(WikidataDiffAnalyzer.count_claims(content)).to eq(3)
  end
end


# test cases for count_references (Actual API request)
# Individual Revision Id: 1596238100
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596238100

# parent id of the above revision id: 1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596236983&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596236983
RSpec.describe '.count_references' do
  # this test case expects the reference count to be 4 because the revision content has 4 references in the API request
  it 'returns the number of references in the revision content' do
    revision_id = 1596238100
    content = WikidataDiffAnalyzer.get_revision_content(revision_id)
    expect(WikidataDiffAnalyzer.count_references(content)).to eq(4)
  end
  it 'returns the number of references in the revision content' do
    revision_id = 1596236983
    content = WikidataDiffAnalyzer.get_revision_content(revision_id)
    expect(WikidataDiffAnalyzer.count_references(content)).to eq(3)
  end
end

# test cases for count_references (sanity check, not Actual API request)
RSpec.describe 'count_references' do
  it 'returns 0 when content is nil' do
    expect(WikidataDiffAnalyzer.count_references(nil)).to eq(0)
  end

  it 'returns 0 when content is an empty hash' do
    expect(WikidataDiffAnalyzer.count_references({})).to eq(0)
  end

  it 'returns 0 when content has no claims' do
    content = {
      'foo' => 'bar'
    }
    expect(WikidataDiffAnalyzer.count_references(content)).to eq(0)
  end

  it 'returns 0 when content has claims but no references' do
    content = {
      'claims' => {
        'P123' => [
          {
            'mainsnak' => {
              'snaktype' => 'value',
              'property' => 'P123',
              'datavalue' => {
                'value' => 'foo',
                'type' => 'string'
              }
            }
          }
        ]
      }
    }
    expect(WikidataDiffAnalyzer.count_references(content)).to eq(0)
  end

  it 'returns the correct number of references when content has claims with references' do
    content = {
      'claims' => {
        'P123' => [
          {
            'mainsnak' => {
              'snaktype' => 'value',
              'property' => 'P123',
              'datavalue' => {
                'value' => 'foo',
                'type' => 'string'
              }
            },
            'references' => [
              {
                'snaks' => {
                  'P456' => [
                    {
                      'snaktype' => 'value',
                      'property' => 'P456',
                      'datavalue' => {
                        'value' => 'bar',
                        'type' => 'string'
                      }
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
    }
    expect(WikidataDiffAnalyzer.count_references(content)).to eq(1)
  end
end

# test cases for count_qualifiers(Actual API request)
# Individual Revision Id: 1596238100
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596238100

# parent id of the above revision id: 1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596236983&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596236983
RSpec.describe '.count_qualifiers' do
  # this test case expects the reference count to be 4 because the revision content has 4 references in the API request
  it 'returns the number of qualifiers in the revision content' do
    revision_id = 1596238100
    content = WikidataDiffAnalyzer.get_revision_content(revision_id)
    expect(WikidataDiffAnalyzer.count_qualifiers(content)).to eq(3)
  end
  it 'returns the number of qualifiers in the revision content' do
    revision_id = 1596236983
    content = WikidataDiffAnalyzer.get_revision_content(revision_id)
    expect(WikidataDiffAnalyzer.count_qualifiers(content)).to eq(1)
  end
end

# test cases for get_parent_id (Actual API request)
RSpec.describe 'get_parent_id' do
  describe '#get_parent_id' do
  # Individual Revision Id: 1596238100
  # parent id of the above revision id: 1596236983

  # JSON: https://www.wikidata.org/w/api.php?action=compare&fromrev=1596238100&torelative=prev&format=json
  # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
    it 'returns the ID of the parent revision' do
      # based on https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
      # I know the parent id of this revision 
      # but have to brainstorm idea for other cases
      current_revision_id = 1596238100
      expected_parent_id = 1596236983

      parent_id = WikidataDiffAnalyzer.get_parent_id(current_revision_id)

      expect(parent_id).to eq(expected_parent_id)
    end

  # Individual Revision Id: 123
  # parent id of the above revision id: none

  # JSON: https://www.wikidata.org/w/api.php?action=compare&fromrev=123&torelative=prev&format=json
  # (returns a warning that there's no previous revision)
  # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=123

    it 'returns nil if the current revision is the first revision' do
      # for sure there's no parent revision for this based on API response
      # https://www.wikidata.org/w/api.php?action=compare&fromrev=123&torelative=prev&format=json
      current_revision_id = 123
      parent_id = WikidataDiffAnalyzer.get_parent_id(current_revision_id)
      expect(parent_id).to be_nil
    end
  end
end

# test cases for calculate_diff
RSpec.describe 'calculate_diff' do
  it 'returns the correct claim and reference diff' do
    diff = WikidataDiffAnalyzer.calculate_diff(1596238100)
    # based on the HTML https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
    # the diff is 1 claim, 1 reference and 2 qualifiers
    expect(diff[:claim_diff]).to eq(1)
    expect(diff[:reference_diff]).to eq(1)
    expect(diff[:qualifier_diff]).to eq(2)
  end
end


