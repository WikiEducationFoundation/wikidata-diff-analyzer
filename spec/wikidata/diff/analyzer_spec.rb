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

# testcases for isolate_claim_differences
# Individual Revision Id: 1895908644
# HTML: https://www.wikidata.org/w/index.php?diff=1895908644
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1895908644&rvslots=main&rvprop=content&format=json
RSpec.describe '.isolate_claim_differences' do
  it 'returns the correct added, removed, and changed claims' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1895908644)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1895908644)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
        added: [
          { key: "P2196", index: 1 },
          { key: "P6589", index: 0 },
          { key: "P6589", index: 1 }
        ],
        removed: [],
        changed: []
      }
    result = WikidataDiffAnalyzer.isolate_claim_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end

# testcases for isolate_claim_differences
# Individual Revision Id: 1863882476
# HTML: https://www.wikidata.org/w/index.php?diff=1863882476
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1863882476&rvslots=main&rvprop=content&format=json
RSpec.describe '.isolate_reference_differences' do
  it 'returns the correct added, removed, and changed claims' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1863882476)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1863882476)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added: [{:key=>"P11686", :index=>0, :reference=>{"hash"=>"99c0d544f9c1449044651cdae3b4b7720d44c50e", "snaks"=>{"P214"=>[{"snaktype"=>"value", "property"=>"P214", "hash"=>"65d02e60b216c442174de88f2406399a6b07a9d2", "datavalue"=>{"value"=>"130740537", "type"=>"string"}}]}, "snaks-order"=>["P214"]}}],
      removed: [],
      modified: []
      }
    result = WikidataDiffAnalyzer.isolate_reference_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
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

 # test cases for count_statements
 RSpec.describe 'count_statements' do
  # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
  it 'returns the number of statements in the revision content' do
    revision_id = 1596238100
    content = WikidataDiffAnalyzer.get_revision_content(revision_id)
    expect(WikidataDiffAnalyzer.count_statements(content)).to eq(11)
  end
  it 'returns the number of statements in the revision content' do
    revision_id = 1596236983
    content = WikidataDiffAnalyzer.get_revision_content(revision_id)
    expect(WikidataDiffAnalyzer.count_statements(content)).to eq(10)
  end
  # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1880197464&oldid=1895908644
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1880197464&rvslots=main&rvprop=content&format=json
  it 'returns the count of statements' do
    parent_content = WikidataDiffAnalyzer.get_revision_content(1880197464)
    expect(WikidataDiffAnalyzer.count_statements(parent_content)).to eq(107)
    content = WikidataDiffAnalyzer.get_revision_content(1895908644)
    expect(WikidataDiffAnalyzer.count_statements(content)).to eq(110)
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

# test cases for get_child_id (Actual API request)
RSpec.describe 'get_child_id' do
  describe '#get_child_id' do
  # parent id of the above revision id: 1596236983
  # Child Revision Id: 1596238100

  # JSON: https://www.wikidata.org/w/api.php?action=compare&fromrev=1596236983&torelative=next&format=json
  # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
    it 'returns the ID of the parent revision' do
      # based on https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
      parent_revision_id = 1596236983
      expected_child_id = 1596238100

      child_id = WikidataDiffAnalyzer.get_child_id(parent_revision_id)

      expect(child_id).to eq(expected_child_id)
    end
  end
end

# test cases for calculate_diff
RSpec.describe 'calculate_diff' do
  it 'returns the correct claim and reference diff' do
    diff = WikidataDiffAnalyzer.calculate_diff(1596238100)
    # based on the HTML https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
    # the diff is 1 claim, 1 reference and 2 qualifiers
    expect(diff[:claim_diff]).to eq(1)
    expect(diff[:reference_diff]).to eq(1)
    expect(diff[:qualifier_diff]).to eq(2)
  end
end

# more test cases for calculate diff
  RSpec.describe '.calculate_diff' do
    # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1898156691&oldid=1898156041
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1898156691&rvslots=main&rvprop=content&format=json
    it 'returns the correct difference for creating a new claim (statement)' do
      revision_id = 1898156691
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(1)
      expect(diff[:reference_diff]).to eq(0)
      expect(diff[:qualifier_diff]).to eq(0)
    end

    # does not pass currently
    it 'returns the correct difference for creating a statement with open refine' do
    # HTML: https://www.wikidata.org/w/index.php?title=Q597236&oldid=1895908644
    # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1895908644&oldid=1880197464
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1895908644&rvslots=main&rvprop=content&format=json
      revision_id = 1895908644
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(3)
      expect(diff[:reference_diff]).to eq(3)
      expect(diff[:qualifier_diff]).to eq(3)
    end

    it 'returns the correct difference for creating a new claim with mix\'n\'match' do
      # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=622872009&oldid=620411938
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=622872009&rvslots=main&rvprop=content&format=json
      revision_id = 622872009
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(1)
      expect(diff[:reference_diff]).to eq(0)
      expect(diff[:qualifier_diff]).to eq(0)
    end

    it 'returns the correct difference for creating a new claim with recoin' do
      # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1901195499&oldid=1901195083
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1901195499&rvslots=main&rvprop=content&format=json
      revision_id = 1901195499
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(1)
      expect(diff[:reference_diff]).to eq(0)
      expect(diff[:qualifier_diff]).to eq(0)
    end

    it 'returns the correct difference for removing a claim (statement)' do
      # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1903003546&oldid=1903003539
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1902995129&rvslots=main&rvprop=content&format=json
      revision_id = 1902995129
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(-1)
      # when the claim is removed, all the references and qualifiers in that claim are removed as well
      # currently, the count is general and not specific to the claim - but it's fine for now
      expect(diff[:reference_diff]).to eq(-1)
      expect(diff[:qualifier_diff]).to eq(-1)
    end

    it 'returns the correct difference for adding a qualifier to a claim (statement)' do
      # HTML: https://www.wikidata.org/w/index.php?title=Q597236&diff=1902995129&oldid=1900775402
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1903003546&rvslots=main&rvprop=content&format=json
      revision_id = 1903003546
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(0)
      expect(diff[:reference_diff]).to eq(0)
      expect(diff[:qualifier_diff]).to eq(1)
    end

    it 'returns the correct difference for adding a reference to a claim' do
      # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1863882476&oldid=1863882469
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1863882476&rvslots=main&rvprop=content&format=json
      revision_id = 1863882476
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(0)
      expect(diff[:reference_diff]).to eq(1)
      expect(diff[:qualifier_diff]).to eq(0)
    end

    it 'returns the correct difference for adding a reference to a claim using quickstatements' do
      # HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=535078533&oldid=535078524
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=535078533&rvslots=main&rvprop=content&format=json
      revision_id = 535078533
      diff = WikidataDiffAnalyzer.calculate_diff(revision_id)

      expect(diff[:claim_diff]).to eq(0)
      expect(diff[:reference_diff]).to eq(1)
      expect(diff[:qualifier_diff]).to eq(0)
    end
end

