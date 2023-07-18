class RepresentationAnalyzer
    def self.isolate_representation_differences(current_content, parent_content)
        return {
        changed: [],
        removed: [],
        added: []
        } if current_content.nil? && parent_content.nil?
    
        current_representations = (current_content['representations'] || {}) if current_content
        if parent_content
            parent_representations = parent_content['representations'] 
        else
            parent_representations = {}
        end

        changed = []
        removed = []
        added = []

        if current_representations.is_a?(Array) ||  parent_representations.is_a?(Array)
        return {
        changed: changed,
        removed: removed,
        added: added
        }
        end

        # if parentid is 0, then add all labels as added and return it
        if parent_content.nil?
            current_representations.each do |lang, label|
                added << { lang: lang }
            end
            return {
                changed: changed,
                removed: removed,
                added: added
            }
        else

        
            # Iterate over each language in the current labels
            (current_representations || {}).each do |lang, current_representation|
                parent_representation =  parent_representations[lang]
            
                if parent_representation.nil?
                    added << { lang: lang }
                elsif current_representation != parent_representation
                    changed << { lang: lang }
                end
                end
            
                # Iterate over each language in the parent labels to find removed labels
            (parent_representations || {}).each do |lang, parent_representation|
                if current_representations[lang].nil?
                    removed << { lang: lang }
                end
            end
        end
    
        {
        changed: changed,
        removed: removed,
        added: added
        }
    end
end