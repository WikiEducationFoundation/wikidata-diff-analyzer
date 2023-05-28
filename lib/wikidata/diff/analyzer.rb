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
        content = JSON.parse(first_revision['slots']['main']['*'])
        return content
      end
    end
  end
end
