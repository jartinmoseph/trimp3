require "csv"
require "./lib/edit.rb"
require "parseconfig"

puts "SYNTAX: ruby trimp3.rb config.conf list_of_edits_and_tags.csv /path/to/mp3s/outputfileprefix"
puts "REMINDER: save csv with tab as field separator"
puts "ANOTHER THING: csv's with empty fields make it crash"
puts "have it put the output files in the correct folder"
ConfigFile = ARGV[0]
CsvFile = ARGV[1]
SplitFile = ARGV[2] + "_split\.txt"
TagFile = ARGV[2] + "_tag\.txt"
SplitTagFile = ARGV[2] + "_both_split_then_tag\.txt"
SplitHandle = File.open SplitFile,"w+"
TagHandle = File.open TagFile,"w+"
SplitTagHandle = File.open SplitTagFile,"w+"
CsvArray = CSV.read CsvFile, {:col_sep => "\t"}

ConfPC = ParseConfig.new ConfigFile
ConfHash = ConfPC.params.freeze
puts "CONFIG:" + ConfHash.inspect

TagListFile = ConfHash['tag_list'] || "tag_list not set"
TagListFileHandle = File.open TagListFile,"r"
TagListFileString = TagListFileHandle.read.to_s

TrimColumnNamesFile = ConfHash['trim_column_names']
TrimColumnNamesFileHandle = File.open TrimColumnNamesFile,"r"
TrimColumnNamesFileString = TrimColumnNamesFileHandle.read
 
Width = CsvArray.transpose.length
Length = CsvArray.length
ThisLinePlusTitlesArray = Array.new
ThisLinePlusTitlesHash = Hash.new
Handover = Hash.new
Handover.update :tag_list => TagListFileString

for row in 1..CsvArray.length-1
  ThisLinePlusTitlesArray[0] = CsvArray[0]
  ThisLinePlusTitlesArray[1] = CsvArray[row]
  for col in 0..Width-1
    ThisLinePlusTitlesHash[CsvArray[0][col]] = CsvArray[row][col] || ""
  end
  Handover.update :hash => ThisLinePlusTitlesHash, :array => ThisLinePlusTitlesArray
  this_edit = Edit.new Handover
  SplitHandle.write this_edit.edit_by_ffmpeg + "\n"
  TagHandle.write this_edit.tag_command.to_s + "\n"
  SplitTagHandle.write this_edit.edit_by_ffmpeg + "\n"
  SplitTagHandle.write this_edit.tag_command.to_s + "\n"
end
