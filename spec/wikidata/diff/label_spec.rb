require './lib/wikidata/diff/label_analyzer'
require './lib/wikidata/diff/large_batches_analyzer'
require 'rspec'
# testcases for isolate_labels_differences
RSpec.describe '.isolate_labels_differences' do
    # Individual Revision Id: 670856707
    # HTML: https://www.wikidata.org/w/index.php?diff=670856707
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=670856707&rvslots=main&rvprop=content&format=json
    it 'returns the correct added labels' do
        result = LargeBatchesAnalyzer.handle_large_batches([670856707], 50)
        current_content = result[670856707][:current_content]
        parent_content = result[670856707][:parent_content]
    
        expected_result = {
          added_labels: [{:lang=>"he"}],
          removed_labels: [],
          changed_labels: []
          }
        result = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)
    
        expect(result).to eq(expected_result)
    end
end