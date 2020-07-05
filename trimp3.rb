require "csv"
require "./lib/edit.rb"
require "parseconfig"
#require "FileUtils"

puts "SYNTAX: ruby trimp3.rb config.conf list_of_edits_and_tags.csv /path/to/mp3s/outputfileprefix"
puts "NOTE: if the video file exists, it is treated as the principal file"
puts "REMINDER: save csv with tab as field separator"
puts "ANOTHER THING: csv's with empty fields make it crash"
puts "COMMAND LINE PARAMETERS:" + ARGV.inspect
SplitTagFile = ARGV[2] + "_both_split_then_tag\.txt"
SplitTagHandle = File.open SplitTagFile,"w+"
CombineAVFile = ARGV[2] + "_combine_audio_video\.txt"
puts "FILE TO COMBINE AUDIO AND VIDEO IS " + CombineAVFile.inspect 
CombineAVHandle = File.open CombineAVFile,"w+"

ConfigFile = ARGV[0]
ConfPC = ParseConfig.new ConfigFile
ConfHash = ConfPC.params.freeze
puts "CONFIG HASH IS " + ConfHash.inspect 

CsvFile = ARGV[1]
CsvArray = CSV.read CsvFile, {:col_sep => "\t"}

TagListFile = ConfHash['tag_list'] || "tag_list not set"
TagListFileHandle = File.open TagListFile,"r"
TagListFileString = TagListFileHandle.read.to_s
OriginalFileLocationFromConfig = ConfHash['file_location']

Width = CsvArray.transpose.length
ThisLinePlusTitlesArray = Array.new
ThisLinePlusTitlesHash = Hash.new
Handover = Hash.new
A2HHandover = Hash.new
Handover.update :tag_list => TagListFileString
Handover.update :original_file_location => OriginalFileLocationFromConfig
for row in 1..CsvArray.length-1
  ThisLinePlusTitlesArray[0] = CsvArray[0]
  ThisLinePlusTitlesArray[1] = CsvArray[row]
  A2HHandover.update :array_version => ThisLinePlusTitlesArray 
  @converter = AHHA.new A2HHandover
  Handover.update :array => ThisLinePlusTitlesArray
  #Handover.update :hash => @converter.hash_version, :array => ThisLinePlusTitlesArray
  this_edit = Edit.new Handover
  SplitTagHandle.write this_edit.edit_by_ffmpeg + "\n"
  SplitTagHandle.write this_edit.tag_command.to_s + "\n"
  CombineAVHandle.write this_edit.av_trim_merge.to_s + "\n" 
  #CombineAVHandle.write this_edit.av_simple_merge.to_s + "\n" 
end
FileUtils.chmod 0774, CombineAVFile 
FileUtils.chmod 0774, SplitTagFile 
=begin
=end
