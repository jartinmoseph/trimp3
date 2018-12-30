require "../hash_mod/lib/hash_mod"

class Edit
  attr_reader :split_command
  attr_reader :file_name

  def initialize (options = {})
    options_symbol = HashMod.new options
    options = options_symbol.to_symbol_hash
    #@username = options[:username] || "username not set"
    @split_command = 'something'
    @file_name = 'nameoffile'
  end
end
