require './lib/wikidata/diff/claim_analyzer'
require './lib/wikidata/diff/large_batches_analyzer'
require 'rspec'

# testcase for isolate_claim_differences
RSpec.describe '.isolate_claim_differences' do
    # Individual Revision Id: 1895908644
    # HTML: https://www.wikidata.org/w/index.php?diff=1895908644
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1895908644&rvslots=main&rvprop=content&format=json
    it 'returns the correct added claims' do
      result = LargeBatchesAnalyzer.handle_large_batches([1895908644], 50)
      current_content = result[1895908644][:current_content]
      parent_content = result[1895908644][:parent_content]
  
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
  
      result = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
  
      expect(result).to eq(expected_result)
    end
  
    it 'returns the correct removed claims' do
      # Individual Revision Id: 1902995129
      # HTML: https://www.wikidata.org/w/index.php?diff=1902995129
      # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1902995129&rvslots=main&rvprop=content&format=json
      result = LargeBatchesAnalyzer.handle_large_batches([1902995129], 50)
      current_content = result[1902995129][:current_content]
      parent_content = result[1902995129][:parent_content]
  
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
  
      result = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
  
      expect(result).to eq(expected_result)
    end
  
    it 'returns the correct changed claims' do
      # Individual Revision Id: 1880197464
      # HTML: https://www.wikidata.org/w/index.php?diff=1880197464
      # JSON(current): https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1880197464&rvslots=main&rvprop=content&format=json
      result = LargeBatchesAnalyzer.handle_large_batches([1880197464], 50)
      current_content = result[1880197464][:current_content]
      parent_content = result[1880197464][:parent_content]
  
      expected_result = {
        added_claims: [],
        removed_claims: [],
        changed_claims: [{:key=>"P856", :index=>0}],
        added_references: [],
        removed_references: [],
        changed_references: [],
        added_qualifiers: [],
        removed_qualifiers: [],
        changed_qualifiers: []
      }
  
      result = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
  
      expect(result).to eq(expected_result)
    end
end
  
  
  