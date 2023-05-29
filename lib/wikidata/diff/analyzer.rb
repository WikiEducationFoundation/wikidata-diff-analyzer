# frozen_string_literal: true

require_relative "analyzer/version"

module Wikidata
  module Diff
    module Analyzer
      class Error < StandardError; end
      def get_parent_revision_id(current_revision_id):
        # API endpoint URL
        url = "https://www.wikidata.org/w/api.php"

        # Parameters for the API request
        params = {
            "action": "query",
            "prop": "revisions",
            "revids": current_revision_id,
            "rvdir": "older",
            "rvlimit": "2",
            "rvprop": "ids",
            "format": "json"
        }

        # Send the API request
        response = requests.get(url, params=params)
        response_json = response.json()

        # Extract parent revision ID from the response
        pages = response_json["query"]["pages"]
        page_id = list(pages.keys())[0]
        revisions = pages[page_id]["revisions"]

        # Check if the current revision has a parent revision
        if len(revisions) > 1:
            parent_revision_id = revisions[1]["revid"]
            return parent_revision_id
        return None
      end
    end
  end
end
