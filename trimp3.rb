require "csv"
require "./lib/edit.rb"
require "parseconfig"
#require "FileUtils"

puts "SYNTAX: ruby trimp3.rb config.conf list_of_edits_and_tags.csv /path/to/mp3s/outputfileprefix"
puts "NOTE: if the video file exists, it is treated as the principal file"
puts "REMINDER: save csv with tab as field separator"
puts "ANOTHER THING: csv's with empty fields make it crash"
puts "COMMAND LINE PARAMETERS:" + ARGV.inspect
DoAllFile = ARGV[2] + "_do_all\.txt"
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
@cncats_array = Array.new

puts "no of rows in array:" + (CsvArray.length-1).to_s.inspect
puts "no of columns in array:" + Width.inspect
for row in 1..CsvArray.length-1
  ThisLinePlusTitlesArray[0] = CsvArray[0]
  ThisLinePlusTitlesArray[1] = CsvArray[row]
  Handover.update :array => ThisLinePlusTitlesArray
  @this_edit = Edit.new Handover
  FileUtils.mkdir_p @this_edit.unquoted_dist_tmp_folder unless Dir.exist? @this_edit.unquoted_dist_tmp_folder

  unless @this_edit.concat_file_name == ""
    @cncats_array[@this_edit.concat_line[0].to_i] = @this_edit.concat_line[1..-1]
  end
  unless @this_edit.process_this_line == "n"
    DoAllHandle.write @this_edit.simple_trim + "\n"
    DoAllHandle.write @this_edit.fade_trimmed_file + "\n"
  end
end
unless @this_edit.concat_file_name == ""
  @concat_file = @this_edit.dist_concat_file_name
  @concat_handle = File.new @concat_file,"a"
  @concat_handle.truncate(0)
  @cncats_array.each do |thingy|
    @concat_handle.write thingy
    @concat_handle.write "\n"
  end
end
FileUtils.chmod 0774, DoAllFile
IO.popen(DoAllFile) 

