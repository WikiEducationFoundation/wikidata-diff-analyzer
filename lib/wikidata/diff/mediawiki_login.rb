require 'mediawiki_api'
# to load env variable
require 'dotenv/load'

# THIS IS NOT WORKING YET
class MediawikiLogin
    def self.mediawiki_login
        client = MediawikiApi::Client.new('https://www.mediawiki.org/w/api.php')
        client.log_in(ENV['MEDIAWIKI_USERNAME'], ENV['MEDIAWIKI_PASSWORD'])
        client.logged_in?  # Return whether login was successful
    end
end
