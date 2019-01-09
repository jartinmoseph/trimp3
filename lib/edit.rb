require "../rspec_book_etc/hash_mod/lib/hash_mod"

class Edit
  attr_reader :split_command
  attr_reader :file_name
  attr_reader :genre

  def initialize (options = {})
    options_symbol = HashMod.new options
    options = options_symbol.to_symbol_hash
<<<<<<< HEAD

    @file_name = options[:file_name] || "name_of_file not set"
    @discard_after = sprintf("%.02f", options[:discard_after] || 0) 
    @discard_before = sprintf("%.02f", options[:discard_before] || 0)
    @split_command = 'mp3splt ' + @file_name + ' ' + @discard_before + ' ' + @discard_after.to_s 
    @genre = options[:genre] || "genre not set"
  end
  def tag_command
    tag_command = 'id3v2 ' + @file_name + ' --genre "' + @genre + '"'
=======
    @username = options[:username] || "username not set"
    @file_name = options[:file_name] || "name_of_file not set"
    @split_point = options[:split_point] || "split_point not set"
    @split_command = 'mp3splt ' + @file_name + ' ' + @split_point
>>>>>>> 62b5fe5c199f19c5c056212600cc08143e3d33ed
  end
end
