# frozen_string_literal: true

require 'json'
require 'mediawiki_api'

module Wikidata
  module Diff
    module Analyzer
      class Error < StandardError; end

      def self.get_revision_content(revision_id)
        api_url = 'https://www.wikidata.org/w/api.php'

        client = MediawikiApi::Client.new(api_url)
        response = client.action(
          'query',
          prop: 'revisions',
          revids: revision_id,
          rvslots: 'main',
          rvprop: 'content',
          format: 'json'
        )

        page_id = response.data['pages'].keys.first
        revisions = response.data['pages'][page_id]['revisions']
        first_revision = revisions[0]
        content = first_revision['slots']['main']['*']
        begin
          parsed_content = JSON.parse(content)
        rescue JSON::ParserError => e
          puts "Error parsing JSON content: #{e.message}"
          puts "Content: #{content}"
          raise e
        end
        return parsed_content
      end

      def self.count_claims(content)
        claims = content['claims']
        # counting the number of elements inside the arrays in claims
        if claims
          claims_lengths = claims.map { |key, value| value.length }
          total_length = claims_lengths.reduce(0) { |sum, length| sum + length }
          return total_length
        else
          return 0
        end
      end

      def self.count_references_recursive(content)
        references_count = 0
        if content.is_a?(Hash)
          content.each do |key, value|
            if key == 'references' && value.is_a?(Array)
              references_count += value.length
            elsif value.is_a?(Array) || value.is_a?(Hash)
              references_count += count_references_recursive(value)
            end
          end
        elsif content.is_a?(Array)
          content.each do |item|
            references_count += count_references_recursive(item)
          end
        end
        return references_count
      end      
    end
  end
end