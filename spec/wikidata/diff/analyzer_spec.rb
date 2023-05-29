require './lib/wikidata/diff/analyzer'
require 'rspec'

RSpec.describe 'Wikidata::Diff::Analyzer' do
  describe '#get_parent_id' do
    it 'returns the ID of the parent revision' do
      # based on https://www.wikidata.org/w/index.php?title=Q111269579&diff=1596238100&oldid=1596236983
      # I know the parent id of this revision 
      # but have to brainstorm idea for other cases
      current_revision_id = 1596238100
      expected_parent_id = 1596236983

      parent_id = get_parent_id(current_revision_id)

      expect(parent_id).to eq(expected_parent_id)
    end

    it 'returns nil if the current revision is the first revision' do
      # for sure there's no parent revision for this
      # https://www.wikidata.org/w/api.php?action=compare&fromrev=123&torelative=prev&format=json
      current_revision_id = 123

      parent_id = get_parent_id(current_revision_id)

      expect(parent_id).to be_nil
    end
  end
end
