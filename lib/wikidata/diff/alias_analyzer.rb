class AliasAnalyzer
    def self.isolate_aliases_differences(current_content, parent_content)
        return {
        changed: [],
        removed: [],
        added: []
        } if current_content.nil? && parent_content.nil?
    
        current_aliases = current_content['aliases'] || {}
        parent_aliases = parent_content['aliases'] || {}

        changed_aliases = []
        removed_aliases = []
        added_aliases = []
    
        if current_aliases.is_a?(Array) || parent_aliases.is_a?(Array)
        return {
        changed: changed_aliases,
        removed: removed_aliases,
        added: added_aliases
        }
        end
    
        # Iterate over each language in the current aliases
        (current_aliases || {}).each do |lang, current_aliases_arr|
        parent_aliases_arr = parent_aliases[lang]
    
        # Check if the language exists in the parent aliases
        if parent_aliases_arr
            # Ensure that current_aliases_arr is always an array
            current_aliases_arr = [current_aliases_arr] unless current_aliases_arr.is_a?(Array)
    
            current_aliases_arr.each_with_index do |current_alias, index|
            parent_alias = parent_aliases_arr[index]
            if parent_alias.nil?
                added_aliases << { lang: lang, index: index }
            elsif current_alias != parent_alias
                changed_aliases << { lang: lang, index: index }
            end
            end
        else
            # Ensure that current_aliases_arr is always an array
            current_aliases_arr = [current_aliases_arr] unless current_aliases_arr.is_a?(Array)
    
            current_aliases_arr.each_with_index do |current_alias, index|
            added_aliases << { lang: lang, index: index }
            end
        end
        end
    
        # Iterate over each language in the parent aliases to find removed aliases
        (parent_aliases || {}).each do |lang, parent_aliases_arr|
        # Ensure that parent_aliases_arr is always an array
        parent_aliases_arr = [parent_aliases_arr] unless parent_aliases_arr.is_a?(Array)
    
        current_aliases_arr = current_aliases[lang]
    
        if current_aliases_arr.nil?
            parent_aliases_arr.each_index do |index|
            removed_aliases << { lang: lang, index: index }
            end
        end
        end
    
        {
        changed: changed_aliases,
        removed: removed_aliases,
        added: added_aliases
        }
    end
end