# frozen_string_literal: true

class CommentAnalyzer
  def self.isolate_comment_differences(comment)
    phrases = {
      'merge_to': 0,
      'merge_from': 0,
      'redirect': 0,
      'undo': 0,
      'restore': 0,
      'clear_item': 0,
      'create_item': 0
    }

    return phrases if comment.nil?

    phrases[:merge_from] = 1 if comment.include?('wbmergeitems-from')

    phrases[:merge_to] = 1 if comment.include?('wbmergeitems-to')

    phrases[:redirect] = 1 if comment.include?('wbcreateredirect')

    phrases[:undo] = 1 if comment.include?('undo:')

    phrases[:restore] = 1 if comment.include?('restore:')

    phrases[:clear_item] = 1 if comment.include?('wbeditentity-override')

    # create-property, create-item, create-lexeme all includes this phrase
    # so based on content model in revision analyzer, it is decided which one it is
    phrases[:create_item] = 1 if comment.include?('wbeditentity-create')

    phrases
  end
end
