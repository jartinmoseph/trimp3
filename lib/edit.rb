require "../rspec_book_etc/hash_mod/lib/hash_mod"

class Edit
  attr_reader :split_command

  def initialize (options = {})
    @handover_hash = options[:hash]
    @handover_array = options[:array]
    @tag_list = options[:tag_list].to_s || "tag list not set"

    @file_name = @handover_hash['file_name'].to_s || "name_of_file not set"
    @discard_after = sprintf("%.02f", @handover_hash['discard_after'].to_s || 0) 
    @discard_before = sprintf("%.02f", @handover_hash['discard_before'].to_s || 0)
    @split_command = 'mp3splt ' + @file_name + ' ' + @discard_before + ' ' + @discard_after.to_s 
  end
  def tag_command
    set_tags = String.new
    @handover_hash.each do |key, value|
      if @tag_list.include? key.to_s
        set_tags = set_tags + ' --' + key.to_s + ' "' + value.to_s + '"'
      end
    end
    @tag_command = 'id3v2 "' + @file_name + '"' + set_tags
  end
end

