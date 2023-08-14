# frozen_string_literal: true

class Total
  KEY_MAPPING = {
    added_claims: :claims_added,
    removed_claims: :claims_removed,
    changed_claims: :claims_changed,
    added_qualifiers: :qualifiers_added,
    removed_qualifiers: :qualifiers_removed,
    changed_qualifiers: :qualifiers_changed,
    added_references: :references_added,
    removed_references: :references_removed,
    changed_references: :references_changed,
    added_aliases: :aliases_added,
    removed_aliases: :aliases_removed,
    changed_aliases: :aliases_changed,
    added_labels: :labels_added,
    removed_labels: :labels_removed,
    changed_labels: :labels_changed,
    added_descriptions: :descriptions_added,
    removed_descriptions: :descriptions_removed,
    changed_descriptions: :descriptions_changed,
    added_sitelinks: :sitelinks_added,
    removed_sitelinks: :sitelinks_removed,
    changed_sitelinks: :sitelinks_changed,
    added_lemmas: :lemmas_added,
    removed_lemmas: :lemmas_removed,
    changed_lemmas: :lemmas_changed,
    added_forms: :forms_added,
    removed_forms: :forms_removed,
    changed_forms: :forms_changed,
    added_representations: :representations_added,
    removed_representations: :representations_removed,
    changed_representations: :representations_changed,
    added_formclaims: :formclaims_added,
    removed_formclaims: :formclaims_removed,
    changed_formclaims: :formclaims_changed,
    added_senses: :senses_added,
    removed_senses: :senses_removed,
    changed_senses: :senses_changed,
    added_glosses: :glosses_added,
    removed_glosses: :glosses_removed,
    changed_glosses: :glosses_changed,
    added_senseclaims: :senseclaims_added,
    removed_senseclaims: :senseclaims_removed,
    changed_senseclaims: :senseclaims_changed,
    merge_from: :merge_from,
    merge_to: :merge_to,
    undo: :undo,
    restore: :restore,
    clear_item: :clear_item,
    create_item: :create_item,
    create_property: :create_property,
    create_lexeme: :create_lexeme,
    redirect: :redirect
  }.freeze

  def self.accumulate_totals(diff_data, total)
    KEY_MAPPING.each do |diff_key, total_key|
      total[total_key] += diff_data[diff_key] if diff_data.key?(diff_key)
    end
  end
end
