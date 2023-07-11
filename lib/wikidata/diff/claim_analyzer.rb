require_relative 'reference_analyzer'
require_relative 'qualifier_analyzer'

class ClaimAnalyzer
    def self.isolate_claim_differences(current_content, parent_content)
        # Initialize empty arrays to store the added, removed, and changed claims
        added_claims = []
        removed_claims = []
        changed_claims = []
        added_references = []
        removed_references = []
        changed_references = []
        added_qualifiers = []
        removed_qualifiers = []
        changed_qualifiers = []

        current_content_claims = current_content["claims"] if current_content
        parent_content_claims = parent_content["claims"] if parent_content

        if !current_content_claims.is_a?(Hash) || !parent_content_claims.is_a?(Hash)
        return {
            added_claims: added_claims,
            removed_claims: removed_claims,
            changed_claims: changed_claims,
            added_references: added_references,
            removed_references: removed_references,
            changed_references: changed_references,
            added_qualifiers: added_qualifiers,
            removed_qualifiers: removed_qualifiers,
            changed_qualifiers: changed_qualifiers
        }
        end

        current_content_claims = current_content["claims"] || {}
        
        # if parentid is 0, add all current claims as added claims and return it
        if parent_content.nil?
            current_content_claims.each do |claim_key, current_claims|
                current_claims.each_with_index do |current_claim, index|
                    added_claims << { key: claim_key, index: index }
                    # check if there's any references or qualifiers in this claim
                    added_references = ReferenceAnalyzer.reference_updates(current_claim, added_references, claim_key, index)
                    added_qualifiers = QualifierAnalyzer.qualifier_updates(current_claim, added_qualifiers, claim_key, index)
                end
            end
        else
            # Iterate over each claim key in the current content
            current_content["claims"].each do |claim_key, current_claims|
            # Check if the claim key exists in the parent content
            if parent_content["claims"].key?(claim_key)
                parent_claims = parent_content["claims"][claim_key]
                # Iterate over each claim in the current and parent content
                current_claims.each_with_index do |current_claim, index|
                    parent_claim = parent_claims[index]
                    if parent_claim.nil?
                        # Claim was added
                        added_claims << { key: claim_key, index: index }
                        # check if there's any references or qualifiers in this claim
                        added_references = ReferenceAnalyzer.reference_updates(current_claim, added_references, claim_key, index)
                        added_qualifiers = QualifierAnalyzer.qualifier_updates(current_claim, added_qualifiers, claim_key, index)

                    elsif current_claim != parent_claim
                        # Claim was changed
                        changed_claims << { key: claim_key, index: index }
                        # check if there's any references or qualifiers in this claim
                        changed_references_hash = ReferenceAnalyzer.handle_changed_references(current_claim, parent_claim, changed_references, added_references, removed_references, claim_key, index)

                        added_references = changed_references_hash[:added_references]
                        removed_references = changed_references_hash[:removed_references]
                        changed_references = changed_references_hash[:changed_references]

                        changed_qualifiers_hash = QualifierAnalyzer.handle_changed_qualifiers(current_claim, parent_claim, changed_qualifiers, added_qualifiers, removed_qualifiers, claim_key, index)

                        added_qualifiers = changed_qualifiers_hash[:added_qualifiers]
                        removed_qualifiers = changed_qualifiers_hash[:removed_qualifiers]
                        changed_qualifiers = changed_qualifiers_hash[:changed_qualifiers]
                    end
                end
                # Check for removed claims
                parent_claims.each_with_index do |parent_claim, index|
                    current_claim = current_claims[index]
                    if current_claim.nil?
                        # Claim was removed
                        removed_claims << { key: claim_key, index: index }

                        # check if there's any references or qualifiers in this claim
                        removed_references = ReferenceAnalyzer.reference_updates(parent_claim, removed_references, claim_key, index)
                        removed_qualifiers = QualifierAnalyzer.qualifier_updates(parent_claim, removed_qualifiers, claim_key, index)
                    end
                end
            else
                # All claims in current content with this key were added
                current_claims.each_index do |index|
                    added_claims << { key: claim_key, index: index }
                    # check if there's any references or qualifiers in this claim
                    added_references = ReferenceAnalyzer.reference_updates(current_claims[index], added_references, claim_key, index)
                    added_qualifiers = QualifierAnalyzer.qualifier_updates(current_claims[index], added_qualifiers, claim_key, index)
                end
            end
            end

            parent_content["claims"].each do |claim_key, parent_claims|
                # current content[claims] can be nil
                parent_claims.each_index do |index|
                    if current_content["claims"].nil? || !current_content["claims"].key?(claim_key)
                    removed_claims << { key: claim_key, index: index }
                    # check if there's any references or qualifiers in this claim
                    removed_references = ReferenceAnalyzer.reference_updates(parent_claims[index], removed_references, claim_key, index)
                    removed_qualifiers = QualifierAnalyzer.qualifier_updates(parent_claims[index], removed_qualifiers, claim_key, index)
                    end
                end
            end
        end

        {
            added_claims: added_claims,
            removed_claims: removed_claims,
            changed_claims: changed_claims,
            added_references: added_references,
            removed_references: removed_references,
            changed_references: changed_references,
            added_qualifiers: added_qualifiers,
            removed_qualifiers: removed_qualifiers,
            changed_qualifiers: changed_qualifiers
        }
    end
end