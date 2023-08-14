# frozen_string_literal: true

class InsideClaimAnalyzer
  def self.isolate_inside_claim_differences(current_content, parent_content)
    # Initialize empty arrays to store the added, removed, and changed claims
    added = []
    removed = []
    changed = []

    if current_content.nil?
      current_content_claims = {}
    else
      current_content_claims = current_content['claims']
      current_content_claims = {} unless current_content_claims.is_a?(Hash)
    end

    if parent_content.nil?
      parent_content_claims = {}
    else
      parent_content_claims = parent_content['claims']
      parent_content_claims = {} unless parent_content_claims.is_a?(Hash)
    end

    # if parentid is 0, add all current claims as added claims and return it
    if parent_content.nil?
      current_content_claims.each do |claim_key, current_claims|
        current_claims.each_with_index do |_current_claim, index|
          added << { key: claim_key, index: index }
        end
      end
    else
      # Iterate over each claim key in the current content
      current_content_claims.each do |claim_key, current_claims|
        # Check if the claim key exists in the parent content
        if parent_content_claims.key?(claim_key)
          parent_claims = parent_content_claims[claim_key]
          # Iterate over each claim in the current and parent content
          current_claims.each_with_index do |current_claim, index|
            parent_claim = parent_claims[index]
            if parent_claim.nil?
              # Claim was added
              added << { key: claim_key, index: index }

            elsif current_claim != parent_claim
              # Claim was changed
              changed << { key: claim_key, index: index }
            end
          end
          # Check for removed claims
          parent_claims.each_with_index do |_parent_claim, index|
            current_claim = current_claims[index]
            if current_claim.nil?
              # Claim was removed
              removed << { key: claim_key, index: index }
            end
          end
        else
          # All claims in current content with this key were added
          current_claims.each_index do |index|
            added << { key: claim_key, index: index }
          end
        end
      end

      parent_content_claims.each do |claim_key, parent_claims|
        # current content[claims] can be nil
        parent_claims.each_index do |index|
          if current_content_claims.nil? || !current_content_claims.key?(claim_key)
            removed << { key: claim_key, index: index }
          end
        end
      end
    end

    {
      added: added,
      removed: removed,
      changed: changed
    }
  end
end
