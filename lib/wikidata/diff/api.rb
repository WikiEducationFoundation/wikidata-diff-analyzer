# frozen_string_literal: true

require 'json'
require 'mediawiki_api'

class Api
  API_URL = 'https://www.wikidata.org/w/api.php'

  def self.get_revision_contents(revision_ids)
    revision_ids = revision_ids.uniq if revision_ids
    client = MediawikiApi::Client.new(API_URL)
    response = fetch_revision_data(client, revision_ids)

    return {} if response.nil? || response.data['pages'].nil?

    parse_revisions(response.data['pages'])
  rescue MediawikiApi::ApiError => e
    puts "Error retrieving revision content: #{e.message}"
    {}
  rescue JSON::ParserError => e
    puts "Error parsing JSON content: #{e.message}"
    raise e
  end

  def self.fetch_revision_data(client, revision_ids)
    client.action(
      'query',
      prop: 'revisions',
      revids: revision_ids&.join('|'),
      rvslots: 'main',
      rvprop: 'content|ids|comment',
      format: 'json'
    )
  end

  def self.parse_revisions(pages)
    parsed_contents = {}

    pages.each_key do |page|
      revisions = pages[page]['revisions']

      next unless revisions

      revisions.each do |revision|
        parsed_content = parse_revision(revision)
        parsed_contents[revision['revid']] = parsed_content if parsed_content
      end
    end

    parsed_contents
  end

  def self.parse_revision(revision)
    content_model = revision['slots']['main']['contentmodel']

    return nil unless %w[wikibase-item wikibase-property wikibase-lexeme].include?(content_model)

    revid = revision['revid']
    parentid = revision['parentid']

    if revision.key?('texthidden')
      { content: nil, comment: nil, parentid: parentid, model: content_model }
    elsif revision.key?('commenthidden')
      content = revision['slots']['main']['*']
      { content: JSON.parse(content), comment: nil, parentid: parentid, model: content_model }
    else
      content = revision['slots']['main']['*']
      comment = revision['comment']

      if revid.nil? || revid.zero?
        { content: nil, comment: nil, parentid: nil, model: 'wikibase-item' }
      else
        { content: JSON.parse(content), comment: comment, parentid: parentid, model: content_model }
      end
    end
  end
end
