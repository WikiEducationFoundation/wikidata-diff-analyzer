# WikidataDiffAnalyzer

Welcome to WikidataDiffAnalyzer! The WikidataDiffAnalyzer is a Ruby gem that provides functionality to parse the differences between Wikidata revisions and extract statistics about the changes. It enables accurate analysis of Wikidata edits, such as counting the number of qualifiers added, references added, and other relevant statistics. This gem has been developed to enhance Wikidata statistics on the Wiki Education Dashboard and Programs & Events Dashboard, but it can be utilized for various other purposes as well.

## Installation

To install the WikidataDiffAnalyzer gem, add it to your Gemfile:
   `$ gem 'wikidata_diff_analyzer'`

Then, run the following command:
    `$ bundle install`

Alternatively, you can install it directly via:
`$ gem install wikidata_diff_analyzer`

## Usage
The `analyze` method allows you to analyze Wikidata edits and extract statistics about what changed.

```
# Import the gem
require 'wikidata_diff_analyzer'

# Pass an array of revision IDs to the analyze method
revision_ids = ['1596238100', '1898156691', '1895908644']
result = WikidataDiffAnalyzer.analyze(revision_ids)

```
The structure of the output of result is: 


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/wikidata-diff-analyzer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/wikidata-diff-analyzer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wikidata::Diff::Analyzer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/wikidata-diff-analyzer/blob/master/CODE_OF_CONDUCT.md).
