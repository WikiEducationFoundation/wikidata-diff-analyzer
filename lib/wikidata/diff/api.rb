require 'json'
require 'mediawiki_api'

class Api
    def self.get_revision_contents(revision_ids)
        api_url = 'https://www.wikidata.org/w/api.php'
        client = MediawikiApi::Client.new(api_url)

        # remove duplicates if revision_ids exists
        # check if duplicate revision_ids exist and print if exists

        revision_ids = revision_ids.uniq if revision_ids

        begin
        response = client.action(
            'query',
            prop: 'revisions',
            revids: revision_ids.join('|'),
            rvslots: 'main',
            rvprop: 'content|ids|comment',
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
            return nil
        end

        response.data['pages'].keys.each do |page|
            page = response.data['pages'][page]
            revisions = page['revisions']
          
            revisions.each do |revision|
              content_model = revision['slots']['main']['contentmodel']
              if content_model != 'wikibase-item'
                puts "Content model is not wikibase-item"
                puts "Revision ID #{revision['revid']} is a #{content_model}"
              else
                # checking if content has been deleted
                if revision.key?('texthidden')
                  puts "Content has been hidden or deleted"
                  revid = revision['revid']
                  parentid = revision['parentid']
                  parsed_contents[revid] = { content: nil, comment: nil, parentid: parentid }
                # checking if comment has been deleted
                elsif revision.key?('commenthidden')
                  puts "Comment has been hidden or deleted"
                  revid = revision['revid']
                  content = revision['slots']['main']['*']
                  parentid = revision['parentid']
                  parsed_contents[revid] = { content: JSON.parse(content), comment: nil, parentid: parentid }
                else
                  content = revision['slots']['main']['*']
                  revid = revision['revid']
                  comment = revision['comment']
                  parentid = revision['parentid']
                  if revid == 0
                    parsed_contents[revid] = { content: nil, comment: nil, parentid: 0 }
                  else
                    parsed_contents[revid] = { content: JSON.parse(content), comment: comment, parentid: parentid }
                  end
                end
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
end