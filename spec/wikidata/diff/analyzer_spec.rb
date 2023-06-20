# frozen_string_literal: true
# spec/wikidata/diff/analyzer_spec.rb

require './lib/wikidata/diff/analyzer'
require 'rspec'

# testcases for analyze
RSpec.describe WikidataDiffAnalyzer do
  describe '.analyze' do
    it 'returns the correct result for a revision array' do
      revision_ids = [1596231784, 1596238100, 1898156691, 1895908644, 622872009, 1901195499, 1902995129, 1903003546, 1863882476, 535078533]
      analyzed_revisions = WikidataDiffAnalyzer.analyze(revision_ids)

      expected_result = {:diffs_analyzed_count=>9, :diffs_not_analyzed=>[1596231784], :diffs=>{1596238100=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>1, :removed_references=>0, :changed_references=>0, :added_qualifiers=>2, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 1898156691=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 1895908644=>{:added_claims=>3, :removed_claims=>0, :changed_claims=>0, :added_references=>3, :removed_references=>0, :changed_references=>0, :added_qualifiers=>3, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 622872009=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 1901195499=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 1902995129=>{:added_claims=>0, :removed_claims=>1, :changed_claims=>0, :added_references=>0, :removed_references=>1, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>1, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 1903003546=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>1, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>1, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 1863882476=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>1, :added_references=>1, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}, 535078533=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>1, :added_references=>1, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0}}, :total=>{:references_added=>6, :references_removed=>1, :references_changed=>0, :aliases_added=>0, :aliases_removed=>0, :aliases_changed=>0, :labels_added=>0, :labels_removed=>0, :labels_changed=>0, :descriptions_added=>0, :descriptions_removed=>0, :descriptions_changed=>0, :sitelinks_added=>0, :sitelinks_removed=>0, :sitelinks_changed=>0, :qualifiers_added=>6, :qualifiers_removed=>1, :qualifiers_changed=>0, :claims_added=>7, :claims_removed=>1, :claims_changed=>3}}
      expect(analyzed_revisions).to eq(expected_result)
    end
  end
end

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

# testcase for isolate_claim_differences
RSpec.describe '.isolate_claim_differences' do
  # Individual Revision Id: 1895908644
  # HTML: https://www.wikidata.org/w/index.php?diff=1895908644
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1895908644&rvslots=main&rvprop=content&format=json
  it 'returns the correct added claims' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1895908644)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1895908644)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added_claims: [{:key=>"P2196", :index=>1}, {:key=>"P6589", :index=>0}, {:key=>"P6589", :index=>1}],
      removed_claims: [],
      changed_claims: [],
      added_references: [{:claim_key=>"P2196", :claim_index=>1, :reference_index=>0}, {:claim_key=>"P6589", :claim_index=>0, :reference_index=>0}, {:claim_key=>"P6589", :claim_index=>1, :reference_index=>0}],
      removed_references: [],
      changed_references: [],
      added_qualifiers: [{:claim_key=>"P2196", :claim_index=>1, :qualifier_key=>"P585", :qualifier_index=>0}, {:claim_key=>"P6589", :claim_index=>0, :qualifier_key=>"P585", :qualifier_index=>0}, {:claim_key=>"P6589", :claim_index=>1, :qualifier_key=>"P585", :qualifier_index=>0}],
      removed_qualifiers: [],
      changed_qualifiers: []
    }

    result = WikidataDiffAnalyzer.isolate_claim_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end

  it 'returns the correct removed claims' do
    # Individual Revision Id: 1902995129
    # HTML: https://www.wikidata.org/w/index.php?diff=1902995129
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1902995129&rvslots=main&rvprop=content&format=json
    current_content = WikidataDiffAnalyzer.get_revision_content(1902995129)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1902995129)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added_claims: [],
      removed_claims: [{:key=>"P2196", :index=>1}],
      changed_claims: [],
      added_references: [],
      removed_references: [{:claim_key=>"P2196", :claim_index=>1, :reference_index=>0}],
      changed_references: [],
      added_qualifiers: [],
      removed_qualifiers: [{:claim_key=>"P2196", :claim_index=>1, :qualifier_key=>"P585", :qualifier_index=>0}],
      changed_qualifiers: []
    }

    result = WikidataDiffAnalyzer.isolate_claim_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end

  it 'returns the correct changed claims' do
    # Individual Revision Id: 1880197464
    # HTML: https://www.wikidata.org/w/index.php?diff=1880197464
    # JSON(current): https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1880197464&rvslots=main&rvprop=content&format=json
    current_content = WikidataDiffAnalyzer.get_revision_content(1880197464)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1880197464)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added_claims: [],
      removed_claims: [],
      changed_claims: [{:key=>"P856", :index=>0}],
      added_references: [],
      removed_references: [],
      changed_references: [],
      added_qualifiers: [],
      removed_qualifiers: [],
      changed_qualifiers: [{:claim_key=>"P856", :claim_index=>0, :qualifier_key=>"P407", :qualifier_index=>0}]
    }

    result = WikidataDiffAnalyzer.isolate_claim_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end

# testcases for isolate_reference_differences
# Individual Revision Id: 535078533
# added 1 reference
#  added: [{:claim_key=>"P463", :claim_index=>1, :reference_index=>0}],
# HTML: https://www.wikidata.org/w/index.php?diff=535078533
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=535078533&rvslots=main&rvprop=content&format=json

  # Individual Revision Id: 1780106722
  # added 1 reference and removed 1 reference
  # added: [{:claim_index=>0, :claim_key=>"P3500", :reference_index=>0}],
  # removed: [{:claim_index=>0, :claim_key=>"P3500", :reference_index=>0}],
  # HTML: https://www.wikidata.org/w/index.php?diff=1780106722
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1780106722&rvslots=main&rvprop=content&format=json

