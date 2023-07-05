require_relative 'api'

class LargeBatchesAnalyzer
    # returns revision contents and parent contents for whole revision_ids array
    def self.handle_large_batches(revision_ids, batch_size)
        revision_contents = {}
        parent_contents = {}
    
    
        revision_ids_batches = revision_ids.each_slice(batch_size).to_a
        revision_ids_batches.each do |batch|
            parsed_contents = Api.get_revision_contents(batch)
            if parsed_contents
                parent_ids = []
                revision_contents.merge!(parsed_contents) if parsed_contents
                parsed_contents.values.each do |data|
                    parent_id = data[:parentid]
                    
                    if parent_id != 0 && !parent_id.nil?
                        parent_ids << parent_id
                    end
                end
                parent_contents_batch = Api.get_revision_contents(parent_ids)
                parent_contents.merge!(parent_contents_batch) if parent_contents_batch
            end
        end
    
        result = {}
        revision_contents.each do |revid, data|
            parentid = data[:parentid]
            parent_content = parent_contents[parentid] if parentid
            current = data ? data[:content] : nil
            parent = parent_content ? parent_content[:content] : nil
            result[revid] = { current_content: current, parent_content: parent }    
        end
        result
    end
end