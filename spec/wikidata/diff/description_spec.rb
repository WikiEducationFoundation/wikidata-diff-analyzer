require './lib/wikidata/diff/description_analyzer'
require './lib/wikidata/diff/large_batches_analyzer'
require 'rspec'
# testcases for isolate_labels_differences
RSpec.describe '.isolate_descriptions_differences' do
    # Individual Revision Id: 1670943384
    # HTML: https://www.wikidata.org/w/index.php?diff=1670943384
    # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1670943384&rvslots=main&rvprop=content&format=json
    it 'returns the correct added descriptions' do
    result = LargeBatchesAnalyzer.handle_large_batches([1670943384], 50)
    current_content = result[1670943384][:current_content]
    parent_content = result[1670943384][:parent_content]

    expected_result = {
        added_descriptions: [],
        removed_descriptions: [],
        changed_descriptions: [{:lang=>"en"}]
        }
    result = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
    end
end