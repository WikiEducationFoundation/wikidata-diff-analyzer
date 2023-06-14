# frozen_string_literal: true

require 'json'
require 'mediawiki_api'

module WikidataDiffAnalyzer
  class Error < StandardError; end

# This method retrieves the content of a specific revision from the Wikidata API.
# It takes a revision ID as input and returns the parsed content as a Ruby object.
  def self.get_revision_content(revision_id)
    api_url = 'https://www.wikidata.org/w/api.php'

    client = MediawikiApi::Client.new(api_url)
    begin
      response = client.action(
        'query',
        prop: 'revisions',
        revids: revision_id,
        rvslots: 'main',
        rvprop: 'content',
        format: 'json'
      )

      if response.nil?
        puts "No response received for revision ID: #{revision_id}"
        return nil
      end

      # Get the page ID and revisions from the response
      page_id = response.data['pages'].keys.first
      revisions = response.data['pages'][page_id]['revisions']
      first_revision = revisions[0]

      # Get the content of the first revision
      content = first_revision['slots']['main']['*']

      # Parse the content as JSON
      parsed_content = JSON.parse(content)

      # Return the parsed content
      return parsed_content
    rescue MediawikiApi::ApiError => e
      puts "Error retrieving revision content: #{e.message}"
      return nil
    rescue JSON::ParserError => e
      puts "Error parsing JSON content: #{e.message}"
      puts "Content: #{content}"
      raise e
    end
  end


  def self.isolate_claim_differences(current_content, parent_content)
    # Initialize empty arrays to store the added, removed, and changed claims
    added_claims = []
    removed_claims = []
    changed_claims = []
  
    if current_content.nil? && parent_content.nil?
      # Both current and parent content are nil, no changes
      return {
        added: added_claims,
        removed: removed_claims,
        changed: changed_claims
      }
    elsif current_content.nil?
      # Only current content is nil, consider all claims in parent content as removed
      parent_content["claims"].each do |claim_key, parent_claims|
        parent_claims.each_index do |index|
          removed_claims << { key: claim_key, index: index }
        end
      end
    elsif parent_content.nil?
      # Only parent content is nil, consider all claims in current content as added
      current_content["claims"].each do |claim_key, current_claims|
        current_claims.each_index do |index|
          added_claims << { key: claim_key, index: index }
        end
      end
    else
      # Iterate over each claim key in the current content
      current_content["claims"].each do |claim_key, current_claims|
        # Check if the claim key exists in the parent content
        if parent_content["claims"].key?(claim_key)
          parent_claims = parent_content["claims"][claim_key]
          # Iterate over each claim in the current and parent content
          current_claims.each_with_index do |current_claim, index|
            parent_claim = parent_claims[index]
            if parent_claim.nil?
              # Claim was added
              added_claims << { key: claim_key, index: index }
            elsif current_claim != parent_claim
              # Claim was changed
              changed_claims << { key: claim_key, index: index }
            end
          end
          # Check for removed claims
          parent_claims.each_with_index do |parent_claim, index|
            current_claim = current_claims[index]
            if current_claim.nil?
              # Claim was removed
              removed_claims << { key: claim_key, index: index }
            end
          end
        else
          # All claims in current content with this key were added
          current_claims.each_index do |index|
            added_claims << { key: claim_key, index: index }
          end
        end
      end
  
      parent_content["claims"].each do |claim_key, parent_claims|
        # current content[claims] can be nil
        if current_content["claims"].nil? 
          parent_claims.each_index do |index|
            removed_claims << { key: claim_key, index: index }
          end
        else
          if !current_content["claims"].key?(claim_key)
            parent_claims.each_index do |index|
              removed_claims << { key: claim_key, index: index }
            end
          end
        end
      end
    end
  
    puts "Added claims: #{added_claims}"
    puts "Removed claims: #{removed_claims}"
    puts "Changed claims: #{changed_claims}"

    {
      added: added_claims,
      removed: removed_claims,
      changed: changed_claims
    }
  end

