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
The main method of this gem is `WikidataDiffAnalyzer.analyze`, which receives an array of revision IDs and provides a comprehensive analysis of the differences among them.

You can look at the HTML version of the difference between the edits with their parent revision below:
- 0 (does not exist)
- [123](https://www.wikidata.org/w/index.php?&diff=123) (No parent revision, is not analyzed)
- [622872009](https://www.wikidata.org/w/index.php?&diff=622872009) (added 1 claim)
- [1902995129](https://www.wikidata.org/w/index.php?&diff=1902995129) (removed 1 claim, 1 reference, and 1 qualifier)
- [1903003546](https://www.wikidata.org/w/index.php?&diff=1903003546) (changed 1 claim, added 1 qualifier)

```
require 'wikidata_diff_analyzer'

revision_ids = [0, 123, 622872009, 1903003546, 1902995129]
result = WikidataDiffAnalyzer.analyze(revision_ids)

```


The output is a hash including the information below:

```
{
  diffs_analyzed_count: 3,
  diffs_not_analyzed: [0, 123],
  diffs: {1780106722: {...}, 1903003546: {...}, 1902995129: {...}},
  total: {claims_added: 0, claims_removed: 1, claims_changed: 3 ...}
}

```
You can delve into the result as shown:

```
puts result[:diffs_analyzed_count]  # Prints the count of analyzed diffs
puts result[:diffs_not_analyzed]     # Prints the list of revision IDs not analyzed
puts result[:diffs]                  # Prints the detailed analysis of each diff (Key is the revision ID)
puts result[:total]                  # Prints the total stats of all diffs

```
Here's the full output structure:
```
# the count of analyzed diffs
3
# the list of revision IDs not analyzed
0
123
# the detailed analysis of each diff (Key is the revision ID)
{
  {
  622872009=>{
    :added_claims=>1,
    :removed_claims=>0,
    :changed_claims=>0,
    :added_references=>0,
    :removed_references=>0,
    :changed_references=>0,
    :added_qualifiers=>0,
    :removed_qualifiers=>0,
    :changed_qualifiers=>0,
    :added_aliases=>0,
    :removed_aliases=>0,
    :changed_aliases=>0,
    :added_labels=>0,
    :removed_labels=>0,
    :changed_labels=>0,
    :added_descriptions=>0,
    :removed_descriptions=>0,
    :changed_descriptions=>0,
    :added_sitelinks=>0,
    :removed_sitelinks=>0,
    :changed_sitelinks=>0
  },
  1902995129=>{
    :added_claims=>0,
    :removed_claims=>1,
    :changed_claims=>0,
    :added_references=>0,
    :removed_references=>1,
    :changed_references=>0,
    :added_qualifiers=>0,
    :removed_qualifiers=>1,
    :changed_qualifiers=>0,
    :added_aliases=>0,
    :removed_aliases=>0,
    :changed_aliases=>0,
    :added_labels=>0,
    :removed_labels=>0,
    :changed_labels=>0,
    :added_descriptions=>0,
    :removed_descriptions=>0,
    :changed_descriptions=>0,
    :added_sitelinks=>0,
    :removed_sitelinks=>0,
    :changed_sitelinks=>0
  },
  1903003546=>{
    :added_claims=>0,
    :removed_claims=>0,
    :changed_claims=>1,
    :added_references=>0,
    :removed_references=>0,
    :changed_references=>0,
    :added_qualifiers=>1,
    :removed_qualifiers=>0,
    :changed_qualifiers=>0,
    :added_aliases=>0,
    :removed_aliases=>0,
    :changed_aliases=>0,
    :added_labels=>0,
    :removed_labels=>0,
    :changed_labels=>0,
    :added_descriptions=>0,
    :removed_descriptions=>0,
    :changed_descriptions=>0,
    :added_sitelinks=>0,
    :removed_sitelinks=>0,
    :changed_sitelinks=>0
  }
}

}
# the total stats of all diffs
{
  :claims_added=>0,
  :claims_removed=>1,
  :claims_changed=>3,
  :references_added=>1,
  :references_removed=>2,
  :references_changed=>0,
  :qualifiers_added=>1,
  :qualifiers_removed=>1,
  :qualifiers_changed=>0,
  :aliases_added=>0,
  :aliases_removed=>0,
  :aliases_changed=>0,
  :labels_added=>0,
  :labels_removed=>0,
  :labels_changed=>0,
  :descriptions_added=>0,
  :descriptions_removed=>0,
  :descriptions_changed=>0,
  :sitelinks_added=>0,
  :sitelinks_removed=>0,
  :sitelinks_changed=>0
}

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/wikidata-diff-analyzer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/wikidata-diff-analyzer/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wikidata::Diff::Analyzer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/wikidata-diff-analyzer/blob/master/CODE_OF_CONDUCT.md).
