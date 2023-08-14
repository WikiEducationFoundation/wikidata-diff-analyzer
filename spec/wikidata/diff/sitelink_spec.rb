# frozen_string_literal: true

require './lib/wikidata/diff/sitelink_analyzer'
require './lib/wikidata/diff/large_batches_analyzer'
require 'rspec'
RSpec.describe '.isolate_sitelinks_differences' do
  # Individual Revision Id: 1633844937
  # HTML: https://www.wikidata.org/w/index.php?diff=1633844937
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1633844937&rvslots=main&rvprop=content&format=json
  it 'returns the correct added sitelinks' do
    result = LargeBatchesAnalyzer.handle_large_batches([1_633_844_937], 50)
    current_content = result[1_633_844_937][:current_content]
    parent_content = result[1_633_844_937][:parent_content]

    expected_result = {
      added_sitelinks: { 'arzwiki' => { 'site' => 'arzwiki', 'title' => 'جامعة ولاية واشينطون', 'badges' => [] } },
      removed_sitelinks: {},
      changed_sitelinks: {}
    }
    result = SitelinkAnalyzer.isolate_sitelinks_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end

  # Individual Revision Id: 1889506559
  # HTML: https://www.wikidata.org/w/index.php?diff=1889506559
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1889506559&rvslots=main&rvprop=content&format=json
  it 'returns the correct removed sitelinks' do
    result = LargeBatchesAnalyzer.handle_large_batches([1_889_506_559], 50)
    current_content = result[1_889_506_559][:current_content]
    parent_content = result[1_889_506_559][:parent_content]

    expected_result = {
      added_sitelinks: {},
      removed_sitelinks: { 'nahwiki' => { 'site' => 'nahwiki', 'title' => 'San Francisco, California',
                                          'badges' => [] } },
      changed_sitelinks: {}
    }
    result = SitelinkAnalyzer.isolate_sitelinks_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end

RSpec.describe '.isolate_sitelinks_differences' do
  # Individual Revision Id: 1813177540
  # HTML: https://www.wikidata.org/w/index.php?diff=1813177540
  # JSON: https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1813177540&rvslots=main&rvprop=content&format=json
  it 'returns the correct changed sitelinks' do
    result = LargeBatchesAnalyzer.handle_large_batches([1_813_177_540], 50)
    current_content = result[1_813_177_540][:current_content]
    parent_content = result[1_813_177_540][:parent_content]

    expected_result = {
      added_sitelinks: {},
      removed_sitelinks: {},
      changed_sitelinks: { 'itwiki' => {
        current: { 'site' => 'itwiki', 'title' => 'Università statale del Washington',
                   'badges' => [] }, parent: { 'site' => 'itwiki', 'title' => 'Washington State University',
                                               'badges' => [] }
      } }
    }
    result = SitelinkAnalyzer.isolate_sitelinks_differences(current_content, parent_content)

    expect(result).to eq(expected_result)
  end
end
