class GlossAnalyzer
    def self.isolate_glosses_differences(current_content, parent_content)
        return {
        changed: [],
        removed: [],
        added: []
        } if current_content.nil? && parent_content.nil?
    
        current_glosses = (current_content['glosses'] || {}) if current_content
        if parent_content
            parent_glosses = parent_content['glosses'] 
        else
            parent_glosses = {}
        end

        changed = []
        removed = []
        added = []

        if current_glosses.is_a?(Array)
        return {
        changed: changed,
        removed: removed,
        added: added
        }
        end

        # if parentid is 0, then add all labels as added and return it
        if parent_content.nil?
            current_glosses.each do |lang, label|
                added << { lang: lang }
            end
            return {
                changed: changed,
                removed: removed,
                added: added
            }
        else

        
            # Iterate over each language in the current labels
            (current_glosses || {}).each do |lang, current_gloss|
                parent_gloss = parent_glosses[lang]
            
                if parent_gloss.nil?
                    added << { lang: lang }
                elsif current_gloss != parent_gloss
                    changed << { lang: lang }
                end
            end
            
                # Iterate over each language in the parent labels to find removed labels
            (parent_glosses || {}).each do |lang, parent_gloss|
                if current_glosses[lang].nil?
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