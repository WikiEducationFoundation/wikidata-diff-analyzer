require_relative 'gloss_analyzer'
require_relative 'inside_claim_analyzer'
class SenseAnalyzer
    def self.isolate_senses_differences(current_content, parent_content)
         # Initialize empty arrays to store the added, removed, and changed claims
         added_senses = []
         removed_senses = []
         changed_senses = []
         added_glosses = []
         removed_glosses = []
         changed_glosses = []
         added_senseclaims = []
         removed_senseclaims = []
         changed_senseclaims = []
 
         current_content_senses = current_content["senses"] if current_content
         parent_content_senses = parent_content["senses"] if parent_content
 
         if !current_content_senses.is_a?(Array) || !parent_content_senses.is_a?(Array)
         return {
            added: added_senses,
            removed: removed_senses,
            changed: changed_senses,
            added_glosses: added_glosses,
            removed_glosses: removed_glosses,
            changed_glosses: changed_glosses,
            added_senseclaims: added_senseclaims,
            removed_senseclaims: removed_senseclaims,
            changed_senseclaims: changed_senseclaims
         }
         end
 
         current_content_senses = current_content["senses"] || []
         parent_content_senses = parent_content["senses"] || []
         
         # if parentid is 0, add all current claims as added claims and return it
         if parent_content.nil?
            current_content_senses.each_with_index do |current_claim, index|
                 added_senses << { index: index }
                 glosses = GlossAnalyzer.isolate_gloss_differences(current_claim, nil)
                 added_glosses += glosses[:added]
                 removed_glosses += glosses[:removed]
                 changed_glosses += glosses[:changed]
                 senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_claim, nil)
                 added_senseclaims += senseclaims[:added]
                 removed_senseclaims += senseclaims[:removed]
                 changed_senseclaims += senseclaims[:changed]
            end
         else
            current_content_senses.each_with_index do |current_claim, index|
                 parent_claim = parent_content_senses[index]
                 if parent_claim.nil?
                     # Claim was added
                    added_senses << { index: index }
                    glosses = GlossAnalyzer.isolate_gloss_differences(current_claim, parent_claim)
                    added_glosses += glosses[:added]
                    removed_glosses += glosses[:removed]
                    changed_glosses += glosses[:changed]
                    senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_claim, nil)
                    added_senseclaims += senseclaims[:added]
                    removed_senseclaims += senseclaims[:removed]
                    changed_senseclaims += senseclaims[:changed]
                 elsif current_claim != parent_claim
                     # Claim was changed
                     changed_senses << { index: index }
                     glosses = GlossAnalyzer.isolate_gloss_differences(current_claim, parent_claim)
                    added_glosses += glosses[:added]
                    removed_glosses += glosses[:removed]
                    changed_glosses += glosses[:changed]
                    senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_claim, nil)
                    added_senseclaims += senseclaims[:added]
                    removed_senseclaims += senseclaims[:removed]
                    changed_senseclaims += senseclaims[:changed]
                 end
             end
         end
 
         # Iterate over each claim key in the parent content
         parent_content_senses.each_with_index do |parent_claim, index|
             current_claim = current_content_senses[index]
             if current_claim.nil?
                # Claim was removed
                removed_senses << { index: index }
                glosses = GlossAnalyzer.isolate_gloss_differences(current_claim, parent_claim)
                added_glosses += glosses[:added]
                removed_glosses += glosses[:removed]
                changed_glosses += glosses[:changed]
                senseclaims = InsideClaimAnalyzer.isolate_inside_claim_differences(current_claim, nil)
                added_senseclaims += senseclaims[:added]
                removed_senseclaims += senseclaims[:removed]
                changed_senseclaims += senseclaims[:changed]
             end
         end
         {
            added: added_senses,
            removed: removed_senses,
            changed: changed_senses,
            added_glosses: added_glosses,
            removed_glosses: removed_glosses,
            changed_glosses: changed_glosses,
            added_senseclaims: added_senseclaims,
            removed_senseclaims: removed_senseclaims,
            changed_senseclaims: changed_senseclaims
         }
    end
end