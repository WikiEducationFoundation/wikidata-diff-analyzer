class DescriptionAnalyzer  
    def self.isolate_descriptions_differences(current_content, parent_content)
        return {
        changed_descriptions: [],
        removed_descriptions: [],
        added_descriptions: []
        } if current_content.nil? && parent_content.nil?

        if current_content
            current_descriptions = current_content['descriptions']
            if current_descriptions.nil? || current_descriptions.is_a?(Array)
                current_descriptions = {}
            end
        else
            current_descriptions = {}
        end
    
        
        if parent_content
            parent_descriptions = parent_content['descriptions']
            if parent_descriptions.nil? || parent_descriptions.is_a?(Array)
                parent_descriptions = {}
            end
        else
            parent_descriptions = {}
        end
    
        changed_descriptions = []    # Initialize as an array
        removed_descriptions = []    # Initialize as an array
        added_descriptions = []      # Initialize as an array


        # if parentid is 0, add all current description as added and return it
        if parent_content.nil?
            if !current_descriptions.empty?
                current_descriptions.each do |lang, description|
                    added_descriptions << { lang: lang }
                end
            end
            return {
                changed_descriptions: changed_descriptions,
                removed_descriptions: removed_descriptions,
                added_descriptions: added_descriptions
            }
        else
            # Iterate over each language in the current descriptions
            (current_descriptions).each do |lang, current_description|
                # checking if the parent descriptions is empty
                if parent_descriptions.empty?
                    added_descriptions << { lang: lang }
                elsif parent_descriptions[lang].nil?
                    added_descriptions << { lang: lang }
                elsif current_description != parent_descriptions[lang]
                    changed_descriptions << { lang: lang }
                end
            end
            
                # Iterate over each language in the parent descriptions to find removed descriptions
            (parent_descriptions).each do |lang, parent_description|
                if current_descriptions.empty?
                    removed_descriptions << { lang: lang }
                end
            end
        end
        {
            changed_descriptions: changed_descriptions,
            removed_descriptions: removed_descriptions,
            added_descriptions: added_descriptions
        }
    end
end