require "csv"
require "./lib/edit.rb"

puts "SYNTAX: ruby trimp3.rb something.conf something.csv outputfile.bat"
ConfigFile = ARGV[0]
CsvFile = ARGV[1]
SplitFile = ARGV[2] + "_split\.txt"
TagFile = ARGV[2] + "_tag\.txt"
SplitHandle = File.open SplitFile,"w+"
TagHandle = File.open TagFile,"w+"

CsvArray = CSV.read CsvFile
p CsvArray
p Width = CsvArray.transpose.length
p Length = CsvArray.length
for row in 1..CsvArray.length-1
  edit_options = Hash.new
  for col in 0..Width-1
    puts "row is " + row.inspect + " col is " + col.inspect + " element is " + CsvArray[row][col].inspect
    puts "key is " + CsvArray[0][col].to_s
    edit_options[CsvArray[0][col]] = CsvArray[row][col] || ""
  end
  puts edit_options.inspect + " options hash for edit object"
  this_edit = Edit.new edit_options
  SplitHandle.write this_edit.split_command + "\n"
  TagHandle.write this_edit.tag_command + "\n"
end