# Refactored Version
  # def self.isolate_claim_differences(current_content, parent_content)
  #   added_claims = []
  #   removed_claims = []
  #   changed_claims = []
  
  #   return { added: added_claims, removed: removed_claims, changed: changed_claims } if current_content.nil? && parent_content.nil?
  
  #   current_content ||= { "claims" => {} }
  #   parent_content ||= { "claims" => {} }
  
  #   all_claim_keys = (current_content["claims"].keys + parent_content["claims"].keys).uniq
  
  #   all_claim_keys.each do |claim_key|
  #     current_claims = current_content["claims"][claim_key] || []
  #     parent_claims = parent_content["claims"][claim_key] || []
  
  #     current_claims.each_with_index do |current_claim, index|
  #       parent_claim = parent_claims[index]
  
  #       if parent_claim.nil?
  #         added_claims << { key: claim_key, index: index }
  #       elsif current_claim != parent_claim
  #         changed_claims << { key: claim_key, index: index }
  #       end
  #     end
  
  #     parent_claims.each_with_index do |parent_claim, index|
  #       current_claim = current_claims[index]
  
  #       if current_claim.nil?
  #         removed_claims << { key: claim_key, index: index }
  #       elsif !current_claims.include?(parent_claim)
  #         added_claims << { key: claim_key, index: index }
  #       end
  #     end
  #   end
  
  #   puts "added_claims: #{added_claims}"
  #   puts "removed_claims: #{removed_claims}"
  #   puts "changed_claims: #{changed_claims}"

  #   {
  #     added: added_claims,
  #     removed: removed_claims,
  #     changed: changed_claims
  #   }
  # end
  
  


# This method counts the total number of claims in the provided content.

# It takes the parsed content as input and returns the count of claims.
  def self.count_claims(content)
    return 0 if content.nil?

    claims = content['claims']

    # Check if claims exist in the content
    if claims
      # Count the number of elements inside the arrays in claims
      claims_lengths = claims.map { |key, value| value.length }
      total_length = claims_lengths.reduce(0) { |sum, length| sum + length }
      return total_length
    else
      # If no claims exist, return 0
      return 0
    end
  end

  def self.isolate_reference_differences(current_content, parent_content)
    added_references = []
    removed_references = []
    modified_references = []
  
    claim_differences = isolate_claim_differences(current_content, parent_content)
    added_claims = claim_differences[:added]
    removed_claims = claim_differences[:removed]
    changed_claims = claim_differences[:changed]

    added_claims.each do |claim|
      claim_key = claim[:key]
      claim_index = claim[:index]

      current_references = current_content["claims"]&.dig(claim_key, claim_index, "references") || []

      current_references.each_with_index do |current_ref, ref_index|
        added_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      end
    end

    removed_claims.each do |claim|
      claim_key = claim[:key]
      claim_index = claim[:index]
      parent_reference = parent_content["claims"]&.dig(claim_key, claim_index, "references") || []

      parent_reference.each_with_index do |current_ref, ref_index|
        removed_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      end
    end
  
    changed_claims.each do |claim|
      claim_key = claim[:key]
      claim_index = claim[:index]
  
      current_references = current_content["claims"]&.dig(claim_key, claim_index, "references") || []
      parent_references = parent_content["claims"]&.dig(claim_key, claim_index, "references") || []
  
      current_references.each_with_index do |current_ref, ref_index|
        if parent_references.empty?
          added_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
        elsif !parent_references.include?(current_ref)
          added_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
        elsif ref_modified?(current_ref, parent_references)
          modified_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
        end
      end
  
      parent_references.each_with_index do |parent_ref, ref_index|
        if !current_references.include?(parent_ref)
          removed_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
        end
      end
    end
  
    puts "Added references: #{added_references}"
    puts "Removed references: #{removed_references}"
    puts "Modified references: #{modified_references}"
  
    { added: added_references, removed: removed_references, changed: modified_references }
  end
  
  def self.ref_modified?(current_reference, parent_references)
    parent_references.each do |parent_reference|
      if current_reference["snaks"] != parent_reference["snaks"]
        return true
      end
    end
    false
  end
  
# This method counts the total number of references in the claims of the provided content.
  def self.count_references(content)
    # https://www.wikidata.org/w/api.php?action=query&prop=revisions&revids=1596238100&rvslots=main&rvprop=content&format=json
    # Example claim P19 has 1 reference:
    # {
    #   "P19": [
    #     {
    #       "mainsnak": {
    #         ...
    #        },
    #       "type": "statement",
    #       "qualifiers": {
    #         ...
    #        },
    #       "qualifiers-order": ["P17"],
    #       "id": "Q111269579$8433a7ee-4e09-77aa-b472-7443d613d8fa",
    #       "rank": "normal",
    #       "references": [
    #         {
    #           "hash": "4c89fc0f26ea4ca4e70c64cb352f42843c5f0900",
    #           "snaks": {
    #             "P854": [
    #               {
    #                 "snaktype": "value",
    #                 "property": "P854",
    #                 "hash": "3260bea98a52f32c3a30041a3bd4dfe1dfb36cda",
    #                 "datavalue": {
    #                   "value": "https://trinidadexpress.com/opinion/columnists/ryan-recalls/article_8fe3c130-118e-11ea-b3e0-7fa49653edde.html",
    #                   "type": "string"
    #                 }
    #               }
    #             ]
    #           },
    #           "snaks-order": ["P854"]
    #         }
    #       ]
    #     }
    #   ]
    # }


    return 0 if content.nil?

    claims = content['claims']
    return 0 unless claims.is_a?(Hash)
  
    references_count = 0
  
    # Iterate over the values of the claims hash
    claims.values.each do |values|
    # Check if values is an array
      if values.is_a?(Array)
      # Iterate over each value
        values.each do |value|
        # Check if the value has references and if references is an array
          if value.key?('references') && value['references'].is_a?(Array)
          # Increment the references count by the length of the references array
            references_count += value['references'].length
          end
        end
      end
    end
    references_count
  end  
