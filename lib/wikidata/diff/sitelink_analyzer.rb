class SitelinkAnalyzer
    def self.isolate_sitelinks_differences(current_content, parent_content)
        added_sitelinks = {}
        removed_sitelinks = {}
        changed_sitelinks = {}
      
        # Check if both current and parent content exist
        if current_content && parent_content
          current_sitelinks = current_content['sitelinks']
          parent_sitelinks = parent_content['sitelinks']
      
          # Check added sitelinks
          if current_sitelinks.respond_to?(:each)
            current_sitelinks.each do |site_key, current_sitelink|
              unless parent_sitelinks.respond_to?(:key?) && parent_sitelinks.key?(site_key)
                added_sitelinks[site_key] = current_sitelink
              end
            end
          end
    
          # Check removed sitelinks
          if parent_sitelinks.respond_to?(:each)
            parent_sitelinks.each do |site_key, parent_sitelink|
              unless current_sitelinks.respond_to?(:key?) && current_sitelinks.key?(site_key)
                removed_sitelinks[site_key] = parent_sitelink
              end
            end
          end
          # Check changed sitelinks
          if current_sitelinks && parent_sitelinks
            current_sitelinks.each do |site_key, current_sitelink|
              if parent_sitelinks.respond_to?(:key?) && parent_sitelinks.key?(site_key)
                parent_sitelink = parent_sitelinks[site_key]
                if current_sitelink != parent_sitelink
                  changed_sitelinks[site_key] = {
                    current: current_sitelink,
                    parent: parent_sitelink
                  }
                end
              end
            end
          end
        elsif current_content
          # All sitelinks are added if parent content is nil
          added_sitelinks = current_content['sitelinks']
        elsif parent_content
          # All sitelinks are removed if current content is nil
          removed_sitelinks = parent_content['sitelinks']
        end
    
        {
          added_sitelinks: added_sitelinks,
          removed_sitelinks: removed_sitelinks,
          changed_sitelinks: changed_sitelinks
        }
    end
end 