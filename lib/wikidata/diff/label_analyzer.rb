class LabelAnalyzer 
      
    def self.isolate_labels_differences(current_content, parent_content)
        return {
        changed_labels: [],
        removed_labels: [],
        added_labels: []
        } if current_content.nil? && parent_content.nil?
        
        if current_content
            current_labels = current_content['labels']
            if current_labels.nil? || current_labels.is_a?(Array)
                current_labels = {}
            end
        else
            current_labels = {}
        end

        if parent_content
            parent_labels = parent_content['labels']
            if parent_labels.nil? || parent_labels.is_a?(Array)
                parent_labels = {}
            end
        else
            parent_labels = {}
        end



        changed_labels_labels = []
        removed_labels_labels = []
        added_labels_labels = []

        # if parentid is 0, then add all labels as added_labels and return it
        if parent_content.nil?  
            if !current_labels.empty?
                current_labels.each do |lang, label|
                    added_labels_labels << { lang: lang }
                end
            end
            return {
                changed_labels: changed_labels_labels,
                removed_labels: removed_labels_labels,
                added_labels: added_labels_labels
            }
        else
            # Iterate over each language in the current labels
            (current_labels).each do |lang, current_label|
                if parent_labels.empty?
                    added_labels_labels << { lang: lang }
                else
                    parent_label = parent_labels[lang]
                    if parent_label.nil?
                        added_labels_labels << { lang: lang }
                    elsif current_label != parent_label
                        changed_labels_labels << { lang: lang }
                    end
                end
            end
            
                # Iterate over each language in the parent labels to find removed_labels labels
                (parent_labels).each do |lang, parent_label|
                if current_labels.empty?
                    removed_labels_labels << { lang: lang }
                end
            end
        end
    
        {
        changed_labels: changed_labels_labels,
        removed_labels: removed_labels_labels,
        added_labels: added_labels_labels
        }
    end
end