# This method isolates the differences in qualifiers between two revisions of content.
def self.isolate_qualifiers_differences(current_content, parent_content)
  added_qualifiers = []
  removed_qualifiers = []
  changed_qualifiers = []

  # Process added and removed claims
  claim_diff = isolate_claim_differences(current_content, parent_content)
  added_claims = claim_diff[:added]
  removed_claims = claim_diff[:removed]

  added_claims.each do |claim|
    claim_key = claim[:key]
    claim_index = claim[:index]
    qualifiers = current_content["claims"]&.dig(claim_key, claim_index, "qualifiers") || {}

    qualifiers.each do |qualifier_key, qualifier_values|
      qualifier_values.each_with_index do |qualifier_value, qualifier_index|
        added_qualifiers << {
        claim_key: claim_key,
        claim_index: claim_index,
        qualifier_key: qualifier_key,
        qualifier_index: qualifier_index
        }
      end
    end
  end

  removed_claims.each do |claim|
    claim_key = claim[:key]
    claim_index = claim[:index]
    qualifiers = parent_content["claims"]&.dig(claim_key, claim_index, "qualifiers") || {}

    qualifiers.each do |qualifier_key, qualifier_values|
      qualifier_values.each_with_index do |qualifier_value, qualifier_index|
        removed_qualifiers << {
        claim_key: claim_key,
        claim_index: claim_index,
        qualifier_key: qualifier_key,
        qualifier_index: qualifier_index
        }
      end
    end
  end

  # Process changed claims
  changed_claims = claim_diff[:changed]

  changed_claims.each do |claim|
    claim_key = claim[:key]
    claim_index = claim[:index]
    current_qualifiers = current_content["claims"]&.dig(claim_key, claim_index, "qualifiers") || {}
    parent_qualifiers = parent_content["claims"]&.dig(claim_key, claim_index, "qualifiers") || {}

    # Iterate over each claim key in the current content
    current_qualifiers.each do |qualifier_key, qualifier_values|
      qualifier_values.each_with_index do |qualifier_value, qualifier_index|
        if parent_qualifiers.key?(qualifier_key)
          parent = parent_qualifiers[key]
        end
        # Check if the qualifier index exists in the parent content
        if !parent.nil?
          parent = parent[qualifier_index]
        end
        if !parent.nil?
          # Claim was changed
          changed_qualifiers << {
            claim_key: claim_key,
            claim_index: claim_index,
            qualifier_key: qualifier_key,
            qualifier_index: qualifier_index
          }
        else
          # Claim was added
          added_qualifiers << {
            claim_key: claim_key,
            claim_index: claim_index,
            qualifier_key: qualifier_key,
            qualifier_index: qualifier_index
          }
        end
      end
    end
    # Check for removed claims
    parent_qualifiers.each do |qualifier_key, qualifier_values|
      qualifier_values.each_with_index do |qualifier_value, qualifier_index|
        if current_qualifiers.key?(qualifier_key)
          current = current_qualifiers[qualifier_key]
        end
        # Check if the qualifier index exists in the current content
        if !current.nil?
          current = current[qualifier_index]
        end
        if current.nil?
          # Claim was removed
          removed_qualifiers << {
            claim_key: claim_key,
            claim_index: claim_index,
            qualifier_key: qualifier_key,
            qualifier_index: qualifier_index
          }
        end
      end
    end
  end


  puts "added_qualifiers: #{added_qualifiers}"
  puts "removed_qualifiers: #{removed_qualifiers}"
  puts "changed_qualifiers: #{changed_qualifiers}"

  {
    added: added_qualifiers,
    removed: removed_qualifiers,
    changed: changed_qualifiers
  }
