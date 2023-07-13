class SenseAnalyzer
    def self.isolate_senses_differences(current_content, parent_content)
         # Initialize empty arrays to store the added, removed, and changed claims
         added_senses = []
         removed_senses = []
         changed_senses = []
 
         current_content_senses = current_content["senses"] if current_content
         parent_content_senses = parent_content["senses"] if parent_content
 
         if !current_content_senses.is_a?(Array) || !parent_content_senses.is_a?(Array)
         return {
             added: added_senses,
             removed: removed_senses,
             changed: changed_senses
         }
         end
 
         current_content_senses = current_content["senses"] || []
         parent_content_senses = parent_content["senses"] || []
         
         # if parentid is 0, add all current claims as added claims and return it
         if parent_content.nil?
            current_content_senses.each_with_index do |current_claim, index|
                 added_senses << { index: index }
             end
         else
            current_content_senses.each_with_index do |current_claim, index|
                 parent_claim = parent_content_senses[index]
                 if parent_claim.nil?
                     # Claim was added
                     added_senses << { index: index }
                 elsif current_claim != parent_claim
                     # Claim was changed
                     changed_senses << { index: index }
                 end
             end
         end
 
         # Iterate over each claim key in the parent content
         parent_content_senses.each_with_index do |parent_claim, index|
             current_claim = current_content_senses[index]
             if current_claim.nil?
                 # Claim was removed
                 removed_senses << { index: index }
             end
         end
         {
            added: added_senses,
            removed: removed_senses,
            changed: changed_senses
         }
    end
end