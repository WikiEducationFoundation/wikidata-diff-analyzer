class DescriptionAnalyzer
    def self.isolate_descriptions_differences(current_content, parent_content)
        return {
        changed: [],
        removed: [],
        added: []
        } if current_content.nil? && parent_content.nil?
    
        current_descriptions = (current_content['descriptions'] || {}) if current_content
        parent_descriptions = (parent_content['descriptions'] || {}) if parent_content

    
        changed_descriptions = []    # Initialize as an array
        removed_descriptions = []    # Initialize as an array
        added_descriptions = []      # Initialize as an array
    
        if !current_descriptions.is_a?(Hash) || !parent_descriptions.is_a?(Hash)
        return{
            changed: changed_descriptions,
            removed: removed_descriptions,
            added: added_descriptions
        }
        end

        # if parentid is 0, add all current description as added and return it
        if parent_content.nil?
            current_descriptions.each do |lang, description|
                added_descriptions << { lang: lang }
            end
            return {
                changed: changed_descriptions,
                removed: removed_descriptions,
                added: added_descriptions
            }
        else
            # Iterate over each language in the current descriptions
            (current_descriptions || {}).each do |lang, current_description|
                parent_description = parent_descriptions[lang]
            
                if parent_description.nil?
                    added_descriptions << { lang: lang }
                elsif current_description != parent_description
                    changed_descriptions << { lang: lang }
                end
                end
            
                # Iterate over each language in the parent descriptions to find removed descriptions
                (parent_descriptions || {}).each do |lang, parent_description|
                if current_descriptions[lang].nil?
                    removed_descriptions << { lang: lang }
                end
            end
        end
        {
            changed: changed_descriptions,
            removed: removed_descriptions,
            added: added_descriptions
        }
    end
end