# frozen_string_literal: true
# spec/wikidata/diff/analyzer_spec.rb

require './lib/wikidata/diff/analyzer'
require 'rspec'

require_relative 'alias_spec'
require_relative 'claim_spec'
require_relative 'description_spec'
require_relative 'label_spec'
require_relative 'sitelink_spec'


# testcases for analyze
#[0, 123, 456, 1780106722, 1596238100, 1898156691, 1895908644, 622872009, 1901195499, 1902995129, 1903003546, 1863882476, 535078533]
# 0 and 123 not analyzed

# Individual Revision Id: 1780106722 (added 1 reference and removed 1 reference)
# HTML: https://www.wikidata.org/w/index.php?diff=1780106722
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1780106722&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 1596238100 (added 1 claim and references and 2 qualifiers)
# HTML https://www.wikidata.org/w/index.php?&diff=1596238100&oldid=1596236983
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 1898156691 (added 1 claim)
# HTML: https://www.wikidata.org/w/index.php?&diff=1898156691&oldid=1898156041
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1898156691&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 1895908644 (added 3 claims, references and qualifiers)
# HTML: https://www.wikidata.org/w/index.php?&diff=1895908644&oldid=1880197464
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1895908644&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 622872009 (added 1 claim)
# HTML: https://www.wikidata.org/w/index.php?&diff=622872009&oldid=620411938
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=622872009&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 1901195499 (added 1 claim)
# HTML: https://www.wikidata.org/w/index.php?&diff=1901195499&oldid=1901195083
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1901195499&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 1902995129 (removed 1 claim, reference and qualifier)
# HTML: https://www.wikidata.org/w/index.php?&diff=1903003546&oldid=1903003539
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1902995129&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 1903003546 (added 1 qualifier)
# HTML: https://www.wikidata.org/w/index.php?&diff=1902995129&oldid=1900775402
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1903003546&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 1903003546 (added 1 reference)
# HTML: https://www.wikidata.org/w/index.php?&diff=1863882476&oldid=1863882469
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1863882476&rvslots=main&rvprop=content&format=json

# Individual Revision Id: 535078533 (removed 1 reference)
# HTML: https://www.wikidata.org/w/index.php?&diff=535078533&oldid=535078524
# JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=535078533&rvslots=main&rvprop=content&format=json
RSpec.describe WikidataDiffAnalyzer do
  describe '.analyze' do
    it 'returns the correct result for a revision array' do
      revision_ids = [0, 123, 456, 1780106722, 1596238100, 1898156691, 1895908644, 622872009, 1901195499, 1902995129, 1903003546, 1863882476, 535078533]
      analyzed_revisions = WikidataDiffAnalyzer.analyze(revision_ids)

      expected_result ={:diffs_analyzed_count=>11, :diffs_not_analyzed=>[0, 123], :diffs=>{456=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>0, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>1, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 535078533=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>1, :added_references=>1, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 622872009=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1780106722=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>2, :added_references=>1, :removed_references=>1, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1863882476=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>1, :added_references=>1, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1895908644=>{:added_claims=>3, :removed_claims=>0, :changed_claims=>0, :added_references=>3, :removed_references=>0, :changed_references=>0, :added_qualifiers=>3, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1898156691=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1902995129=>{:added_claims=>0, :removed_claims=>1, :changed_claims=>0, :added_references=>0, :removed_references=>1, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>1, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1903003546=>{:added_claims=>0, :removed_claims=>0, :changed_claims=>1, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>1, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1596238100=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>1, :removed_references=>0, :changed_references=>0, :added_qualifiers=>2, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}, 1901195499=>{:added_claims=>1, :removed_claims=>0, :changed_claims=>0, :added_references=>0, :removed_references=>0, :changed_references=>0, :added_qualifiers=>0, :removed_qualifiers=>0, :changed_qualifiers=>0, :added_aliases=>0, :removed_aliases=>0, :changed_aliases=>0, :added_labels=>0, :removed_labels=>0, :changed_labels=>0, :added_descriptions=>0, :removed_descriptions=>0, :changed_descriptions=>0, :added_sitelinks=>0, :removed_sitelinks=>0, :changed_sitelinks=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}}, :total=>{:claims_added=>7, :claims_removed=>1, :claims_changed=>5, :references_added=>7, :references_removed=>2, :references_changed=>0, :qualifiers_added=>6, :qualifiers_removed=>1, :qualifiers_changed=>0, :aliases_added=>0, :aliases_removed=>0, :aliases_changed=>0, :labels_added=>0, :labels_removed=>0, :labels_changed=>0, :descriptions_added=>0, :descriptions_removed=>0, :descriptions_changed=>0, :sitelinks_added=>1, :sitelinks_removed=>0, :sitelinks_changed=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}}
      expect(analyzed_revisions).to eq(expected_result)
    end

    it 'returns the correct result for a revision array' do
      revision_ids = [0, 123, 1803628651, 1952846609]
      analyzed_revisions = WikidataDiffAnalyzer.analyze(revision_ids)

      # the four ids given should not be analyzed
      # 1803628651 is a wiki-text
      # HTML: https://www.wikidata.org/w/index.php?&diff=1803628651
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1803628651&rvslots=main&rvprop=content&format=json
      # 1952846609 is a bad rev id
      # HTML: https://www.wikidata.org/w/index.php?&diff=1952846609
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1952846609&rvslots=main&rvprop=content&format=json

      expected_result = {:diffs_analyzed_count=>0, :diffs_not_analyzed=>[0, 123, 1803628651, 1952846609], :diffs=>{}, :total=>{:claims_added=>0, :claims_removed=>0, :claims_changed=>0, :references_added=>0, :references_removed=>0, :references_changed=>0, :qualifiers_added=>0, :qualifiers_removed=>0, :qualifiers_changed=>0, :aliases_added=>0, :aliases_removed=>0, :aliases_changed=>0, :labels_added=>0, :labels_removed=>0, :labels_changed=>0, :descriptions_added=>0, :descriptions_removed=>0, :descriptions_changed=>0, :sitelinks_added=>0, :sitelinks_removed=>0, :sitelinks_changed=>0, :merge_to=>0, :merge_from=>0, :redirect=>0, :undo=>0, :restore=>0, :clear_item=>0}}
      expect(analyzed_revisions).to eq(expected_result)
    end
  end
end





