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
  CLAIM_TYPES = [:added_claims, :removed_claims, :changed_claims,:added_references, :removed_references, :changed_references,:added_qualifiers, :removed_qualifiers, :changed_qualifiers].freeze
  ALIAS_TYPES = [:added_aliases, :removed_aliases, :changed_aliases].freeze
  LABEL_TYPES = [:added_labels, :removed_labels, :changed_labels].freeze
  DESCRIPTION_TYPES = [:added_descriptions, :removed_descriptions, :changed_descriptions].freeze
  SITELINK_TYPES = [:added_sitelinks, :removed_sitelinks, :changed_sitelinks].freeze
  COMMENT_TYPES = [:merge_to, :merge_from, :redirect, :undo, :restore, :clear_item].freeze
  LEMMA_TYPES = [:added_lemmas, :removed_lemmas, :changed_lemmas].freeze
  FORM_TYPES = [:added_forms, :removed_forms, :changed_forms, :added_representations, :removed_representations, :changed_representations, :added_formclaims, :removed_formclaims, :changed_formclaims].freeze
  SENSE_TYPES = [:added_senses, :removed_senses, :changed_senses, :added_glosses, :removed_glosses, :changed_glosses, :added_senseclaims, :removed_senseclaims, :changed_senseclaims].freeze
  NOT_IN_ITEM = [:create_lexeme, :create_property, :added_lemmas, :removed_lemmas, :changed_lemmas, :added_forms, :removed_forms, :changed_forms, :added_senses, :removed_senses, :changed_senses, :added_representations, :removed_representations, :changed_representations, :added_glosses, :removed_glosses, :changed_glosses, :added_formclaims, :removed_formclaims, :changed_formclaims, :added_senseclaims, :removed_senseclaims, :changed_senseclaims].freeze
  NOT_IN_PROPERTY = [:create_lexeme, :create_item, :added_sitelinks, :removed_sitelinks, :changed_sitelinks, :added_lemmas, :removed_lemmas, :changed_lemmas, :added_forms, :removed_forms, :changed_forms, :added_senses, :removed_senses, :changed_senses, :added_representations, :removed_representations, :changed_representations, :added_glosses, :removed_glosses, :changed_glosses, :added_formclaims, :removed_formclaims, :changed_formclaims, :added_senseclaims, :removed_senseclaims, :changed_senseclaims].freeze
  NOT_IN_LEXEME = [:create_item, :create_property, :added_sitelinks, :changed_sitelinks, :removed_sitelinks, :added_aliases, :changed_aliases, :removed_aliases, :added_labels, :changed_labels, :removed_labels, :added_descriptions, :changed_descriptions, :removed_descriptions].freeze
  
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


    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
    CLAIM_TYPES.each do |change_type|
      diff[change_type] = claim_diff[change_type].length
    end

    alias_diff = AliasAnalyzer.isolate_aliases_differences(current_content, parent_content)
    ALIAS_TYPES.each do |change_type|
      diff[change_type] = alias_diff[change_type].length
    end

    # Calculate label differences
    label_diff = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)
    LABEL_TYPES.each do |change_type|
      diff[change_type] = label_diff[change_type].length
    end

    # Calculate description differences
    description_diff = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)
    DESCRIPTION_TYPES.each do |change_type|
      diff[change_type] = description_diff[change_type].length
    end

    # Calculate sitelink differences
    sitelink_diff = SitelinkAnalyzer.isolate_sitelinks_differences(current_content, parent_content)
    SITELINK_TYPES.each do |change_type|
      diff[change_type] = sitelink_diff[change_type].length
    end

    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    COMMENT_TYPES.each do |change_type|
      diff[change_type] = phrases[change_type]
    end

    NOT_IN_ITEM.each do |change_type|
      diff[change_type] = 0
    end

    diff[:create_item] = phrases[:create_item]

    diff
  end

  def self.property(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]

    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
    CLAIM_TYPES.each do |change_type|
      diff[change_type] = claim_diff[change_type].length
    end

    alias_diff = AliasAnalyzer.isolate_aliases_differences(current_content, parent_content)
    ALIAS_TYPES.each do |change_type|
      diff[change_type] = alias_diff[change_type].length
    end

    # Calculate label differences
    label_diff = LabelAnalyzer.isolate_labels_differences(current_content, parent_content)

    LABEL_TYPES.each do |change_type|
      diff[change_type] = label_diff[change_type].length
    end

    # Calculate description differences
    description_diff = DescriptionAnalyzer.isolate_descriptions_differences(current_content, parent_content)
    DESCRIPTION_TYPES.each do |change_type|
      diff[change_type] = description_diff[change_type].length
    end
  

    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    COMMENT_TYPES.each do |change_type|
      diff[change_type] = phrases[change_type]
    end

    diff[:create_property] = phrases[:create_item]

    NOT_IN_PROPERTY.each do |change_type|
      diff[change_type] = 0
    end
  end

  def self.lexeme(diff, revision_data)
    current_content = revision_data[:current_content]
    parent_content = revision_data[:parent_content]
    comment = revision_data[:comment]
    
    claim_diff = ClaimAnalyzer.isolate_claims_differences(current_content, parent_content)
    CLAIM_TYPES.each do |change_type|
      diff[change_type] = claim_diff[change_type].length
    end

    forms_diff = FormAnalyzer.isolate_forms_differences(current_content, parent_content)
    FORM_TYPES.each do |change_type|
      diff[change_type] = forms_diff[change_type].length
    end

    # Calculate label differences
    lemmas_diff = LemmaAnalyzer.isolate_lemmas_differences(current_content, parent_content)
    LEMMA_TYPES.each do |change_type|
      diff[change_type] = lemmas_diff[change_type].length
    end

    # Calculate description differences
    senses_diff = SenseAnalyzer.isolate_senses_differences(current_content, parent_content)
    SENSE_TYPES.each do |change_type|
      diff[change_type] = senses_diff[change_type].length
    end

    phrases = CommentAnalyzer.isolate_comment_differences(comment)
    COMMENT_TYPES.each do |change_type|
      diff[change_type] = phrases[change_type]
    end
      
    NOT_IN_LEXEME.each do |change_type|
      diff[change_type] = 0
    end
    diff[:create_lexeme] = phrases[:create_item]
  end
end
