require "csv"
require "./lib/edit.rb"
require "parseconfig"
#require "FileUtils"

p @proj_title = ARGV[2] || "/Users/martinpick/git/trimp3/work_files/default_trimp3"
@timings_csv = @proj_title + "_timings.csv"
@timings_handle = File.open @timings_csv,"w+"
DoAllFile = @proj_title + "_do_all\.txt"
DoAllHandle = File.open DoAllFile,"w+"
puts "FILE TO RUN IS " + DoAllFile.inspect 

ConfigFile = ARGV[0] || "/Users/martinpick/git/trimp3/conf/config.conf"
ConfPC = ParseConfig.new ConfigFile
ConfHash = ConfPC.params.freeze
puts "CONFIG HASH IS " + ConfHash.inspect 

@csv_file = ARGV[1] || "/Users/martinpick/git/trimp3/work_files/trimp3sheet.csv" 
#work_files/do_trimp3/dotrimp3
if File.exist? @csv_file
  @csv_array = CSV.read @csv_file, {:col_sep => "\t"}
else
  puts; puts "The CSV file '" + @csv_file + "' doesn't exist"; puts
  exit
end
 
if File.exist? ConfHash['temp_folder_location']
  FileUtils.rm_rf ConfHash['temp_folder_location']
  FileUtils.mkdir ConfHash['temp_folder_location']
end
p "tried to remove " + ConfHash['temp_folder_location'].inspect

TagListFile = ConfHash['tag_list'] || "tag_list not set"
TagListFileHandle = File.open TagListFile,"r"
TagListFileString = TagListFileHandle.read.to_s
OriginalFileLocationFromConfig = ConfHash['file_location']

Width = @csv_array.transpose.length
ThisLinePlusTitlesArray = Array.new
ThisLinePlusTitlesHash = Hash.new
Handover = Hash.new
Handover.update :temp_folder => ConfHash['temp_folder']
Handover.update :temp_folder_location => ConfHash['temp_folder_location']
A2HHandover = Hash.new

puts "no of rows in array:" + (@csv_array.length-1).to_s.inspect
puts "no of columns in array:" + Width.inspect + "\n"
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
for row in 1..@csv_array.length-1
  ThisLinePlusTitlesArray[0] = @csv_array[0]
  ThisLinePlusTitlesArray[1] = @csv_array[row]
  Handover.update :array => ThisLinePlusTitlesArray
  @this_edit = Edit.new Handover
  FileUtils.mkdir_p @this_edit.unquoted_dist_tmp_folder unless Dir.exist? @this_edit.unquoted_dist_tmp_folder
  puts 'csv line number ' +  @this_edit.distinguisher
  unless @this_edit.destination_folder == ""
    FileUtils.mkdir_p @this_edit.destination_folder unless Dir.exist? @this_edit.destination_folder
  end
  @process_mode = @this_edit.process_mode
  @timings_handle.write @this_edit.line_of_duration_file
  DoAllHandle.write @this_edit.audio_trim
  DoAllHandle.write @this_edit.video_trim
  DoAllHandle.write @this_edit.pretrim_audio
  DoAllHandle.write @this_edit.pretrim_video
  DoAllHandle.write @this_edit.av_delayed_merge
  DoAllHandle.write @this_edit.add_pic_to_mp3
  DoAllHandle.write @this_edit.fade_merged_pretrimmed_file
  DoAllHandle.write @this_edit.fade_trimmed_file
  DoAllHandle.write @this_edit.fade_picture_added_file
  if @process_mode == "y" || @process_mode == "s" || @process_mode == "f"
    FileUtils.mkdir_p @this_edit.unquoted_dist_tmp_folder unless Dir.exist? @this_edit.unquoted_dist_tmp_folder
    if @this_edit.do_concat_command
      @concat_handle = File.open(@this_edit.dist_concat_list_file_name, "a+")
      @concat_handle.write @this_edit.concat_file_line
      @concat_handle.close
      DoAllHandle.write @this_edit.concat_command + "\n"
    end
  end
end
DoAllHandle.close
@timings_handle.close
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
File.open(@timings_csv).each do |line|
  p line
end
puts "That was " + @timings_csv.inspect
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
File.open(DoAllFile).each do |line|
  p line
end
puts "That was " + DoAllFile.inspect
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts "SYNTAX: ruby y trimp3.rb config.conf list_of_edits_and_tags.csv /path/to/outputfile/outputfileprefix"
puts "leave off the initial y (can be anything) to just display the DoAllFile"
puts "if the video file exists, it is treated as the principal file"
puts "REMINDER: save csv with tab as field separator"
puts "ANOTHER THING: csv's with empty fields make it crash, so set process_mode to n"
puts "process_mode can be y (yes), n (no), f (fade), d (duration), s (short clip to test sync when merging)"
puts "video_delay is in seconds, resolved to hundredths of a second"
puts "COMMAND LINE PARAMETERS:" + ARGV.inspect

FileUtils.chmod 0774, DoAllFile
IO.popen(DoAllFile) if ARGV[3]
