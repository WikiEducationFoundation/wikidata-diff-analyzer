# frozen_string_literal: true

class AliasAnalyzer
  def self.isolate_aliases_differences(current_content, parent_content)
    if current_content.nil? && parent_content.nil?
      return {
        changed_aliases: [],
        removed_aliases: [],
        added_aliases: []
      }
    end

    changed_aliases = []
    removed_aliases = []
    added_aliases = []

    if current_content
      current_aliases = current_content['aliases']
      current_aliases = {} if current_aliases.nil? || current_aliases.is_a?(Array)
    else
      current_aliases = {}
    end

    if parent_content
      parent_aliases = parent_content['aliases']
      parent_aliases = {} if parent_aliases.nil? || parent_aliases.is_a?(Array)
    else
      parent_aliases = {}
    end

    if parent_content.nil?
      (current_aliases || {}).each do |lang, current_aliases_arr|
        current_aliases_arr = [current_aliases_arr] unless current_aliases_arr.is_a?(Array)

        current_aliases_arr.each_with_index do |_current_alias, index|
          added_aliases << { lang: lang, index: index }
        end
      end
    else
      # Iterate over each language in the current aliases
      (current_aliases || {}).each do |lang, current_aliases_arr|
        parent_aliases_arr = parent_aliases[lang]

        # Check if the language exists in the parent aliases
        current_aliases_arr = [current_aliases_arr] unless current_aliases_arr.is_a?(Array)
        if parent_aliases_arr
          # Ensure that current_aliases_arr is always an array

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

          current_aliases_arr.each_with_index do |_current_alias, index|
            added_aliases << { lang: lang, index: index }
          end
        end
      end

      # Iterate over each language in the parent aliases to find removed aliases
      (parent_aliases || {}).each do |lang, parent_aliases_arr|
        # Ensure that parent_aliases_arr is always an array
        parent_aliases_arr = [parent_aliases_arr] unless parent_aliases_arr.is_a?(Array)

        current_aliases_arr = current_aliases[lang]

        next unless current_aliases_arr.nil?

        parent_aliases_arr.each_index do |index|
          removed_aliases << { lang: lang, index: index }
        end
      end
    end
    {
      changed_aliases: changed_aliases,
      removed_aliases: removed_aliases,
      added_aliases: added_aliases
    }
  end
end
