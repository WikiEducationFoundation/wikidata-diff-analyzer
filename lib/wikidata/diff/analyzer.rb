# frozen_string_literal: true

require 'json'
require 'mediawiki_api'

module WikidataDiffAnalyzer
  class Error < StandardError; end

  # This method analyzes a set of revision ids and returns the differences between them.
  def self.analyze(revision_ids)
    diffs_analyzed_count = 0
    diffs_not_analyzed = []
    diffs = {}
    total = {
      claims_added: 0,
      claims_removed: 0,
      claims_changed: 0,
      references_added: 0,
      references_removed: 0,
      references_changed: 0,
      qualifiers_added: 0,
      qualifiers_removed: 0,
      qualifiers_changed: 0,
      aliases_added: 0,
      aliases_removed: 0,
      aliases_changed: 0,
      labels_added: 0,
      labels_removed: 0,
      labels_changed: 0,
      descriptions_added: 0,
      descriptions_removed: 0,
      descriptions_changed: 0,
      sitelinks_added: 0,
      sitelinks_removed: 0,
      sitelinks_changed: 0
    }

    result = handle_large_batchs(revision_ids)

    puts "Analyzing #{result.length} revisions"

    # result is a hash which has contents like this:
    # result[revid] = { current_content: data[:content], parent_content: parent_content }

    result.each do |revision_id, revision_data|
      current_content = revision_data[:current_content]
      parent_content = revision_data[:parent_content]
      if current_content && parent_content
        diff = analyze_diff(current_content, parent_content)
        diffs[revision_id] = diff
        accumulate_totals(diff, total)
        diffs_analyzed_count += 1
      else
        diffs_not_analyzed << revision_id
      end
    end

    {
      diffs_analyzed_count: diffs_analyzed_count,
      diffs_not_analyzed: diffs_not_analyzed,
      diffs: diffs,
      total: total
    }
  end

  # This method takes two revisions as input and returns the differences between them.
  def self.analyze_diff(current_content, parent_content)
    diff = {}
    # Calculate claim differences includes references and qualifiers
    claim_diff = WikidataDiffAnalyzer.isolate_claim_differences(current_content, parent_content)
    diff[:added_claims] = claim_diff[:added_claims].length
    diff[:removed_claims] = claim_diff[:removed_claims].length
    diff[:changed_claims] = claim_diff[:changed_claims].length
    diff[:added_references] = claim_diff[:added_references].length
    diff[:removed_references] = claim_diff[:removed_references].length
    diff[:changed_references] = claim_diff[:changed_references].length
    diff[:added_qualifiers] = claim_diff[:added_qualifiers].length
    diff[:removed_qualifiers] = claim_diff[:removed_qualifiers].length
    diff[:changed_qualifiers] = claim_diff[:changed_qualifiers].length
  
    # Calculate alias differences
    alias_diff = WikidataDiffAnalyzer.isolate_aliases_differences(current_content, parent_content)
    diff[:added_aliases] = alias_diff[:added].length
    diff[:removed_aliases] = alias_diff[:removed].length
    diff[:changed_aliases] = alias_diff[:changed].length


    # Calculate label differences
    label_diff = WikidataDiffAnalyzer.isolate_labels_differences(current_content, parent_content)
    diff[:added_labels] = label_diff[:added].length
    diff[:removed_labels] = label_diff[:removed].length
    diff[:changed_labels] = label_diff[:changed].length

    # Calculate description differences
    description_diff = WikidataDiffAnalyzer.isolate_descriptions_differences(current_content, parent_content)
    diff[:added_descriptions] = description_diff[:added].length
    diff[:removed_descriptions] = description_diff[:removed].length
    diff[:changed_descriptions] = description_diff[:changed].length

    # Calculate sitelink differences
    sitelink_diff = WikidataDiffAnalyzer.isolate_sitelinks_differences(current_content, parent_content)
    diff[:added_sitelinks] = sitelink_diff[:added].length
    diff[:removed_sitelinks] = sitelink_diff[:removed].length
    diff[:changed_sitelinks] = sitelink_diff[:changed].length

  
    diff
  end


  # 
  def self.accumulate_totals(diff, total)
    diff_data = diff
      total[:references_added] += diff_data[:added_references]
      total[:references_removed] += diff_data[:removed_references]
      total[:references_changed] += diff_data[:changed_references]
      total[:aliases_added] += diff_data[:added_aliases]
      total[:aliases_removed] += diff_data[:removed_aliases]
      total[:aliases_changed] += diff_data[:changed_aliases]
      total[:labels_added] += diff_data[:added_labels]
      total[:labels_removed] += diff_data[:removed_labels]
      total[:labels_changed] += diff_data[:changed_labels]
      total[:descriptions_added] += diff_data[:added_descriptions]
      total[:descriptions_removed] += diff_data[:removed_descriptions]
      total[:descriptions_changed] += diff_data[:changed_descriptions]
      total[:sitelinks_added] += diff_data[:added_sitelinks]
      total[:sitelinks_removed] += diff_data[:removed_sitelinks]
      total[:sitelinks_changed] += diff_data[:changed_sitelinks]
      total[:qualifiers_added] += diff_data[:added_qualifiers]
      total[:qualifiers_removed] += diff_data[:removed_qualifiers]
      total[:qualifiers_changed] += diff_data[:changed_qualifiers]
      total[:claims_added] += diff_data[:added_claims]
      total[:claims_removed] += diff_data[:removed_claims]
      total[:claims_changed] += diff_data[:changed_claims]
  end

