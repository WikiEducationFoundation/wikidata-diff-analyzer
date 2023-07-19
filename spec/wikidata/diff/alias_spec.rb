require './lib/wikidata/diff/alias_analyzer'
require './lib/wikidata/diff/large_batches_analyzer'
require 'rspec'

# testcases for isolate_aliases_differences
RSpec.describe '.isolate_aliases_differences' do
    # Individual Revision Id: 1900774614
    # HTML: https://www.wikidata.org/w/index.php?diff=1900774614
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1900774614&rvslots=main&rvprop=content&format=json
    it 'returns the correct added aliases' do
      result = LargeBatchesAnalyzer.handle_large_batches([1900774614], 50)
      current_content = result[1900774614][:current_content]
      parent_content = result[1900774614][:parent_content]
  
      expected_result = {
        added_aliases: [{:lang=>"en", :index=>4}],
        removed_aliases: [],
        changed_aliases: []
        }
      result = AliasAnalyzer.isolate_aliases_differences(current_content, parent_content)
  
      expect(result).to eq(expected_result)
    end
  end
  