# testcases for isolate_qualifiers_differences
# Individual Revision Id: 1903003546
# added 1 qualifier
# {:claim_key=>"P2196", :claim_index=>1, :qualifier_key=>"P585", :qualifier_index=>0}
# HTML: https://www.wikidata.org/w/index.php?diff=1903003546
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1903003546&rvslots=main&rvprop=content&format=json
# Individual Revision Id: 1902995129 (removed 1 qualifier)
# [{:claim_key=>"P2196", :claim_index=>1, :qualifier_key=>"P585", :qualifier_index=>0}]
# HTML: https://www.wikidata.org/w/index.php?diff=1902995129
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1902995129&rvslots=main&rvprop=content&format=json

# testcases for isolate_aliases_differences
# Individual Revision Id: 1900774614
# HTML: https://www.wikidata.org/w/index.php?diff=1900774614
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1900774614&rvslots=main&rvprop=content&format=json
RSpec.describe '.isolate_aliases_differences' do
  it 'returns the correct added aliases' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1900774614)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1900774614)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added: [{:lang=>"en", :index=>4}],
      removed: [],
      changed: []
      }
    result = WikidataDiffAnalyzer.isolate_aliases_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end

# testcases for isolate_labels_differences
# Individual Revision Id: 670856707
# HTML: https://www.wikidata.org/w/index.php?diff=670856707
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=670856707&rvslots=main&rvprop=content&format=json
RSpec.describe '.isolate_labels_differences' do
  it 'returns the correct added labels' do
    current_content = WikidataDiffAnalyzer.get_revision_content(670856707)
    parent_id = WikidataDiffAnalyzer.get_parent_id(670856707)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added: [{:lang=>"he"}],
      removed: [],
      changed: []
      }
    result = WikidataDiffAnalyzer.isolate_labels_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end
# testcases for isolate_labels_differences
# Individual Revision Id: 1670943384
# HTML: https://www.wikidata.org/w/index.php?diff=1670943384
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1670943384&rvslots=main&rvprop=content&format=json
RSpec.describe '.isolate_descriptions_differences' do
  it 'returns the correct added descriptions' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1670943384)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1670943384)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added: [],
      removed: [],
      changed: [{:lang=>"en"}]
      }
    result = WikidataDiffAnalyzer.isolate_descriptions_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end

RSpec.describe '.isolate_sitelinks_differences' do
  # Individual Revision Id: 1633844937
  # HTML: https://www.wikidata.org/w/index.php?diff=1633844937
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1633844937&rvslots=main&rvprop=content&format=json
  it 'returns the correct added sitelinks' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1633844937)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1633844937)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added: {"arzwiki"=>{"site"=>"arzwiki", "title"=>"جامعة ولاية واشينطون", "badges"=>[]}},
      removed: {},
      changed: {}
      }
    result = WikidataDiffAnalyzer.isolate_sitelinks_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end

  # Individual Revision Id: 1889506559
  # HTML: https://www.wikidata.org/w/index.php?diff=1889506559
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1889506559&rvslots=main&rvprop=content&format=json
  it 'returns the correct removed sitelinks' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1889506559)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1889506559)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added: {},
      removed: {"nahwiki"=>{"site"=>"nahwiki", "title"=>"San Francisco, California", "badges"=>[]}},
      changed: {}
      }
    result = WikidataDiffAnalyzer.isolate_sitelinks_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end

  # Individual Revision Id: 1813177540
  # HTML: https://www.wikidata.org/w/index.php?diff=1813177540
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1813177540&rvslots=main&rvprop=content&format=json
  it 'returns the correct changed sitelinks' do
    current_content = WikidataDiffAnalyzer.get_revision_content(1813177540)
    parent_id = WikidataDiffAnalyzer.get_parent_id(1813177540)
    parent_content = WikidataDiffAnalyzer.get_revision_content(parent_id)

    expected_result = {
      added: {},
      removed: {},
      changed: {"itwiki"=>{:current=>{"site"=>"itwiki", "title"=>"Università statale del Washington", "badges"=>[]}, :parent=>{"site"=>"itwiki", "title"=>"Washington State University", "badges"=>[]}}}
      }
    result = WikidataDiffAnalyzer.isolate_sitelinks_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end


# testcases for claim count(Acutal API request)(added 1)
# Individual Revision Id: 1596238100
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596238100

# parent id of the above revision id: 1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596236983&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596236983


# test cases for count_references (Actual API request)(added 1 r)
# Individual Revision Id: 1596238100
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596238100

# parent id of the above revision id: 1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596236983&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596236983


# test cases for count_qualifiers(Actual API request)(added 2 q)
# Individual Revision Id: 1596238100
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596238100

# parent id of the above revision id: 1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596236983&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?diff=1596236983



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


# [1596238100, 1898156691, 1895908644, 622872009, 1901195499, 1902995129, 1903003546, 1863882476, 535078533]
# [c-r 1 added q 2 added, c 1 added, c-r-f 3 added, c-1 added, c-1 added, c-r-f 1 removed, q-1 added, r-1 added, r-1 added]
# HTML https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1898156691&oldid=1898156041
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1898156691&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1895908644&oldid=1880197464
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1895908644&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=622872009&oldid=620411938
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=622872009&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1901195499&oldid=1901195083
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1901195499&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1903003546&oldid=1903003539
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1902995129&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q597236&diff=1902995129&oldid=1900775402
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1903003546&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=1863882476&oldid=1863882469
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1863882476&rvslots=main&rvprop=content&format=json
# HTML: https://www.wikidata.org/w/index.php?title=Q111269579&diff=535078533&oldid=535078524
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=535078533&rvslots=main&rvprop=content&format=json

