require "../rspec_book_etc/hash_mod/lib/hash_mod"

class CommandBuilder
  attr_reader :csv_array
  attr_reader :command

  def initialize options = ({})
  #def initialize (command, csv_array, columns)

    @command = options[:command] || "command not set"
    @csv_array = options[:csv_array] || "csv_array not set"
    @columns = options[:columns] || "columns not set"
  end
  def convert_csv_to_hash
  #puts "hello from convert_csv_to_hash"
    width = @csv_array.transpose.length
    length = @csv_array.length
    for row in 1..@csv_array.length-1
      @edit_options = Hash.new
      for col in 0..width-1
        #puts "row is " + row.inspect + " col is " + col.inspect + " element is " + @csv_array[row][col].inspect
        #puts "key is " + @csv_array[0][col].to_s
        #puts key = @csv_array[0][col] || "no key"
        if @columns.include? key 
          @edit_options[@csv_array[0][col]] = @csv_array[row][col] || ""
        end 
      end 
    end
    return @edit_options
  end

end

