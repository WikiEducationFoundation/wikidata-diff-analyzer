class FormAnalyzer
    def self.isolate_forms_differences(current_content, parent_content)
        # Initialize empty arrays to store the added, removed, and changed claims
        added_forms = []
        removed_forms = []
        changed_forms = []

        current_content_forms = current_content["forms"] if current_content
        parent_content_forms = parent_content["forms"] if parent_content

        if !current_content_forms.is_a?(Array) || !parent_content_forms.is_a?(Array)
        return {
            added: added_forms,
            removed: removed_forms,
            changed: changed_forms
        }
        end

        current_content_forms = current_content["forms"] || []
        parent_content_forms = parent_content["forms"] || []
        
        # if parentid is 0, add all current claims as added claims and return it
        if parent_content.nil?
            current_content_forms.each_with_index do |current_claim, index|
                added_forms << { index: index }
            end
        else
            current_content_forms.each_with_index do |current_claim, index|
                parent_claim = parent_content_forms[index]
                if parent_claim.nil?
                    # Claim was added
                    added_forms << { index: index }
                elsif current_claim != parent_claim
                    # Claim was changed
                    changed_forms << { index: index }
                end
            end
        end

        # Iterate over each claim key in the parent content
        parent_content_forms.each_with_index do |parent_claim, index|
            current_claim = current_content_forms[index]
            if current_claim.nil?
                # Claim was removed
                removed_forms << { index: index }
            end
        end
        {
            added: added_forms,
            removed: removed_forms,
            changed: changed_forms
        }
    end
end