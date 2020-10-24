require "date"
require "fileutils"
require "streamio-ffmpeg"

class String 
  def dquote
    return '"' + self + '"'
  end
end

class Edit
  attr_reader :artist
  attr_reader :composer
  attr_reader :song
  attr_reader :unquoted_dist_tmp_folder
  attr_reader :quoted_dist_tmp_folder

  attr_reader :concat_list_file_name
  attr_reader :dist_concat_list_file_name
  attr_reader :q_dist_concat_list_file_name
  attr_reader :concat_file_line
  attr_reader :concat_filename_base
  attr_reader :do_concat

  attr_reader :video_ffmpeg_duration
  attr_reader :fade_out_start
  attr_reader :calculated_duration_in_secs
  attr_reader :adjusted_opus
  attr_reader :date_with_month_in_text_and_spaces
  attr_reader :derived_tit2
  attr_reader :fade
  attr_reader :mode
  attr_reader :process_mode
  attr_reader :discard_before_total_seconds 
  attr_reader :discard_after_total_seconds 
  attr_reader :video_file_duration
  attr_reader :audio_file_duration
  attr_reader :file_duration 
  #attr_reader :write_the_duration 
  attr_reader :line_of_duration_file
  attr_reader :temp_folder
  attr_reader :handover_hash
  attr_reader :pretrim_video
  attr_reader :vd
  attr_reader :video_delay

  def initialize (options = {})
    @handover_array = options[:array]
    @a2h_handover_hash = Hash.new
    @a2h_handover_hash.update :array_version => @handover_array
    @converter = AHHA.new @a2h_handover_hash
    #@handover_hash = @converter.hash_version
    if options[:array]
      @handover_hash = @converter.hash_version
    elsif options[:hash]
      @handover_hash = options[:hash]
    end

    @process_mode = @handover_hash['process_mode'].to_s.downcase || ""
    if @process_mode == "y"
      #p @handover_hash
    end
    
    @temp_folder = options[:temp_folder]
    @temp_folder_location = options[:temp_folder_location]
    @hash_temp = {'temp_folder' => @temp_folder, 'temp_folder_location' => @temp_folder_location}
    @handover_hash.update @hash_temp
    @filename_builder = FilenameBuilder.new @handover_hash

    ((@process_mode == ("y" || "f")) && @concat_filename_base) ? @do_concat = true : @do_concat = false

    @concat_filename_base = @filename_builder.concat_filename_base
    @concat_list_file_name = @filename_builder.concat_list_file_name
    @q_dist_concat_list_file_name = @filename_builder.q_dist_concat_list_file_name
    @concat_file_line = @filename_builder.concat_file_line
    @dist_concat_list_file_name = @filename_builder.dist_concat_list_file_name

    @unquoted_dist_tmp_folder = @filename_builder.unquoted_dist_tmp_folder
    @quoted_dist_tmp_folder = @filename_builder.quoted_dist_tmp_folder

    #@quoted_dist_input_picture = @filename_builder.quoted_dist_input_picture 

    @tag_list = options[:tag_list].to_s || "tag list not set"
    @discard_before_hours = @handover_hash['discard_before_hours'].to_f || 0
    @discard_before_minutes = @handover_hash['discard_before_minutes'].to_f || 0
    @discard_before_seconds = @handover_hash['discard_before_seconds'].to_f || 0
    @discard_after_hours = @handover_hash['discard_after_hours'].to_f || 0
    @discard_after_minutes = @handover_hash['discard_after_minutes'].to_f || 0
    @discard_after_seconds = @handover_hash['discard_after_seconds'].to_f || 0
    @video_delay = @handover_hash['video_delay'].to_f || 0
    @vd = @filename_builder.vd

    @process_mode = @handover_hash['process_mode'].to_s.downcase || ""
    @distinguisher = @handover_hash['distinguisher'].to_s || ""
    @comment = @handover_hash['comment_used_as_location'].to_s || ""
    @song = @handover_hash['song'].to_s || ""
    @artist = @handover_hash['artist'].to_s || ""
    @composer = @handover_hash['TCOM'].to_s || ""
    @fade = @handover_hash['fade'].to_s.downcase || ""
    @adjusted_comment = @comment != "" ? @comment.downcase.gsub(/ /,'-') + '_' : ""
    @adjusted_artist = (@artist + '_').downcase.gsub(/ /,'-').gsub(/,/,'-').gsub(/--/,'-').gsub(/'/,'-')
    @adjusted_opus = (@handover_hash['opus'] + '_').downcase.gsub(/ /,'-')
    @destination_folder = @filename_builder.destination_folder
    @audio_file_name = @filename_builder.audio_file_name
    @mode = @filename_builder.get_mode
     @discard_before_total_seconds = (@discard_before_hours * 3600) + (@discard_before_minutes * 60) + (@discard_before_seconds)
    @discard_before_cmd = '-ss ' + @discard_before_total_seconds.to_s
    @delayed_discard_before_cmd = '-ss ' + (@discard_before_total_seconds.to_f - @video_delay).to_s
    @discard_after_total_seconds  = (@discard_after_hours * 3600)  + (@discard_after_minutes * 60)  + (@discard_after_seconds)
    @calculated_duration_in_secs = @discard_after_total_seconds - @discard_before_total_seconds
    @discard_after_cmd = ' -t ' + @calculated_duration_in_secs.to_s
    @all_times = @discard_before_hours + @discard_before_minutes + @discard_before_seconds + @discard_after_hours + @discard_after_minutes + @discard_after_seconds
    if self.file_duration && @process_mode == "y" || @process_mode == "d" || @process_mode == "f"
      @line_of_duration_file = self.file_duration.to_s + "," + @artist + "," + @composer + "," + @song + "\n"
    else
      #@line_of_duration_file = "no line for duration file. process_mode is " + @process_mode.inspect + " file_duration is " + self.file_duration.inspect
      @line_of_duration_file = ""
    end

    @derived_tit2 = @artist + ', ' + @composer + ', ' + @song + ' ' + @handover_hash['opus'] + ', ' + @comment + ' ' + @filename_builder.date_with_month_in_text_and_spaces
  end

  def file_duration
    if @mode == "audio" || @mode == "add_picture"
      @time_this_file = @filename_builder.dist_input_audio_pth.full_path
      unless @process_mode == "n"
	@audio_ffmpeg = FFMPEG::Movie.new @time_this_file || "file doesn't exist"
	@audio_file_duration = @audio_ffmpeg.duration
      end
    end
    if @mode == "video" || @mode == "merge"
      @time_this_file = @filename_builder.dist_input_video_pth.full_path
      unless @process_mode == "n"
	@video_ffmpeg = FFMPEG::Movie.new @time_this_file || "file doesn't exist"
	@video_ffmpeg = FFMPEG::Movie.new @filename_builder.dist_input_video_pth.full_path || "file doesn't exist"
	@video_ffmpeg_duration = @video_ffmpeg.duration
	if @calculated_duration_in_secs == 0
	  @video_file_duration = @video_ffmpeg.duration
        elsif
	  @discard_before_total_seconds == 0 && @discard_after_total_seconds > 0
	  @video_file_duration = @discard_after_total_seconds
	elsif @discard_before_total_seconds > 0 && @discard_after_total_seconds == 0
	  @video_file_duration = @video_ffmpeg.duration - @discard_before_total_seconds
	elsif @discard_before_total_seconds > 0 && @discard_after_total_seconds > 0
	  @video_file_duration = @calculated_duration_in_secs 
	else @video_file_duration = 0
	end
        @file_duration = @video_file_duration
        @fade_out_start = @video_file_duration - 1
      end
    elsif @mode == "audio" || @mode == "add_picture" 
      @file_duration = @audio_file_duration
    end
  end
=begin

  def av_simple_merge
    #if @mode == "merge" && (@discard_before_total_seconds + @discard_after_total_seconds == 0)
    if @mode == "merge" && @all_times == 0
      'ffmpeg -y -i ' + @filename_builder.quoted_dist_input_audio_str + ' -i ' + @filename_builder.quoted_dist_input_video_str + ' ' + @filename_builder.quoted_distinguished_calculated_output_filename_str + $/
    else ""
    end
  end
=end
  def add_pic_to_mp3
    if @mode == "add_picture" && @process_mode == "y"
     'ffmpeg -y -loop 1 -r 10 -i ' + @filename_builder.quoted_dist_input_picture + ' -i ' + @filename_builder.quoted_dist_input_audio_str + ' -map 0:v:0 -map 1:a:0 -shortest ' + @filename_builder.q_with_pic_calcd_dist_oput_fname + " \n"
    else ""
    end 
  end
  def concat_command
    unless @filename_builder.concat_list_file_name == ""
      'ffmpeg -y -f concat -safe 0 -i ' + @filename_builder.q_dist_concat_list_file_name + ' -c copy ' + @filename_builder.q_dist_concat_output_file_name + "\n"
    end
  end
  def simple_trim
    #if (@discard_before_hours + @discard_before_minutes + @discard_before_seconds + @discard_after_hours + @discard_after_minutes + @discard_after_seconds) > 0 
    if (@mode == "audio" || @mode == "video") && (@all_times > 0) && (@process_mode == "y" || @process_mode == "f")
    'ffmpeg -y ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @filename_builder.quoted_distinguished_principal_filename + @filename_builder.codec + @filename_builder.quoted_distinguished_calculated_output_filename_str + $/
    #'ffmpeg -y ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @filename_builder.quoted_distinguished_principal_filename + @filename_builder.codec + @filename_builder.quoted_dist_trimmed_temp_output_filename + $/
    else ""
    end
  end
  def pretrim_audio
  #  if (@mode == "merge" || @mode == "add_picture") && ((@discard_before_hours + @discard_before_minutes  + @discard_before_seconds  + @discard_after_hours  + @discard_after_minutes  + @discard_after_seconds) > 0)
    if @mode == "merge" && @all_times  > 0 && @process_mode == "y" 
      'ffmpeg -y ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @filename_builder.quoted_dist_input_audio_str + ' -acodec copy ' + @filename_builder.dist_pretrimmed_audio  + "\n"
    else ""
    end
  end
  def pretrim_video
    if @mode == "merge" && @all_times > 0 && @process_mode == "y"
      'ffmpeg -y ' + (@discard_before_total_seconds == 0 ? "" :  @delayed_discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @filename_builder.quoted_dist_input_video_str + ' -vcodec copy ' + @filename_builder.dist_pretrimmed_video + "\n"
    else ""
    end
  end
  def av_delayed_merge
    if @mode == "merge" && @video_delay > 0 && @process_mode == "y"
      'ffmpeg -y -i ' + @filename_builder.dist_pretrimmed_audio + ' -i ' + @filename_builder.dist_pretrimmed_video + ' ' + @filename_builder.q_temp_merged + "\n"
    else ""
    end
  end
  def fade_picture_added_file
    if @fade == "y" && @process_mode == "y" && @mode == "add_picture"
      'ffmpeg -y -i ' + @filename_builder.q_with_pic_calcd_dist_oput_fname + ' -vf "fade=type=in:duration=1,fade=type=out:duration=1:start_time=' + @fade_out_start.to_s + '" -c:a copy ' + @filename_builder.q_fade_trim_calcd_dist_oput_fname  + "\n"
    else ""
    end
  end
  def fade_merged_pretrimmed_file
    if @mode == "merge" && @fade == "y" && @process_mode == "y"
      'ffmpeg -y -i ' + @filename_builder.q_temp_merged + ' -vf "fade=type=in:duration=1,fade=type=out:duration=1:start_time=' + @fade_out_start.to_s + '" -c:a copy ' + @filename_builder.q_fade_trim_calcd_dist_oput_fname + "\n" 
    else ""
    end
  end
  def fade_trimmed_file
    if @mode == "video" && @fade == "y" && @process_mode == "y"
      'ffmpeg -y -i ' + @filename_builder.quoted_dist_trimmed_temp_output_filename + ' -vf "fade=type=in:duration=1,fade=type=out:duration=1:start_time=' + @fade_out_start.to_s + '" -c:a copy ' + @filename_builder.q_fade_trim_calcd_dist_oput_fname + "\n"
    else ""
    end
  end


  def tag_command
    set_tags = String.new
    @handover_hash.each do |key, value|
      if key == "TIT2" && value == ""
        value = self.derived_tit2
      end
      if @tag_list.include? key.to_s 
        if value != ""
          set_tags = set_tags + ' --' + key.to_s + ' "' + value.to_s + '"'
        end
      end
    end
    @tag_command = 'id3v2 ' + @filename_builder.quoted_distinguished_calculated_output_filename_str + set_tags
  end
end

class AHHA
  def initialize (options = {})
    @array_version = options[:array_version]
  end
  def hash_version 
    @length = @array_version[0].length
    @hash_version = Hash.new
    for col in 0..@length-1
      @hash_version[@array_version[0][col]] = @array_version[1][col] || ""
    end
    @hash_version
  end
  def hash_version_with_symbols 
    @length = @array_version[0].length
    @hash_version_with_symbols = Hash.new
    for col in 0..@length-1
      @hash_version_with_symbols[@array_version[0][col]].to_sym = @array_version[1][col] || ""
    end
    @hash_version_with_symbols
  end
end


class FilenameBuilder < String
  attr_reader :distinguisher
  attr_reader :opus
  attr_reader :mode
  attr_reader :artist

  attr_reader :audio_file_name
  attr_reader :video_file_name
  attr_reader :video_file_location
  attr_reader :audio_file_location
#FilenameBuilder
  attr_reader :concat_filename_base
  attr_reader :concat_list_file_name
  attr_reader :dist_concat_list_file_name
  attr_reader :q_dist_concat_list_file_name
  attr_reader :concat_file_line
  attr_reader :concat_output_file_name
  attr_reader :q_dist_concat_output_file_name

  attr_reader :quoted_dist_input_audio_str 
  attr_reader :quoted_dist_input_video_str #
  attr_reader :dist_input_video_pth
  attr_reader :dist_input_audio_pth 
  attr_reader :q_with_pic_calcd_dist_oput_fname 
#FilenameBuilder
  attr_reader :extnless_pretrimmed_audio 
  attr_reader :dist_pretrimmed_audio 
  attr_reader :extnless_pretrimmed_video 
  attr_reader :dist_pretrimmed_video 
  attr_reader :extnless_temp_merged
  attr_reader :q_temp_merged

  attr_reader :calculated_extensionless_output_filename
  attr_reader :quoted_distinguished_calculated_output_filename_str 
  attr_reader :calculated_extensionless_trimmed_output_filename
  attr_reader :unquoted_distinguished_calculated_trimmed_output_filename
  attr_reader :quoted_distinguished_calculated_trimmed_output_filename
  attr_reader :quoted_dist_trimmed_temp_output_filename
  attr_reader :fade_trim_calcd_extnless_oput_fname 
  attr_reader :q_fade_trim_calcd_dist_oput_fname 
  attr_reader :destination_folder

  attr_reader :quoted_distinguished_principal_filename 
  attr_reader :principal_file_extension

  attr_reader :temp_folder
  attr_reader :quoted_dist_tmp_folder
  attr_reader :unquoted_dist_tmp_folder
  attr_reader :quoted_dist_input_picture 
  attr_reader :date_with_month_in_text_and_spaces 
  
  attr_reader :vd

#FilenameBuilder
  def initialize (options = {})
    @distinguisher = options['distinguisher'] || ""
    @opus = options['opus'] || ""
    @artist = options['artist'].to_s || ""
    @comment = options['comment'].to_s || ""
    @audio_file_location = options['audio_file_location'].to_s || ""
    @audio_file_name = options['audio_file_name'].to_s || ""
    @video_file_location = options['video_file_location'].to_s || ""
    @video_file_name = options['video_file_name'].to_s || ""
    @picture_file_location = options['picture_file_location'].to_s || ""
    @picture_file_name = options['picture_file_name'].to_s || ""
    @destination_folder = options['destination_folder'].to_s || ""
    @concat_filename_base = options['concat_filename_base'] || ""
    @temp_folder = options['temp_folder'].to_s || ""
#FilenameBuilder
    options['concat_filename_base'].to_s ? @concat_list_file_name = 'concat_' + @concat_filename_base + '.txt': "" 
    @adjusted_comment = @comment != "" ? @comment.downcase.gsub(/ /,'-') + '_' : ""
    @adjusted_opus = (@opus + '_').downcase.gsub(/ /,'-')
    @adjusted_artist = (@artist + '_').downcase.gsub(/ /,'-').gsub(/,/,'-').gsub(/--/,'-').gsub(/'/,'-')

    if options['temp_folder_location']
      @unquoted_dist_tmp_folder =(Path.new :path => options['temp_folder_location'], :extra => @temp_folder).full_path
    else
      @unquoted_dist_tmp_folder = (Path.new :path => options['destination_folder'], :extra => @temp_folder).full_path
    end
#FilenameBuilder
    if (@audio_file_name[0,2].to_i > 0) && (@audio_file_name[2,2].to_i > 0) && (@audio_file_name[4,2].to_i > 0)
      @date_with_month_in_text = @audio_file_name[4,2] + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].downcase + @audio_file_name[0,2]
      @date_with_month_in_text_and_spaces = @audio_file_name[4,2] + ' ' + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].capitalize + ' 20' + @audio_file_name[0,2]
    else
      @date_with_month_in_text = ""
      @date_with_month_in_text_and_spaces = ""
    end

    if options['video_delay']
      @vd = (options['video_delay'].to_f * 100).to_i
      @calculated_extensionless_trimmed_output_filename = @adjusted_artist + 'tr' + @distinguisher + '-vd' + @vd.to_s + '_' + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
    @end_of_filename = @distinguisher + '-vd' + @vd.to_s + '_' + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
    else
      #@calculated_extensionless_trimmed_output_filename = @adjusted_artist + 'tr' + @distinguisher + '_' + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
      @calculated_extensionless_trimmed_output_filename = @adjusted_artist + 'tr' + @distinguisher + '_' + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
    @end_of_filename = @distinguisher + '_' + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
    end

#FilenameBuilder
    @dist_picture = Path.new :path => @picture_file_location, :extra => @picture_file_name
    @quoted_dist_input_picture = @dist_picture.full_path_in_dquotes

    @dist_input_video_pth = Path.new :path => @video_file_location, :extra => @video_file_name
    @dist_input_audio_pth = Path.new :path => @audio_file_location, :extra => @audio_file_name
    @quoted_dist_input_video_str = @dist_input_video_pth.full_path_in_dquotes
    @quoted_dist_input_audio_str = @dist_input_audio_pth.full_path_in_dquotes

    principal_file == "audiofile" ? @quoted_distinguished_principal_filename = @quoted_dist_input_audio_str : @quoted_distinguished_principal_filename = @quoted_dist_input_video_str 
    principal_file == "audiofile" ? @principal_file_extension = (File.extname @audio_file_name).downcase :  @principal_file_extension = (File.extname @video_file_name).downcase
    @mode == "add_picture" ? @principal_file_extension = "mp4" : ""

    options['concat_filename_base'].to_s ? @concat_output_file_name = 'combined_' + @concat_filename_base + @principal_file_extension : "" 
    @q_dist_concat_output_file_name = (Path.new :path => options['destination_folder'], :extra => @concat_output_file_name).full_path_in_dquotes

#FilenameBuilder
    @calculated_extensionless_output_filename = @adjusted_artist + @end_of_filename

    @quoted_distinguished_calculated_output_filename_str = (Path.new :path => @destination_folder, :extra => @calculated_extensionless_output_filename, :extension_to_add => @principal_file_extension).full_path_in_dquotes

    @quoted_dist_input_audio_str = (Path.new :path => @audio_file_location, :extra => @audio_file_name).full_path_in_dquotes
    @fade_trim_calcd_extnless_oput_fname              = @adjusted_artist + 'tf' + @end_of_filename
    @with_pic_calcd_extnless_oput_fname              = @adjusted_artist + 'wp' + @end_of_filename
    @extnless_pretrimmed_audio = @adjusted_artist + 'pta' + @end_of_filename
    @extnless_pretrimmed_video = @adjusted_artist + 'ptv' + @end_of_filename
    @extnless_temp_merged = @adjusted_artist + 'mtr' + @end_of_filename
#FilenameBuilder 
    @dist_pretrimmed_audio = (Path.new :path => @unquoted_dist_tmp_folder, :extr2 => extnless_pretrimmed_audio, :extension_to_add => (File.extname @audio_file_name).downcase).full_path_in_dquotes
    @dist_pretrimmed_video = (Path.new :path => @unquoted_dist_tmp_folder, :extr2 => extnless_pretrimmed_video, :extension_to_add => (File.extname @video_file_name).downcase).full_path_in_dquotes
    @q_temp_merged = (Path.new :path => @unquoted_dist_tmp_folder, :extr2 => extnless_temp_merged, :extension_to_add => (File.extname @video_file_name).downcase).full_path_in_dquotes
    #@dist_pretrimmed_audio = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => extnless_pretrimmed_audio, :extension_to_add => (File.extname @audio_file_name).downcase).full_path_in_dquotes
    #@dist_pretrimmed_video = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => extnless_pretrimmed_video, :extension_to_add => (File.extname @video_file_name).downcase).full_path_in_dquotes
    #@q_temp_merged = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => extnless_temp_merged, :extension_to_add => (File.extname @video_file_name).downcase).full_path_in_dquotes

    @unquoted_distinguished_calculated_trimmed_output_filename = (Path.new :path => @destination_folder, :extra => @calculated_extensionless_trimmed_output_filename, :extension_to_add => @principal_file_extension).full_path
    @quoted_distinguished_calculated_trimmed_output_filename = (Path.new :path => @destination_folder, :extra => @calculated_extensionless_trimmed_output_filename, :extension_to_add => @principal_file_extension).full_path_in_dquotes

    @fade_trim_calcd_dist_oput_fname = (Path.new :path => options['destination_folder'], :extra => @fade_trim_calcd_extnless_oput_fname, :extension_to_add => @principal_file_extension).full_path
    @q_fade_trim_calcd_dist_oput_fname = (Path.new :path => options['destination_folder'], :extra => @fade_trim_calcd_extnless_oput_fname, :extension_to_add => @principal_file_extension).full_path_in_dquotes

    #@q_with_pic_calcd_dist_oput_fname = (Path.new :path => options['destination_folder'], :extr2 => @with_pic_calcd_extnless_oput_fname, :extra => @temp_folder, :extension_to_add => @principal_file_extension).full_path_in_dquotes
    @q_with_pic_calcd_dist_oput_fname = (Path.new :path => @unquoted_dist_tmp_folder, :extr2 => @with_pic_calcd_extnless_oput_fname, :extension_to_add => @principal_file_extension).full_path_in_dquotes
    @quoted_dist_tmp_folder = (Path.new :path => @unquoted_dist_tmp_folder).full_path_in_dquotes
    @quoted_dist_trimmed_temp_output_filename = (Path.new :path => @unquoted_dist_tmp_folder, :extr2 => @calculated_extensionless_trimmed_output_filename, :extension_to_add => @principal_file_extension).full_path_in_dquotes
    #@quoted_dist_tmp_folder = (Path.new :path => options['destination_folder'], :extra => @temp_folder).full_path_in_dquotes
    #@quoted_dist_trimmed_temp_output_filename = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => @calculated_extensionless_trimmed_output_filename, :extension_to_add => @principal_file_extension).full_path_in_dquotes

    if options['concat_filename_base'].to_s 
      @q_dist_concat_list_file_name = (Path.new :path => @unquoted_dist_tmp_folder, :extr2 => @concat_list_file_name).full_path_in_dquotes 
      @dist_concat_list_file_name = (Path.new :path => @unquoted_dist_tmp_folder, :extr2 => @concat_list_file_name).full_path
      @concat_file_line = "file '" + @fade_trim_calcd_dist_oput_fname + "'" + $/
    else  ""
    end
=begin
    options['concat_filename_base'].to_s ? @q_dist_concat_list_file_name = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => @concat_list_file_name).full_path_in_dquotes : ""
    options['concat_filename_base'].to_s ? @dist_concat_list_file_name = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => @concat_list_file_name).full_path : ""
    @concat_file_line = "file '" + @fade_trim_calcd_dist_oput_fname + "'" + $/
