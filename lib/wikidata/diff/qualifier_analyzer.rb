class QualifierAnalyzer
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