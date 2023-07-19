class CommentAnalyzer
    def self.isolate_comment_differences(comment)
    phrases = {
        'merge_to': 0,
        'merge_from': 0,
        'redirect': 0,
        'undo': 0,
        'restore': 0,
        'clear_item': 0,
        'create_item': 0,
    }

    if comment.nil?
        return phrases
    end

    if comment.include?('wbmergeitems-from')
        phrases[:merge_from] = 1
    end

    if comment.include?('wbmergeitems-to')
        phrases[:merge_to] = 1
    end

    if comment.include?('wbcreateredirect')
        phrases[:redirect] = 1
    end

    if comment.include?('undo:')
        phrases[:undo] = 1
    end

    if comment.include?('restore:')
        phrases[:restore] = 1
    end

    if comment.include?('wbeditentity-override')
        phrases[:clear_item] = 1
    end

    # create-property, create-item, create-lexeme all includes this phrase
    # so based on content model in revision analyzer, it is decided which one it is
    if comment.include?('wbeditentity-create')
        phrases[:create_item] = 1
    end

    return phrases
    end
end