# frozen_string_literal: true
require_relative 'large_batches_analyzer'
require_relative 'revision_analyzer'
require_relative 'total'
require_relative 'mediawiki_login'

module WikidataDiffAnalyzer
  class Error < StandardError; end

  # This method analyzes a set of revision ids and returns the differences between them.
  def self.analyze(revision_ids)
    diffs_analyzed_count = 0
    diffs_analyzed = []
    diffs_not_analyzed = []
    diffs = {}
    total = {
      claims_added: 0,
      claims_removed: 0,
      claims_changed: 0,
      references_added: 0,
      references_removed: 0,
      references_changed: 0,
      qualifiers_added: 0,
      qualifiers_removed: 0,
      qualifiers_changed: 0,
      aliases_added: 0,
      aliases_removed: 0,
      aliases_changed: 0,
      labels_added: 0,
      labels_removed: 0,
      labels_changed: 0,
      descriptions_added: 0,
      descriptions_removed: 0,
      descriptions_changed: 0,
      sitelinks_added: 0,
      sitelinks_removed: 0,
      sitelinks_changed: 0,
      merge_to: 0,
      merge_from: 0,
      redirect: 0,
      undo: 0,
      restore: 0,
      clear_item: 0,
      create_item: 0
    }

    # if revision_ids has 0, then 0 can never be analyzed, so remove it and add in not analyzed
    if revision_ids.include?(0)
      revision_ids.delete(0)
      diffs_not_analyzed << 0
    end
    # # if mediawiki can be logged in call for 500, otherwise call for 50
    # if MediawikiLogin.mediawiki_login
    #   puts 'Logged in to mediawiki'
    #   result = LargeBatchesAnalyzer.handle_large_batches(revision_ids, 500)
    # else
    #   puts 'Not logged in to mediawiki'
    #   result = LargeBatchesAnalyzer.handle_large_batches(revision_ids, 50)
    # end

    result = LargeBatchesAnalyzer.handle_large_batches(revision_ids, 50)
    # result is a hash which has contents like this:
    # result[revid] = { current_content: data[:content], parent_content: parent_content }

    result.each do |revision_id, revision_data|
      current_content = revision_data[:current_content]
      parent_content = revision_data[:parent_content]
      comment = revision_data[:comment]
      
    
      if current_content
        diff = RevisionAnalyzer.analyze_diff(current_content, parent_content, comment)
        diffs[revision_id] = diff
        Total.accumulate_totals(diff, total)
        diffs_analyzed << revision_id
        diffs_analyzed_count += 1
      end
    end

    # adding the bad rev_ids to the not_analyzed list
    diffs_not_analyzed += revision_ids - diffs_analyzed

    {
      diffs_analyzed_count: diffs_analyzed_count,
      diffs_not_analyzed: diffs_not_analyzed,
      diffs: diffs,
      total: total
    }
  end
end