# returns revision contents and parent contents for whole revision_ids array
def self.handle_large_batchs(revision_ids)
  puts "Handling large batchs"
  puts revision_ids.length
  revision_contents = {}
  parent_contents = {}

  revision_ids_batches = revision_ids.each_slice(500).to_a
  puts "Number of batches"
  puts revision_ids_batches.length
  revision_ids_batches.each do |batch|
    puts "Batch"
    puts batch.length
    contents = get_revision_contents(batch)
    revision_contents.merge!(contents)

    parent_ids = contents.values.map { |data| data[:parentid] }.compact
    parent_contents_batch = get_revision_contents(parent_ids)
    parent_contents.merge!(parent_contents_batch)
  end

  puts "revision_contents"
  puts revision_contents.length
  result = {}
  revision_contents.each do |revid, data|
    parentid = data[:parentid]
    parent_content = parent_contents[parentid] if parentid
    current = data ? data[:content] : nil
    parent = parent_content ? parent_content[:content] : nil

    result[revid] = { current_content: current, parent_content: parent }
  end
  result
end

def self.get_revision_contents(revision_ids)
  api_url = 'https://www.wikidata.org/w/api.php'
  client = MediawikiApi::Client.new(api_url)

  # remove duplicates if revision_ids exists
  revision_ids = revision_ids.uniq if revision_ids

  begin
    response = client.action(
      'query',
      prop: 'revisions',
      revids: revision_ids.join('|'),
      rvslots: 'main',
      rvprop: 'content|ids',
      format: 'json'
    )

    if response.nil?
      puts "No response received for revision IDs: #{revision_ids.join(', ')}"
      return {}
    end

    parsed_contents = {}

    # checks if it has pages
    if response.data['pages'].nil?
      puts "No pages found in the response for revision IDs: #{revision_ids.join(', ')}"
      return {}
    end

    puts "page count"
    puts response.data['pages'].values.length
    puts "page keys"
    puts response.data['pages'].keys
    # print revision count for each page 
    # create a loop for this purpose only

    puts "printing specific key info"
    page = response.data['pages']["562024"]['revisions'].length
    puts page


    response.data['pages'].keys.each do |page|
      puts "revisions count per page"
      # puts the key of the page
      page = response.data['pages'][page]

      puts page['revisions'].length
      revisions = page['revisions']
      
      revisions.each do |revision|
        content = revision['slots']['main']['*']
        revid = revision['revid']
        if revid == 0
          parsed_contents[revid] = {content: nil, parentid: 0}
        else
          parentid = revision['parentid']
          parsed_contents[revid] = {content: JSON.parse(content), parentid: parentid}
        end
      end
    end
    return parsed_contents
  rescue MediawikiApi::ApiError => e
    puts "Error retrieving revision content: #{e.message}"
    return {}
  rescue JSON::ParserError => e
    puts "Error parsing JSON content: #{e.message}"
    raise e
  end
