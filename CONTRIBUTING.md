This file contains information about file structures and how the gem works.

`analyzer.rb` contains the main function `analyze` which calls functions from `large_batches_analyzer.rb`, `total.rb` and `revision_analyzer.rb`

`large_batches_analyzer.rb` handles large batches and builds the result containing the current_content, parent_content, model and comment. 
`revision_analyzer.rb` calls all the analyzers based on if the revision is item/property/lexeme to analyze the differences between current and parent contents.
`total.rb` sums up the count of all the analyzed revisions.

`revision_analyzer.rb` calls `claim_analyzer`, `alias_analyzer`, `label_analyzer`, `description_analyzer`, `sitelink_analyzer`, `comment_analyzer`, `lemma_analyzer`, `sense_analyzer`, `form_analyzer` for analyzing the differences

`claim_analyzer.rb` calls `reference_analyzer` and `qualifier_analyzer`
`form_analyzer.rb` calls `representation_analyzer` and `inside_claim_analyzer`
`sense_analyzer.rb` calls `gloss_analyzer` and `inside_claim_analyzer`
