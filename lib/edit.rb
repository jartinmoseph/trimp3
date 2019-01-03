require "../rspec_book_etc/hash_mod/lib/hash_mod"

class Edit
  attr_reader :split_command
  attr_reader :file_name

  def initialize (options = {})
    options_symbol = HashMod.new options
    options = options_symbol.to_symbol_hash
    @username = options[:username] || "username not set"
    @file_name = options[:file_name] || "name_of_file not set"
    @split_point = options[:split_point] || "split_point not set"
    @split_command = 'mp3splt ' + @file_name + ' ' + @split_point
  end
end