end

  
# This method retrieves the content of a specific revision from the Wikidata API.
# It takes a revision ID as input and returns the parsed content as a Ruby object.
  def self.get_revision_content(revision_id)
    # in case of the first revision, there is no parent revision
    # currently we are not handling this case
    if revision_id.nil?
      return nil
    end

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

   # Gets the parent id based on current revision id from the action:compare at Wikidata API.
   def self.get_parent_id(current_revision_id)
    client = MediawikiApi::Client.new('https://www.wikidata.org/w/api.php')
    response = client.action('compare', fromrev: current_revision_id, torelative: 'prev', format: 'json')
    data = response.data
    if data
      if data['fromrevid'].nil?
        return nil
      end
      parent_id = data['fromrevid']
      return parent_id
    else
      return nil
    end
  end

  def self.isolate_claim_differences(current_content, parent_content)
    # Initialize empty arrays to store the added, removed, and changed claims
    added_claims = []
    removed_claims = []
    changed_claims = []
    added_references = []
    removed_references = []
    changed_references = []
    added_qualifiers = []
    removed_qualifiers = []
    changed_qualifiers = []


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
            # check if there's any references or qualifiers in this claim
            added_references = reference_updates(current_claim, added_references, claim_key, index)
            added_qualifiers = qualifier_updates(current_claim, added_qualifiers, claim_key, index)

          elsif current_claim != parent_claim
            # Claim was changed
            changed_claims << { key: claim_key, index: index }
            # check if there's any references or qualifiers in this claim
            changed = handle_changed_references(current_claim, parent_claim, changed_references, added_references, removed_references, claim_key, index)
            added_references = changed[:added_references]
            removed_references = changed[:removed_references]
            changed_references = changed[:changed_references]
            changed_qualifiers = handle_changed_qualifiers(current_claim, parent_claim, changed_qualifiers, added_qualifiers, removed_qualifiers, claim_key, index)
            added_qualifiers = changed_qualifiers[:added_qualifiers]
            removed_qualifiers = changed_qualifiers[:removed_qualifiers]
            changed_qualifiers = changed_qualifiers[:changed_qualifiers]
          end
        end
        # Check for removed claims
        parent_claims.each_with_index do |parent_claim, index|
          current_claim = current_claims[index]
          if current_claim.nil?
            # Claim was removed
            removed_claims << { key: claim_key, index: index }

            # check if there's any references or qualifiers in this claim
            removed_references = reference_updates(parent_claim, removed_references, claim_key, index)
            removed_qualifiers = qualifier_updates(parent_claim, removed_qualifiers, claim_key, index)
          end
        end
      else
        # All claims in current content with this key were added
        current_claims.each_index do |index|
          added_claims << { key: claim_key, index: index }
          # check if there's any references or qualifiers in this claim
          added_references = reference_updates(current_claims[index], added_references, claim_key, index)
          added_qualifiers = qualifier_updates(current_claims[index], added_qualifiers, claim_key, index)
        end
      end
    end

    parent_content["claims"].each do |claim_key, parent_claims|
      # current content[claims] can be nil
      parent_claims.each_index do |index|
        if current_content["claims"].nil? || !current_content["claims"].key?(claim_key)
          removed_claims << { key: claim_key, index: index }
          # check if there's any references or qualifiers in this claim
          removed_references = reference_updates(parent_claims[index], removed_references, claim_key, index)
          removed_qualifiers = qualifier_updates(parent_claims[index], removed_qualifiers, claim_key, index)
        end
      end
    end
  
    # puts "Added claims: #{added_claims}"
    # puts "Removed claims: #{removed_claims}"
    # puts "Changed claims: #{changed_claims}"
    # puts "Added references: #{added_references}"
    # puts "Removed references: #{removed_references}"
    # puts "Changed references: #{changed_references}"
    # puts "Added qualifiers: #{added_qualifiers}"
    # puts "Removed qualifiers: #{removed_qualifiers}"
    # puts "Changed qualifiers: #{changed_qualifiers}"


    {
      added_claims: added_claims,
      removed_claims: removed_claims,
      changed_claims: changed_claims,
      added_references: added_references,
      removed_references: removed_references,
      changed_references: changed_references,
      added_qualifiers: added_qualifiers,
      removed_qualifiers: removed_qualifiers,
      changed_qualifiers: changed_qualifiers
    }
  end

  # helper method for adding and removing references
  def self.reference_updates(claim, updated_references, claim_key, claim_index)
    if claim["references"]
      claim["references"].each_with_index do |current_ref, ref_index|
        updated_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      end
    end
    updated_references
  end

  # helper method for changed references
  def self.handle_changed_references(current_claim, parent_claim, changed_references, added_references, removed_references, claim_key, claim_index)
    current_references = current_claim["references"] ? current_claim["references"] : []
    parent_references = parent_claim["references"] ? parent_claim["references"] : []
  
    current_references.each_with_index do |current_ref, ref_index|
      if parent_references.empty?
        added_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      elsif !parent_references.include?(current_ref)
        added_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      elsif ref_modified?(current_ref, parent_references)
        changed_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      end
    end
  
    parent_references.each_with_index do |parent_ref, ref_index|
      if !current_references.include?(parent_ref)
        removed_references << { claim_key: claim_key, claim_index: claim_index, reference_index: ref_index }
      end
    end

    {
      added_references: added_references,
      removed_references: removed_references,
      changed_references: changed_references
    }
  end

  # helper method for checking if a reference has been modified
  def self.ref_modified?(current_reference, parent_references)
    parent_references.each do |parent_reference|
      if current_reference["snaks"] != parent_reference["snaks"]
        return true
      end
    end
    false
  end

  # helper method for adding qualifiers
  # handles added and removed qualifiers
  def self.qualifier_updates(claim, updated_qualifiers, claim_key, claim_index)
    if claim["qualifiers"]
      qualifiers = claim["qualifiers"]
      qualifiers.each do |qualifier_key, qualifier_values|
        qualifier_values.each_with_index do |qualifier_value, qualifier_index|
          updated_qualifiers << {
          claim_key: claim_key,
          claim_index: claim_index,
          qualifier_key: qualifier_key,
          qualifier_index: qualifier_index
          }
        end
      end
    end
    updated_qualifiers
  end

  # helper method for changed qualifiers
  def self.handle_changed_qualifiers(current_claim, parent_claim, changed_qualifiers, added_qualifiers, removed_qualifiers, claim_key, claim_index)
    current_qualifiers = current_claim["qualifiers"] ? current_claim["qualifiers"] : {}
    parent_qualifiers = parent_claim["qualifiers"] ? parent_claim["qualifiers"] : {}

    current_qualifiers.each do |qualifier_key, qualifier_values|
      qualifier_values.each_with_index do |qualifier_value, qualifier_index|
        if parent_qualifiers.key?(qualifier_key)
          parent = parent_qualifiers[qualifier_key]
        end
        # Check if the qualifier index exists in the parent content
        if !parent.nil?
          parent = parent[qualifier_index]
        # check if the parent claim was changed by comparing the objects first
          if parent != qualifier_value
            # Claim was changed
            changed_qualifiers << {
              claim_key: claim_key,
              claim_index: claim_index,
              qualifier_key: qualifier_key,
              qualifier_index: qualifier_index
            }
          end
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

    {
      added_qualifiers: added_qualifiers,
      removed_qualifiers: removed_qualifiers,
      changed_qualifiers: changed_qualifiers
    }
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
  
    # puts "Changed aliases: #{changed_aliases}"
    # puts "Removed aliases: #{removed_aliases}"
    # puts "Added aliases: #{added_aliases}"

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

    # puts "Changed labels: #{changed_labels}"
    # puts "Removed labels: #{removed_labels}"
    # puts "Added labels: #{added_labels}"
  
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
  
    # puts "Changed descriptions: #{changed_descriptions}"
    # puts "Removed descriptions: #{removed_descriptions}"
    # puts "Added descriptions: #{added_descriptions}"

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
  
    # puts "Added sitelinks: #{added_sitelinks}"
    # puts "Removed sitelinks: #{removed_sitelinks}"
    # puts "Changed sitelinks: #{changed_sitelinks}"

    {
      added: added_sitelinks,
      removed: removed_sitelinks,
      changed: changed_sitelinks
    }
  end
end

revision_ids = [123, 456]
revision_idss = [1780106722, 1903003546, 1902995129, 1596238100, 1898156691]
revisions =[123, 456, 1780106722, 1596238100, 1898156691, 1895908644, 622872009, 1901195499, 1902995129, 1903003546, 1863882476, 535078533]
# Test with your revision ids
#puts WikidataDiffAnalyzer.analyze(revision_ids)
# current = WikidataDiffAnalyzer.get_revision_content(1903003546)
# parent_id = WikidataDiffAnalyzer.get_parent_id(1903003546)
# parent = WikidataDiffAnalyzer.get_revision_content(parent_id)
# puts WikidataDiffAnalyzer.isolate_claim_differences(current, parent)

# Test with your revision ids
contents = WikidataDiffAnalyzer.analyze(revisions)
puts contents


