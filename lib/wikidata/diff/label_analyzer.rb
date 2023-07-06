class LabelAnalyzer
    def self.isolate_labels_differences(current_content, parent_content)
        return {
        changed: [],
        removed: [],
        added: []
        } if current_content.nil? && parent_content.nil?
    
        current_labels = current_content['labels'] || {}
        parent_labels = parent_content['labels'] || {}

        changed_labels = []
        removed_labels = []
        added_labels = []

        if current_labels.is_a?(Array) || parent_labels.is_a?(Array)
        return {
        changed: changed_labels,
        removed: removed_labels,
        added: added_labels
        }
        end

    
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
    
        {
        changed: changed_labels,
        removed: removed_labels,
        added: added_labels
        }
    end
end