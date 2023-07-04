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

        if !current_content["claims"].is_a?(Hash) || !parent_content["claims"].is_a?(Hash)
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
                added_references = reference_updates(current_claim, added_references, claim_key, index)
                added_qualifiers = qualifier_updates(current_claim, added_qualifiers, claim_key, index)

            elsif current_claim != parent_claim
                # Claim was changed
                changed_claims << { key: claim_key, index: index }
                # check if there's any references or qualifiers in this claim
                changed = handle_changed_references(current_claim, parent_claim, changed_references, added_references, removed_references, claim_key, index)
                added_references = changed[:added_references]
                removed_references = changed[:removed_references]
                changed_references = changed[:changed_references]
                changed_qualifiers = handle_changed_qualifiers(current_claim, parent_claim, changed_qualifiers, added_qualifiers, removed_qualifiers, claim_key, index)
                added_qualifiers = changed_qualifiers[:added_qualifiers]
                removed_qualifiers = changed_qualifiers[:removed_qualifiers]
                changed_qualifiers = changed_qualifiers[:changed_qualifiers]
            end
            end
            # Check for removed claims
            parent_claims.each_with_index do |parent_claim, index|
            current_claim = current_claims[index]
            if current_claim.nil?
                # Claim was removed
                removed_claims << { key: claim_key, index: index }

                # check if there's any references or qualifiers in this claim
                removed_references = reference_updates(parent_claim, removed_references, claim_key, index)
                removed_qualifiers = qualifier_updates(parent_claim, removed_qualifiers, claim_key, index)
            end
            end
        else
            # All claims in current content with this key were added
            current_claims.each_index do |index|
            added_claims << { key: claim_key, index: index }
            # check if there's any references or qualifiers in this claim
            added_references = reference_updates(current_claims[index], added_references, claim_key, index)
            added_qualifiers = qualifier_updates(current_claims[index], added_qualifiers, claim_key, index)
            end
        end
        end

        parent_content["claims"].each do |claim_key, parent_claims|
        # current content[claims] can be nil
        parent_claims.each_index do |index|
            if current_content["claims"].nil? || !current_content["claims"].key?(claim_key)
            removed_claims << { key: claim_key, index: index }
            # check if there's any references or qualifiers in this claim
            removed_references = reference_updates(parent_claims[index], removed_references, claim_key, index)
            removed_qualifiers = qualifier_updates(parent_claims[index], removed_qualifiers, claim_key, index)
            end
        end
        end
    
        # puts "Added claims: #{added_claims}"
        # puts "Removed claims: #{removed_claims}"
        # puts "Changed claims: #{changed_claims}"
        # puts "Added references: #{added_references}"
        # puts "Removed references: #{removed_references}"
        # puts "Changed references: #{changed_references}"
        # puts "Added qualifiers: #{added_qualifiers}"
        # puts "Removed qualifiers: #{removed_qualifiers}"
        # puts "Changed qualifiers: #{changed_qualifiers}"


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

    # helper method for adding and removing references
    def self.reference_updates(claim, updated_references, claim_key, claim_index)
        if claim["references"]
        claim["references"].each_with_index do |current_ref, ref_index|
            updated_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
        end
        end
        updated_references
    end

    # helper method for changed references
    def self.handle_changed_references(current_claim, parent_claim, changed_references, added_references, removed_references, claim_key, claim_index)
        current_references = current_claim["references"] ? current_claim["references"] : []
        parent_references = parent_claim["references"] ? parent_claim["references"] : []
    
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
        if !current_references.include?(parent_ref)
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
        if current_reference["snaks"] != parent_reference["snaks"]
            return true
        end
        end
        false
    end

    # helper method for adding qualifiers
    # handles added and removed qualifiers
    def self.qualifier_updates(claim, updated_qualifiers, claim_key, claim_index)
        if claim["qualifiers"]
        qualifiers = claim["qualifiers"]
        qualifiers.each do |qualifier_key, qualifier_values|
            qualifier_values.each_with_index do |qualifier_value, qualifier_index|
            updated_qualifiers << {
            claim_key: claim_key,
            claim_index: claim_index,
            qualifier_key: qualifier_key,
            qualifier_index: qualifier_index
            }
            end
        end
        end
        updated_qualifiers
    end

    # helper method for changed qualifiers
    def self.handle_changed_qualifiers(current_claim, parent_claim, changed_qualifiers, added_qualifiers, removed_qualifiers, claim_key, claim_index)
        current_qualifiers = current_claim["qualifiers"] ? current_claim["qualifiers"] : {}
        parent_qualifiers = parent_claim["qualifiers"] ? parent_claim["qualifiers"] : {}

        current_qualifiers.each do |qualifier_key, qualifier_values|
        qualifier_values.each_with_index do |qualifier_value, qualifier_index|
            if parent_qualifiers.key?(qualifier_key)
            parent = parent_qualifiers[qualifier_key]
            end
            # Check if the qualifier index exists in the parent content
            if !parent.nil?
            parent = parent[qualifier_index]
            # check if the parent claim was changed by comparing the objects first
            if parent != qualifier_value
                # Claim was changed
                changed_qualifiers << {
                claim_key: claim_key,
                claim_index: claim_index,
                qualifier_key: qualifier_key,
                qualifier_index: qualifier_index
                }
            end
            else
            # Claim was added
            added_qualifiers << {
                claim_key: claim_key,
                claim_index: claim_index,
                qualifier_key: qualifier_key,
                qualifier_index: qualifier_index
            }
            end
        end
        end
        # Check for removed claims
        parent_qualifiers.each do |qualifier_key, qualifier_values|
        qualifier_values.each_with_index do |qualifier_value, qualifier_index|
            if current_qualifiers.key?(qualifier_key)
            current = current_qualifiers[qualifier_key]
            end
            # Check if the qualifier index exists in the current content
            if !current.nil?
            current = current[qualifier_index]
            end
            if current.nil?
            # Claim was removed
            removed_qualifiers << {
                claim_key: claim_key,
                claim_index: claim_index,
                qualifier_key: qualifier_key,
                qualifier_index: qualifier_index
            }
            end
        end
        end

        {
        added_qualifiers: added_qualifiers,
        removed_qualifiers: removed_qualifiers,
        changed_qualifiers: changed_qualifiers
        }
    end
end