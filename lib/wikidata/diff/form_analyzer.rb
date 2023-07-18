require_relative 'representation_analyzer'
require_relative 'inside_claim_analyzer'
class FormAnalyzer
    def self.isolate_forms_differences(current_content, parent_content)
        # Initialize empty arrays to store the added, removed, and changed claims
        added_forms = []
        removed_forms = []
        changed_forms = []
        added_representations = []
        removed_representations = []
        changed_representations = []
        added_formclaims = []
        removed_formclaims = []
        changed_formclaims = []

        current_content_forms = current_content["forms"] if current_content
        parent_content_forms = parent_content["forms"] if parent_content

        if !current_content_forms.is_a?(Array)
        return {
            added: added_forms,
            removed: removed_forms,
            changed: changed_forms,
            added_representations: added_representations,
            removed_representations: removed_representations,
            changed_representations: changed_representations,
            added_formclaims: added_formclaims,
            removed_formclaims: removed_formclaims,
            changed_formclaims: changed_formclaims
        }
        end

        if parent_content.nil?
            parent_content_forms = []
        else
            parent_content_forms = parent_content["forms"] || []
        end
        
        # if parentid is 0, add all current claims as added claims and return it
        if parent_content.nil?
            current_content_forms.each_with_index do |current_form, index|
                added_forms << { index: index }
                representations = RepresentationAnalyzer.isolate_representation_differences(current_form, nil)
                added_representations += representations[:added]
                removed_representations += representations[:removed]
                changed_representations += representations[:changed]
                formclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_form, nil)
                added_formclaims += formclaims[:added]
                removed_formclaims += formclaims[:removed]
                changed_formclaims += formclaims[:changed]
            end
        else
            current_content_forms.each_with_index do |current_form, index|
            parent_form = parent_content_forms[index]
                if parent_form.nil?
                    # Claim was added
                    added_forms << { index: index }
                    representations = RepresentationAnalyzer.isolate_representation_differences(current_form, parent_form)
                    added_representations += representations[:added]
                    removed_representations += representations[:removed]
                    changed_representations += representations[:changed]
                    formclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_form, parent_form)
                    added_formclaims += formclaims[:added]
                    removed_formclaims += formclaims[:removed]
                    changed_formclaims += formclaims[:changed]
                elsif current_form
                    # Claim was changed
                    changed_forms << { index: index }
                    representations = RepresentationAnalyzer.isolate_representation_differences(current_form, parent_form)
                    added_representations += representations[:added]
                    removed_representations += representations[:removed]
                    changed_representations += representations[:changed]
                    formclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_form, parent_form)
                    added_formclaims += formclaims[:added]
                    removed_formclaims += formclaims[:removed]
                    changed_formclaims += formclaims[:changed]
                end
            end
        end

        # Iterate over each claim key in the parent content
        parent_content_forms.each_with_index do |parent_form, index|
            current_form = current_content_forms[index]
            if current_form.nil?
                # Claim was removed
                removed_forms << { index: index }
                representations = RepresentationAnalyzer.isolate_representation_differences(current_form, parent_form)
                    added_representations += representations[:added]
                    removed_representations += representations[:removed]
                    changed_representations += representations[:changed]
                formclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_form, parent_form)
                    added_formclaims += formclaims[:added]
                    removed_formclaims += formclaims[:removed]
                    changed_formclaims += formclaims[:changed]
            end
        end
        {
            added: added_forms,
            removed: removed_forms,
            changed: changed_forms,
            added_representations: added_representations,
            removed_representations: removed_representations,
            changed_representations: changed_representations,
            added_formclaims: added_formclaims,
            removed_formclaims: removed_formclaims,
            changed_formclaims: changed_formclaims
        }
    end
end
