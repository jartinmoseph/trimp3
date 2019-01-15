require "csv"
require "./lib/edit.rb"
require "./lib/tagger.rb"
require "parseconfig"
require "./lib/command_builder.rb"

puts "SYNTAX: ruby trimp3.rb config.conf list_of_edits_and_tags.csv outputfile"
ConfigFile = ARGV[0]
CsvFile = ARGV[1]
SplitFile = ARGV[2] + "_split\.txt"
TagFile = ARGV[2] + "_tag\.txt"
SplitHandle = File.open SplitFile,"w+"
TagHandle = File.open TagFile,"w+"
CsvArray = CSV.read CsvFile

ConfPC = ParseConfig.new ConfigFile
ConfHash = ConfPC.params
ConfHash.freeze

TagListFile = ConfHash['tag_list'] || "tag_list not set"
TagListFileHandle = File.open TagListFile,"r"
TagListFileContents = TagListFileHandle.read
TagListFileString = TagListFileContents.to_s
#puts "TagListFileString is: " + TagListFileString.inspect

TrimColumnNamesFile = ConfHash['trim_column_names']
#puts "TrimColumnNamesFile: " + TrimColumnNamesFile.inspect
TrimColumnNamesFileHandle = File.open TrimColumnNamesFile,"r"
TrimColumnNamesFileString = TrimColumnNamesFileHandle.read
#Pass each line of the array, plus the top line to the command builder, also the command and the list of tags
Width = CsvArray.transpose.length
Length = CsvArray.length
ThisLinePlusTitlesArray = Array.new
ThisLinePlusTitlesHash = Hash.new
Handover = Hash.new
Handover.update :tag_list => TagListFileString
#puts "Handover: " + Handover.inspect

for row in 1..CsvArray.length-1
  ThisLinePlusTitlesArray[0] = CsvArray[0]
  ThisLinePlusTitlesArray[1] = CsvArray[row]
  for col in 0..Width-1
    ThisLinePlusTitlesHash[CsvArray[0][col]] = CsvArray[row][col] || ""
  end
  Handover.update :hash => ThisLinePlusTitlesHash, :array => ThisLinePlusTitlesArray
  #puts "Handover: " + Handover.inspect
  #puts "Handover class: " + Handover.class.inspect
  #puts "Handover hash: " + Handover[:hash].inspect
  this_edit = Edit.new Handover
  SplitHandle.write this_edit.split_command + "\n"
  TagHandle.write this_edit.tag_command + "\n"
end

=begin
#Pass CsvArray and column names for trimming to an object

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
=end
