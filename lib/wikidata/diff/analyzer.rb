# frozen_string_literal: true

require_relative "analyzer/version"
require 'mediawiki_api'

module Wikidata
  module Diff
    module Analyzer
      class Error < StandardError; end

      def self.get_parent_revision_id(current_revision_id)
        client = MediawikiApi::Client.new('https://www.wikidata.org/w/api.php')
        params = {
          action: 'query',
          prop: 'revisions',
          titles: 'Data:Main_Page',
          rvdir: 'older',
          rvlimit: 2,
          rvprop: 'ids',
          format: 'json'
        }
        response = client.query(params)
        pages = response.data['pages']
        page_id = pages.keys[0]
        revisions = pages[page_id]['revisions']

        if revisions && revisions.length > 1
          parent_revision_id = revisions[1]['revid']
          return parent_revision_id
        end

        nil
      end
    end
  end
end

# Example usage
current_revision_id = '1596238176'
parent_revision_id = Wikidata::Diff::Analyzer.get_parent_revision_id(current_revision_id)

if parent_revision_id
  puts "Parent Revision ID: #{parent_revision_id}"
else
  puts 'No parent revision found.'
end
