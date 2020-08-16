require "csv"
require "./lib/edit.rb"
require "parseconfig"
#require "FileUtils"

puts "SYNTAX: ruby trimp3.rb config.conf list_of_edits_and_tags.csv /path/to/mp3s/outputfileprefix"
puts "NOTE: if the video file exists, it is treated as the principal file"
puts "REMINDER: save csv with tab as field separator"
puts "ANOTHER THING: csv's with empty fields make it crash"
puts "COMMAND LINE PARAMETERS:" + ARGV.inspect
DoAllFile = ARGV[2] + "do_all\.txt"
DoAllHandle = File.open DoAllFile,"w+"
puts "FILE TO RUN IS " + DoAllFile.inspect 

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
Handover.update :temp_folder => ConfHash['temp_folder']
A2HHandover = Hash.new
=begin
Handover.update :tag_list => TagListFileString
Handover.update :original_file_location => OriginalFileLocationFromConfig
Handover.update :temp_folder => TempFolderName
=end

puts "no of rows in array:" + (CsvArray.length-1).to_s.inspect
puts "no of columns in array:" + Width.inspect
for row in 1..CsvArray.length-1
  ThisLinePlusTitlesArray[0] = CsvArray[0]
  ThisLinePlusTitlesArray[1] = CsvArray[row]
  #A2HHandover.update :array_version => ThisLinePlusTitlesArray 
  #@converter = AHHA.new A2HHandover
  Handover.update :array => ThisLinePlusTitlesArray
  this_edit = Edit.new Handover
  unless this_edit.process_this_line == "n"
    DoAllHandle.write this_edit.simple_trim + "\n"
    DoAllHandle.write this_edit.fade_trimmed_file + "\n"
  end
=begin
  unless this_edit.process_this_line == "n"
    if this_edit.mode == "merge"
      DoAllHandle.write this_edit.av_trim_merge.to_s + "\n" 
    else
      DoAllHandle.write this_edit.simple_trim + "\n"
    end
    DoAllHandle.write this_edit.fade_trimmed_file + "\n"
  end
=end
end
FileUtils.chmod 0774, DoAllFile

IO.popen(DoAllFile) 
=begin
TrimTagFile = ARGV[2] + "_both_trim_then_tag\.txt"
TrimTagHandle = File.open TrimTagFile,"w+"
TrimFadeFile = ARGV[2] + "trim_then_fade\.txt"
TrimFadeHandle = File.open TrimFadeFile,"w+"
MergeTrimFadeFile = ARGV[2] + "merge_trim_fade\.txt"
MergeTrimFadeHandle = File.open MergeTrimFadeFile,"w+" 
TagFile = ARGV[2] + "_tag\.txt"
TagHandle = File.open TagFile,"w+"
MergeAVFile = ARGV[2] + "_combine_audio_video\.txt"
MergeAVHandle = File.open MergeAVFile,"w+"
    TrimFadeHandle.write this_edit.simple_trim + "\n"
    TrimFadeHandle.write this_edit.fade_trimmed_file + "\n"
    TrimTagHandle.write this_edit.simple_trim + "\n"
    TrimTagHandle.write this_edit.tag_command.to_s + "\n"
    MergeAVHandle.write this_edit.av_trim_merge.to_s + "\n" 
    MergeTrimFadeHandle.write this_edit.av_trim_merge.to_s + "\n" 
    MergeTrimFadeHandle.write this_edit.fade_trimmed_file + "\n"
FileUtils.chmod 0774, MergeAVFile 
FileUtils.chmod 0774, TrimTagFile 
FileUtils.chmod 0774, TrimFadeFile 
FileUtils.chmod 0774, MergeTrimFadeFile
=end
