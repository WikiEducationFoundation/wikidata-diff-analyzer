require_relative 'claim_analyzer'
require_relative 'alias_analyzer'
require_relative 'label_analyzer'
require_relative 'description_analyzer'
require_relative 'sitelink_analyzer'
require_relative 'comment_analyzer'
require_relative 'form_analyzer'  
require_relative 'sense_analyzer'
require_relative 'lemma_analyzer'


class RevisionAnalyzer
  # This method takes two revisions as input and returns the differences between them.
  def self.analyze_diff(revision_data)
      model = revision_data[:model]
      diff = {}
      if model == 'wikibase-item'
        item(diff, revision_data)
      elsif model == 'wikibase-property'
        property(diff, revision_data)
      elsif model == 'wikibase-lexeme'
        lexeme(diff, revision_data)
      end
      diff
  end

  def self.item(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]
    # Calculate claim differences includes references and qualifiers
    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
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
    diff[:added_aliases] = alias_diff[:added_aliases].length
    diff[:removed_aliases] = alias_diff[:removed_aliases].length
    diff[:changed_aliases] = alias_diff[:changed_aliases].length


    # Calculate label differences
    label_diff = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)
    diff[:added_labels] = label_diff[:added_labels].length
    diff[:removed_labels] = label_diff[:removed_labels].length
    diff[:changed_labels] = label_diff[:changed_labels].length

    # Calculate description differences
    description_diff = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)
    diff[:added_descriptions] = description_diff[:added_descriptions].length
    diff[:removed_descriptions] = description_diff[:removed_descriptions].length
    diff[:changed_descriptions] = description_diff[:changed_descriptions].length

    # Calculate sitelink differences
    sitelink_diff = SitelinkAnalyzer.isolate_sitelinks_differences(current_content, parent_content)
    diff[:added_sitelinks] = sitelink_diff[:added_sitelinks].length
    diff[:removed_sitelinks] = sitelink_diff[:removed_sitelinks].length
    diff[:changed_sitelinks] = sitelink_diff[:changed_sitelinks].length


    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    diff[:merge_to] = phrases[:merge_to]
    diff[:merge_from] = phrases[:merge_from]
    diff[:redirect] = phrases[:redirect]
    diff[:undo] = phrases[:undo]
    diff[:restore] = phrases[:restore]
    diff[:clear_item] = phrases[:clear_item]
    diff[:create_item] = phrases[:create_item]


    # not present in item
    diff[:added_lemmas] = 0
    diff[:removed_lemmas] = 0
    diff[:changed_lemmas] = 0
    diff[:added_forms] = 0
    diff[:removed_forms] = 0
    diff[:changed_forms] = 0
    diff[:added_senses] = 0
    diff[:removed_senses] = 0
    diff[:changed_senses] = 0
    diff[:create_property] = 0
    diff[:create_lexeme] = 0
    diff[:added_representations] = 0
    diff[:removed_representations] = 0
    diff[:changed_representations] = 0
    diff[:added_glosses] = 0
    diff[:removed_glosses] = 0
    diff[:changed_glosses] = 0
    diff[:added_formclaims] = 0
    diff[:removed_formclaims] = 0
    diff[:changed_formclaims] = 0
    diff[:added_senseclaims] = 0
    diff[:removed_senseclaims] = 0
    diff[:changed_senseclaims] = 0

    diff
  end

  def self.property(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]
    # Calculate claim differences includes references and qualifiers
    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
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
      diff[:added_aliases] = alias_diff[:added_aliases].length
      diff[:removed_aliases] = alias_diff[:removed_aliases].length
      diff[:changed_aliases] = alias_diff[:changed_aliases].length
  
  
      # Calculate label differences
      label_diff = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)
      diff[:added_labels] = label_diff[:added_labels].length
      diff[:removed_labels] = label_diff[:removed_labels].length
      diff[:changed_labels] = label_diff[:changed_labels].length
  
      # Calculate description differences
      description_diff = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)
      diff[:added_descriptions] = description_diff[:added_descriptions].length
      diff[:removed_descriptions] = description_diff[:removed_descriptions].length
      diff[:changed_descriptions] = description_diff[:changed_descriptions].length
  

    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    diff[:merge_to] = phrases[:merge_to]
    diff[:merge_from] = phrases[:merge_from]
    diff[:redirect] = phrases[:redirect]
    diff[:undo] = phrases[:undo]
    diff[:restore] = phrases[:restore]
    diff[:clear_item] = phrases[:clear_item]
    diff[:create_item] = 0
    diff[:create_property] = phrases[:create_item]
    diff[:create_lexeme] = 0

    # not present in properties
    diff[:added_sitelinks] = 0
    diff[:removed_sitelinks] = 0
    diff[:changed_sitelinks] = 0
    diff[:added_lemmas] = 0
    diff[:removed_lemmas] = 0
    diff[:changed_lemmas] = 0
    diff[:added_forms] = 0
    diff[:removed_forms] = 0
    diff[:changed_forms] = 0
    diff[:added_senses] = 0
    diff[:removed_senses] = 0
    diff[:changed_senses] = 0
    diff[:added_representations] = 0
    diff[:removed_representations] = 0
    diff[:changed_representations] = 0
    diff[:added_glosses] = 0
    diff[:removed_glosses] = 0
    diff[:changed_glosses] = 0
    diff[:added_formclaims] = 0
    diff[:removed_formclaims] = 0
    diff[:changed_formclaims] = 0
    diff[:added_senseclaims] = 0
    diff[:removed_senseclaims] = 0
    diff[:changed_senseclaims] = 0
  end

  def self.lexeme(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]
    # Calculate claim differences includes references and qualifiers
    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
    diff[:added_claims] = claim_diff[:added_claims].length
    diff[:removed_claims] = claim_diff[:removed_claims].length
    diff[:changed_claims] = claim_diff[:changed_claims].length
    diff[:added_references] = claim_diff[:added_references].length
    diff[:removed_references] = claim_diff[:removed_references].length
    diff[:changed_references] = claim_diff[:changed_references].length
    diff[:added_qualifiers] = claim_diff[:added_qualifiers].length
    diff[:removed_qualifiers] = claim_diff[:removed_qualifiers].length
    diff[:changed_qualifiers] = claim_diff[:changed_qualifiers].length

    # not present in lexeme
    diff[:added_aliases] = 0
    diff[:removed_aliases] = 0
    diff[:changed_aliases] = 0
    diff[:added_labels] = 0
    diff[:removed_labels] = 0
    diff[:changed_labels] = 0
    diff[:added_descriptions] = 0
    diff[:removed_descriptions] = 0
    diff[:changed_descriptions] = 0
    diff[:added_sitelinks] = 0
    diff[:removed_sitelinks] = 0
    diff[:changed_sitelinks] = 0

    # Calculate alias differences
    forms_diff = FormAnalyzer.isolate_forms_differences(current_content, parent_content)
    diff[:added_forms] = forms_diff[:added_forms].length
    diff[:removed_forms] = forms_diff[:removed_forms].length
    diff[:changed_forms] = forms_diff[:changed_forms].length
    diff[:added_representations] = forms_diff[:added_representations].length
    diff[:removed_representations] = forms_diff[:removed_representations].length
    diff[:changed_representations] = forms_diff[:changed_representations].length
    diff[:added_formclaims] = forms_diff[:added_formclaims].length
    diff[:removed_formclaims] = forms_diff[:removed_formclaims].length
    diff[:changed_formclaims] = forms_diff[:changed_formclaims].length



    # Calculate label differences
    lemmas_diff = LemmaAnalyzer.isolate_lemmas_differences(current_content, parent_content)
    diff[:added_lemmas] = lemmas_diff[:added_lemmas].length
    diff[:removed_lemmas] = lemmas_diff[:removed_lemmas].length
    diff[:changed_lemmas] = lemmas_diff[:changed_lemmas].length

    # Calculate description differences
    senses_diff = SenseAnalyzer.isolate_senses_differences(current_content, parent_content)
    diff[:added_senses] = senses_diff[:added_senses].length
    diff[:removed_senses] = senses_diff[:removed_senses].length
    diff[:changed_senses] = senses_diff[:changed_senses].length
    diff[:added_glosses] = senses_diff[:added_glosses].length
    diff[:removed_glosses] = senses_diff[:removed_glosses].length
    diff[:changed_glosses] = senses_diff[:changed_glosses].length
    diff[:added_senseclaims] = senses_diff[:added_senseclaims].length
    diff[:removed_senseclaims] = senses_diff[:removed_senseclaims].length
    diff[:changed_senseclaims] = senses_diff[:changed_senseclaims].length


    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    diff[:merge_to] = phrases[:merge_to]
    diff[:merge_from] = phrases[:merge_from]
    diff[:redirect] = phrases[:redirect]
    diff[:undo] = phrases[:undo]
    diff[:restore] = phrases[:restore]
    diff[:clear_item] = phrases[:clear_item]
    diff[:create_item] = 0
    diff[:create_property] = 0
    diff[:create_lexeme] = phrases[:create_item]

  end
end