end

# This method counts the total number of qualifiers in the claims of the provided content.
# It takes one argument:
# - content: a hash representing the content to count the qualifiers of
# It returns an integer representing the total number of qualifiers in the content.
def self.count_qualifiers(content)
  return 0 if content.nil?

  claims = content['claims']
  return 0 unless claims.is_a?(Hash)

  qualifiers_count = 0

  # Iterate over the values of the claims hash
  claims.values.each do |values|
    # Check if values is an array
    if values.is_a?(Array)
      # Iterate over each value
      values.each do |value|
        # Check if the value has qualifiers and if qualifiers is a hash
        if value.key?('qualifiers') && value['qualifiers'].is_a?(Hash)
          # Increment the qualifiers count by the length of each array inside the hash
          qualifiers_count += value['qualifiers'].map { |key, value| value.length }.reduce(0) { |sum, length| sum + length }
        end
      end
    end
  end
  return qualifiers_count
end


  def self.isolate_aliases_differences(current_content, parent_content)
    return {} if current_content.nil? && parent_content.nil?
  
    current_aliases = current_content['aliases'] || {}
    parent_aliases = parent_content['aliases'] || {}
  
    changed_aliases = []
    removed_aliases = []
    added_aliases = []
  
    # Iterate over each language in the current aliases
    current_aliases.each do |lang, current_aliases_arr|
      parent_aliases_arr = parent_aliases[lang]
  
      # Check if the language exists in the parent aliases
      if parent_aliases_arr
        current_aliases_arr.each_with_index do |current_alias, index|
          parent_alias = parent_aliases_arr[index]
          if parent_alias.nil?
            added_aliases << { lang: lang, index: index }
          elsif current_alias != parent_alias
            changed_aliases << { lang: lang, index: index }
          end
        end
      else
        current_aliases_arr.each_with_index do |current_alias, index|
          added_aliases << { lang: lang, index: index }
        end
      end
    end
  
    # Iterate over each language in the parent aliases to find removed aliases
    parent_aliases.each do |lang, parent_aliases_arr|
      current_aliases_arr = current_aliases[lang]
  
      if current_aliases_arr.nil?
        parent_aliases_arr.each_index do |index|
          removed_aliases << { lang: lang, index: index }
        end
      end
    end
  
    puts "Changed aliases: #{changed_aliases}"
    puts "Removed aliases: #{removed_aliases}"
    puts "Added aliases: #{added_aliases}"

    {
      changed: changed_aliases,
      removed: removed_aliases,
      added: added_aliases
    }
  end
  
  def self.isolate_labels_differences(current_content, parent_content)
    return {} if current_content.nil? && parent_content.nil?
  
    current_labels = current_content['labels'] || {}
    parent_labels = parent_content['labels'] || {}
  
    changed_labels = []
    removed_labels = []
    added_labels = []
  
    # Iterate over each language in the current labels
    current_labels.each do |lang, current_label|
      parent_label = parent_labels[lang]
  
      if parent_label.nil?
        added_labels << { lang: lang }
      elsif current_label != parent_label
        changed_labels << { lang: lang }
      end
    end
  
    # Iterate over each language in the parent labels to find removed labels
    parent_labels.each do |lang, parent_label|
      if current_labels[lang].nil?
        removed_labels << { lang: lang }
      end
    end

    puts "Changed labels: #{changed_labels}"
    puts "Removed labels: #{removed_labels}"
    puts "Added labels: #{added_labels}"
  
    {
      changed: changed_labels,
      removed: removed_labels,
      added: added_labels
    }
  end
  
  def self.isolate_descriptions_differences(current_content, parent_content)
    return {} if current_content.nil? && parent_content.nil?
  
    current_descriptions = current_content['descriptions'] || {}
    parent_descriptions = parent_content['descriptions'] || {}
  
    changed_descriptions = []
    removed_descriptions = []
    added_descriptions = []
  
    # Iterate over each language in the current descriptions
    current_descriptions.each do |lang, current_description|
      parent_description = parent_descriptions[lang]
  
      if parent_description.nil?
        added_descriptions << { lang: lang }
      elsif current_description != parent_description
        changed_descriptions << { lang: lang }
      end
    end
  
    # Iterate over each language in the parent descriptions to find removed descriptions
    parent_descriptions.each do |lang, parent_description|
      if current_descriptions[lang].nil?
        removed_descriptions << { lang: lang }
      end
    end
  
    puts "Changed descriptions: #{changed_descriptions}"
    puts "Removed descriptions: #{removed_descriptions}"
    puts "Added descriptions: #{added_descriptions}"

    {
      changed: changed_descriptions,
      removed: removed_descriptions,
      added: added_descriptions
    }
  end
  
  def self.isolate_sitelinks_differences(current_content, parent_content)
    added_sitelinks = {}
    removed_sitelinks = {}
    changed_sitelinks = {}
  
    # Check if both current and parent content exist
    if current_content && parent_content
      current_sitelinks = current_content['sitelinks']
      parent_sitelinks = parent_content['sitelinks']
  
      # Check added sitelinks
      if current_sitelinks
        current_sitelinks.each do |site_key, current_sitelink|
          unless parent_sitelinks&.key?(site_key)
            added_sitelinks[site_key] = current_sitelink
          end
        end
      end
  
      # Check removed sitelinks
      if parent_sitelinks
        parent_sitelinks.each do |site_key, parent_sitelink|
          unless current_sitelinks&.key?(site_key)
            removed_sitelinks[site_key] = parent_sitelink
          end
        end
      end
  
      # Check changed sitelinks
      if current_sitelinks && parent_sitelinks
        current_sitelinks.each do |site_key, current_sitelink|
          if parent_sitelinks.key?(site_key)
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
  
    puts "Added sitelinks: #{added_sitelinks}"
    puts "Removed sitelinks: #{removed_sitelinks}"
    puts "Changed sitelinks: #{changed_sitelinks}"

    {
      added: added_sitelinks,
      removed: removed_sitelinks,
      changed: changed_sitelinks
    }
  end
  
  
  # counts the total number of statements in the claims of the provided content.
  def self.count_statements(content)
    return 0 if content.nil?

    claims = content['claims']
    return 0 unless claims.is_a?(Hash)
    statement_count = 0

    claims.each do |_property, statements|
      next unless statements.is_a?(Array)

      statements.each do |statement|
        statement_count += 1 if statement.is_a?(Hash) && statement['type'] == 'statement'
      end
    end
    statement_count
  end
  
  # Gets the parent id based on current revision id from the action:compare at Wikidata API.
  def self.get_parent_id(current_revision_id)
    client = MediawikiApi::Client.new('https://www.wikidata.org/w/api.php')
    response = client.action('compare', fromrev: current_revision_id, torelative: 'prev', format: 'json')
    data = response.data
    if data
      parent_id = data['fromrevid']
      return parent_id
    else
      return nil
    end
  end

  # Gets the child id based on parent revision id from the action:compare at Wikidata API.
  def self.get_child_id(parent_revision_id)
    client = MediawikiApi::Client.new('https://www.wikidata.org/w/api.php')
    response = client.action('compare', fromrev: parent_revision_id, torelative: 'next', format: 'json')
    data = response.data
    if data
      child_id = data['torevid']
      return child_id
    else
      return nil
    end
  end

  # calculates the difference between two revisions based on the revision ids.
  def self.calculate_diff(current_revision_id)
    # get the parent revision id
    parent_revision_id = get_parent_id(current_revision_id)

    # current claim, reference and qualifier count
    current_content = get_revision_content(current_revision_id)
    current_claim_count = count_claims(current_content)
    current_reference_count = count_references(current_content)
    current_qualifier_count = count_qualifiers(current_content)

    # parent claim, reference and qualifier count
    parent_content = get_revision_content(parent_revision_id)
    parent_claim_count = count_claims(parent_content)
    parent_reference_count = count_references(parent_content)
    parent_qualifier_count = count_qualifiers(parent_content)

    # calculate the difference
    claim_diff = current_claim_count - parent_claim_count
    reference_diff = current_reference_count - parent_reference_count
    qualifier_diff = current_qualifier_count - parent_qualifier_count

    puts "Claim diff: #{claim_diff}"
    puts "Reference diff: #{reference_diff}"
    puts "Qualifier diff: #{qualifier_diff}"
    # return the difference
    return {
      claim_diff: claim_diff,
      reference_diff: reference_diff,
      qualifier_diff: qualifier_diff
    }
  end
end

current = WikidataDiffAnalyzer.get_revision_content(1911025895)
parent_id = WikidataDiffAnalyzer.get_parent_id(1911025895)
parent = WikidataDiffAnalyzer.get_revision_content(parent_id)
WikidataDiffAnalyzer.isolate_claim_differences(current, parent)
WikidataDiffAnalyzer.isolate_reference_differences(current, parent)
WikidataDiffAnalyzer.calculate_diff(1911025895)