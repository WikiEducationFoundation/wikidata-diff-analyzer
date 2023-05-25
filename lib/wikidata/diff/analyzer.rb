# frozen_string_literal: true

require_relative "analyzer/version"
require 'json'
require 'open-uri'

module Wikidata
  module Diff
    module Analyzer
      class Error < StandardError; end
      def self.get_revision_item_json(item_id, revision_id)
        url = "https://www.wikidata.org/w/api.php?action=query&prop=revisions&titles=#{item_id}&rvslots=main&rvprop=content&format=json&rvstartid=#{revision_id}"
        response = URI.open(url).read
        json = JSON.parse(response)
        page_id = json['query']['pages'].keys.first
        return json['query']['pages'][page_id]['revisions'][0]
      end
    end
  end
end
