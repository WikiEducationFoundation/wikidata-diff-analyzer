# frozen_string_literal: true

require_relative "analyzer/version"
require 'mediawiki_api'

def get_parent_id(current_revision_id)
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



