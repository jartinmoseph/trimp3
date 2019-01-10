require "csv"
require "./lib/edit.rb"
require "./lib/tagger.rb"
require "parseconfig"

puts "SYNTAX: ruby trimp3.rb config.conf list_of_edits_and_tags.csv outputfile"
ConfigFile = ARGV[0]
CsvFile = ARGV[1]
SplitFile = ARGV[2] + "_split\.txt"
TagFile = ARGV[2] + "_tag\.txt"
SplitHandle = File.open SplitFile,"w+"
TagHandle = File.open TagFile,"w+"

ConfPC = ParseConfig.new ConfigFile
ConfHash = ConfPC.params
ConfHash.freeze

TagListFile = ConfHash['tag_list'] || "tag_list not set"
puts "TagListFile: " + TagListFile.inspect
TagListFileHandle = File.open TagListFile,"r"
p TagListFileString = TagListFileHandle.read

#Pass CsvArray and column names for trimming to an object
TrimColumnNames = ConfHash['trim_column_names']
puts "TrimColumnNames: " + TrimColumnNames.inspect
TrimColumnNamesHandle = File.open TrimColumnNames,"r"
p TrimColumnNamesString = TrimColumnNamesHandle.read

CsvArray = CSV.read CsvFile
Width = CsvArray.transpose.length
Length = CsvArray.length
for row in 1..CsvArray.length-1
  edit_options = Hash.new
  for col in 0..Width-1
    #puts "row is " + row.inspect + " col is " + col.inspect + " element is " + CsvArray[row][col].inspect
    #puts "key is " + CsvArray[0][col].to_s
    puts key = CsvArray[0][col] || "no key"
    if TagListFileString.include? key 
      edit_options[CsvArray[0][col]] = CsvArray[row][col] || ""
    end
  end
  #puts edit_options.inspect + " options hash for edit object"
  this_edit = Edit.new edit_options
  SplitHandle.write this_edit.split_command + "\n"
  TagHandle.write this_edit.tag_command + "\n"
end
