require "csv"
require "./lib/edit.rb"
require "parseconfig"
#require "FileUtils"

puts "SYNTAX: ruby trimp3.rb config.conf list_of_edits_and_tags.csv /path/to/outputfile/outputfileprefix y"
puts "leave off the final y (can be anything) to just display the DoAllFile"
puts "if the video file exists, it is treated as the principal file"
puts "REMINDER: save csv with tab as field separator"
puts "ANOTHER THING: csv's with empty fields make it crash, so set process_this_line to n"
puts "COMMAND LINE PARAMETERS:" + ARGV.inspect

@proj_title = ARGV[2] || ""
@timings_csv = @proj_title + "_timings.csv"
@timings_handle = File.open @timings_csv,"w+"
@timings_only_csv = @proj_title + "_timings_only.csv"
@timings_only_handle = File.open @timings_only_csv,"w+"
DoAllFile = @proj_title + "_do_all\.txt"
DoAllHandle = File.open DoAllFile,"w+"
puts "FILE TO RUN IS " + DoAllFile.inspect 

ConfigFile = ARGV[0]
ConfPC = ParseConfig.new ConfigFile
ConfHash = ConfPC.params.freeze
puts "CONFIG HASH IS " + ConfHash.inspect 

CsvFile = ARGV[1]
if File.exist? CsvFile
  CsvArray = CSV.read CsvFile, {:col_sep => "\t"}
else
  puts; puts "The CSV file '" + CsvFile + "' doesn't exist"; puts
  exit
end
 

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

puts "no of rows in array:" + (CsvArray.length-1).to_s.inspect
puts "no of columns in array:" + Width.inspect
for row in 1..CsvArray.length-1
  ThisLinePlusTitlesArray[0] = CsvArray[0]
  ThisLinePlusTitlesArray[1] = CsvArray[row]
  Handover.update :array => ThisLinePlusTitlesArray
  @this_edit = Edit.new Handover

  @timings_handle.write (@this_edit.file_duration.to_s + "," + @this_edit.artist + "," + @this_edit.composer + "," + @this_edit.song + "\n") if @this_edit.file_duration > 0
  @timings_only_handle.write (@this_edit.file_duration.to_s + "\n") if @this_edit.file_duration
  if @this_edit.process_this_line.downcase == "y"
    FileUtils.mkdir_p @this_edit.unquoted_dist_tmp_folder unless Dir.exist? @this_edit.unquoted_dist_tmp_folder
    case @this_edit.mode
      when "audio"
        DoAllHandle.write @this_edit.simple_trim + "\n"
      when "video"
        DoAllHandle.write @this_edit.simple_trim + "\n"
        DoAllHandle.write @this_edit.fade_trimmed_file + "\n"
      when "merge"
	DoAllHandle.write @this_edit.pretrim_audio + "\n"
	DoAllHandle.write @this_edit.pretrim_video + "\n"
	DoAllHandle.write @this_edit.av_delayed_merge + "\n"
	DoAllHandle.write @this_edit.fade_merged_pretrimmed_file + "\n"
      when "add_picture"
        DoAllHandle.write @this_edit.add_pic_to_mp3 + "\n"
        DoAllHandle.write @this_edit.fade_picture_added_file + "\n"
    end
=begin
=end
    unless @this_edit.concat_filename_base == ""
      @concat_handle = File.open(@this_edit.dist_concat_list_file_name, "a+")
      @concat_handle.write @this_edit.concat_file_line
      @concat_handle.write "\n"
      @concat_handle.close
      DoAllHandle.write @this_edit.concat_command + "\n"
    end
  end
end
DoAllHandle.close
@timings_handle.close
@timings_only_handle.close

File.open(DoAllFile).each do |line|
  p line
end
puts "That was " + DoAllFile.inspect

File.open(@timings_csv).each do |line|
  p line
end
puts "That was " + @timings_csv.inspect

FileUtils.chmod 0774, DoAllFile
IO.popen(DoAllFile) if ARGV[3]
