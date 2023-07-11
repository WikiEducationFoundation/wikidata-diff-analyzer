require_relative 'claim_analyzer'
require_relative 'alias_analyzer'
require_relative 'label_analyzer'
require_relative 'description_analyzer'
require_relative 'sitelink_analyzer'
require_relative 'comment_analyzer'

class RevisionAnalyzer
  # This method takes two revisions as input and returns the differences between them.
  def self.analyze_diff(current_content, parent_content, comment)
      diff = {}
      # Calculate claim differences includes references and qualifiers
      claim_diff = ClaimAnalyzer.isolate_claim_differences(current_content, parent_content)
      diff[:added_claims] = claim_diff[:added_claims].length
      diff[:removed_claims] = claim_diff[:removed_claims].length
      diff[:changed_claims] = claim_diff[:changed_claims].length
      diff[:added_references] = claim_diff[:added_references].length
      diff[:removed_references] = claim_diff[:removed_references].length
      diff[:changed_references] = claim_diff[:changed_references].length
      diff[:added_qualifiers] = claim_diff[:added_qualifiers].length
      diff[:removed_qualifiers] = claim_diff[:removed_qualifiers].length
      diff[:changed_qualifiers] = claim_diff[:changed_qualifiers].length
    
      # Calculate alias differences
      alias_diff = AliasAnalyzer.isolate_aliases_differences(current_content, parent_content)
      diff[:added_aliases] = alias_diff[:added].length
      diff[:removed_aliases] = alias_diff[:removed].length
      diff[:changed_aliases] = alias_diff[:changed].length


      # Calculate label differences
      label_diff = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)
      diff[:added_labels] = label_diff[:added].length
      diff[:removed_labels] = label_diff[:removed].length
      diff[:changed_labels] = label_diff[:changed].length

      # Calculate description differences
      description_diff = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)
      diff[:added_descriptions] = description_diff[:added].length
      diff[:removed_descriptions] = description_diff[:removed].length
      diff[:changed_descriptions] = description_diff[:changed].length

      # Calculate sitelink differences
      sitelink_diff = SitelinkAnalyzer.isolate_sitelinks_differences(current_content, parent_content)
      diff[:added_sitelinks] = sitelink_diff[:added].length
      diff[:removed_sitelinks] = sitelink_diff[:removed].length
      diff[:changed_sitelinks] = sitelink_diff[:changed].length


      phrases = CommentAnalyzer.isolate_comment_differences(comment)
      diff[:merge_to] = phrases[:merge_to]
      diff[:merge_from] = phrases[:merge_from]
      diff[:redirect] = phrases[:redirect]
      diff[:undo] = phrases[:undo]
      diff[:restore] = phrases[:restore]
      diff[:clear_item] = phrases[:clear_item]
      diff[:create_item] = phrases[:create_item]

      diff
  end
end
