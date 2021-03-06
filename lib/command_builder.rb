require "../rspec_book_etc/hash_mod/lib/hash_mod"

class CommandBuilder
  attr_reader :csv_array
  attr_reader :command

  def initialize options = ({})
  #def initialize (command, csv_array, columns)

    @command = options[:command] || "command not set"
    @csv_array = options[:csv_array] || "csv_array not set"
    @columns = options[:columns].to_s || "columns not set" 
    #puts "@columns is " + @columns.inspect + " @columns is of class " + @columns.class.inspect
    #puts "@csv_array is " + @csv_array.inspect
  end
  def convert_csv_to_hash
    @edit_options = Hash.new
    width = @csv_array.transpose.length
    @complete_command = @command + ' '
    for col in 0..width-1
      key = @csv_array[0][col]
      val = @csv_array[1][col]
      #puts "key is " + key.inspect + " val is " + val.inspect
      if @columns.include? key 
        puts "inside if loop - key is " + key.inspect + " val is " + val.inspect
        @complete_command.concat '--'
        @complete_command.concat key 
        @complete_command.concat " £"
        @complete_command.concat val
        @complete_command.concat '£ '
      end 
    end
    @complete_command.gsub! '£', '"'
    puts @complete_command.inspect
    return @complete_command
  end
end 