=end
  end

#FilenameBuilder
  def get_mode
    @mode = "dunno"
    if (@quoted_dist_input_picture != '""') && (@quoted_dist_input_video_str == '""')
      @mode = "add_picture"
    elsif (@quoted_dist_input_video_str == '""') && (@quoted_dist_input_audio_str != '""')
      @mode = "audio"
    elsif (@quoted_dist_input_video_str != '""') && (@quoted_dist_input_audio_str != '""')
      @mode = "merge"
    elsif (@quoted_dist_input_video_str != '""') && (@quoted_dist_input_audio_str == '""')
      @mode = "video"
    end
  @mode
  end

  def principal_file
    case self.get_mode
    when "audio"
      @principal_filename = "audiofile"
    when "video"
      @principal_filename = "videofile"
    when "merge"
      @principal_filename = "videofile"
    when "add_picture"
      @principal_filename = "audiofile"
    else
      @principal_filename = "prin-din"
    end
    @principal_filename
  end

  def codec
    case self.get_mode
    when "audio" 
      @codec = " -acodec copy "
    when "video"
      @codec = " -vcodec copy "
    when "merge"
      @codec = " -vcodec copy "
    else 
      @codec = ""
    end
  end
end
#FilenameBuilder

class Path < String
  attr_reader :path
  attr_reader :extension
  attr_reader :dquoty
  attr_reader :extended
  attr_reader :extended_quoty 
  attr_reader :with_extension
  attr_reader :full_path
  attr_reader :full_path_in_dquotes
  def initialize (options = {})
    @path = options[:path] || ""
    @path.chars[-1] == '/' ?  @path = @path.chop : @path
    @extra = options[:extra] || ""
    @extr2 = options[:extr2] || ""
    @extension_to_add = options[:extension_to_add] || ""
    @extension_to_add[0] == '.' ? @extension_to_add[0] = '' : @extension_to_add
    @extension = (File.extname @path).downcase
    @extra == "" ? @extended = @path : @extended = @path + '/' + @extra
    @extr2 == "" ? @extended = @extended : @extended = @extended + '/' + @extr2
    @extension_to_add == "" ? @with_extension = @extended : @with_extension = @extended + '.' + @extension_to_add
    @extension_to_add == "" ? @full_path = @extended : @full_path = @extended + '.' + @extension_to_add
    @dquoty = @path.dquote 
    @full_path_in_dquotes = @full_path.dquote
  end
end

class Cncats < Array
  attr_accessor :line
  def initialize
    @conkats_array = Array.new
  end
  def add_line
  end
    
end
