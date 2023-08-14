# frozen_string_literal: true

class ReferenceAnalyzer
  # helper method for adding and removing references
  def self.reference_updates(claim, updated_references, claim_key, claim_index)
    claim['references']&.each_with_index do |_current_ref, ref_index|
      updated_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
    end
    updated_references
  end

  # helper method for changed references
  def self.handle_changed_references(current_claim, parent_claim, changed_references, added_references, removed_references, claim_key, claim_index)
    current_references = current_claim['references'] || []
    parent_references = parent_claim['references'] || []

    current_references.each_with_index do |current_ref, ref_index|
      if parent_references.empty?
        added_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      elsif !parent_references.include?(current_ref)
        added_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      elsif ref_modified?(current_ref, parent_references)
        changed_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      end
    end

    parent_references.each_with_index do |parent_ref, ref_index|
      unless current_references.include?(parent_ref)
        removed_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      end
    end

    {
      added_references: added_references,
      removed_references: removed_references,
      changed_references: changed_references
    }
  end

  # helper method for checking if a reference has been modified
  def self.ref_modified?(current_reference, parent_references)
    parent_references.each do |parent_reference|
      return true if current_reference['snaks'] != parent_reference['snaks']
    end
    false
  end
end
