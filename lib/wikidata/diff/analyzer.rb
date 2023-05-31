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
end