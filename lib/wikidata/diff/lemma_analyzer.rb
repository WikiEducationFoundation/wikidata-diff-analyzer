class LemmaAnalyzer
    def self.isolate_lemmas_differences(current_content, parent_content)
        return {
        changed_lemmas: [],
        removed_lemmas: [],
        added_lemmas: []
        } if current_content.nil? && parent_content.nil?
    
        
        if current_content
            current_labels = current_content['lemmas']
            if current_labels.nil? || current_labels.is_a?(Array)
                current_labels = {}
            end
        else
            current_labels = {}
        end
        if parent_content
            parent_labels = parent_content['lemmas'] 
            if parent_labels.nil? || parent_labels.is_a?(Array)
                parent_labels = {}
            end
        else
            parent_labels = {}
        end

        changed_labels = []
        removed_labels = []
        added_labels = []


        # if parentid is 0, then add all labels as added and return it
        if parent_content.nil?
            current_labels.each do |lang, label|
                added_labels << { lang: lang }
            end
            return {
                changed_lemmas: changed_labels,
                removed_lemmas: removed_labels,
                added_lemmas: added_labels
            }
        else

        
            # Iterate over each language in the current labels
            (current_labels || {}).each do |lang, current_label|
                parent_label = parent_labels[lang]
            
                if parent_label.nil?
                    added_labels << { lang: lang }
                elsif current_label != parent_label
                    changed_labels << { lang: lang }
                end
                end
            
                # Iterate over each language in the parent labels to find removed labels
                (parent_labels || {}).each do |lang, parent_label|
                if current_labels[lang].nil?
                    removed_labels << { lang: lang }
                end
            end
        end
    
        {
        changed_lemmas: changed_labels,
        removed_lemmas: removed_labels,
        added_lemmas: added_labels
        }
    end
end