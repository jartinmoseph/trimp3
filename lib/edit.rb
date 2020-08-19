require "date"
require "fileutils"
require "streamio-ffmpeg"

class String 
  def dquote
    return '"' + self + '"'
  end
end

class Edit
  attr_reader :quoted_dist_input_audio_str 
  attr_reader :quoted_dist_input_video_str 
  attr_reader :calculated_extensionless_output_filename
  attr_reader :unquoted_dist_tmp_folder

  attr_reader :concat_file_name
  attr_reader :dist_concat_file_name
  attr_reader :concat_line

  attr_reader :video_ffmpeg_duration
  attr_reader :fade_out_start
  attr_reader :calculated_duration_in_secs
  attr_reader :adjusted_opus
  attr_reader :date_with_month_in_text_and_spaces
  attr_reader :derived_tit2
  attr_reader :principal_file_extension
  attr_reader :fade
  attr_reader :mode
  attr_reader :process_this_line
  attr_reader :video_file_duration
  attr_reader :temp_folder

  attr_reader :fnb_opus
  attr_reader :handover_hash

  def initialize (options = {})
    @handover_array = options[:array]
    @a2h_handover_hash = Hash.new
    @a2h_handover_hash.update :array_version => @handover_array
    @converter = AHHA.new @a2h_handover_hash
    @handover_hash = @converter.hash_version
    @temp_folder = options[:temp_folder]
    @hash_temp = {'temp_folder' => @temp_folder}
    @handover_hash.update @hash_temp
    @filename_builder = FilenameBuilder.new @handover_hash

    @concat_file_name = @handover_hash['concat_file_name']
    @dist_concat_file_name = @filename_builder.dist_concat_file_name
    @concat_line = @filename_builder.concat_line
    @unquoted_dist_tmp_folder = @filename_builder.unquoted_dist_tmp_folder

    @tag_list = options[:tag_list].to_s || "tag list not set"
    @discard_before_hours = @handover_hash['discard_before_hours'].to_f || 0
    @discard_before_minutes = @handover_hash['discard_before_minutes'].to_f || 0
    @discard_before_seconds = @handover_hash['discard_before_seconds'].to_f || 0
    @discard_after_hours = @handover_hash['discard_after_hours'].to_f || 0
    @discard_after_minutes = @handover_hash['discard_after_minutes'].to_f || 0
    @discard_after_seconds = @handover_hash['discard_after_seconds'].to_f || 0

    @process_this_line = @handover_hash['process_this_line'].to_s.downcase || ""
    @distinguisher = @handover_hash['distinguisher'].to_s || ""
    @comment = @handover_hash['comment_used_as_location'].to_s || ""
    @song = @handover_hash['song'].to_s || ""
    @artist = @handover_hash['artist'].to_s || ""
    @composer = @handover_hash['TCOM'].to_s || ""
    @fade = @handover_hash['fade'].to_s.downcase || ""
    @adjusted_comment = @comment != "" ? @comment.downcase.gsub(/ /,'-') + '_' : ""
    @adjusted_artist = (@artist + '_').downcase.gsub(/ /,'-').gsub(/,/,'-').gsub(/--/,'-').gsub(/'/,'-')
    @adjusted_opus = (@handover_hash['opus'] + '_').downcase.gsub(/ /,'-')

    #@audio_file_name = @handover_hash['audio_file_name'].to_s || ""
    #@video_file_name = @handover_hash['video_file_name'].to_s || ""
    #@video_file_location = @handover_hash['video_file_location'].to_s || ""
    #@audio_file_location = @handover_hash['audio_file_location'].to_s || ""
    #@destination_folder = @handover_hash['destination_folder'].to_s || ""
    #@audio_file_location = @filename_builder.audio_file_location
    #@video_file_name = @filename_builder.video_file_name
    @destination_folder = @filename_builder.destination_folder
    @audio_file_name = @filename_builder.audio_file_name
    @mode = @filename_builder.get_mode
    @fnb_opus = @filename_builder.opus

    @dist_input_video_pth = Path.new :path => @filename_builder.video_file_location, :extra => @filename_builder.video_file_name
    @quoted_dist_input_video_str = @dist_input_video_pth.full_path_in_dquotes
    @quoted_dist_input_audio_str = @filename_builder.quoted_dist_input_audio_str 
    #@quoted_dist_input_audio_str = (Path.new :path => @filename_builder.audio_file_location, :extra => @audio_file_name).full_path_in_dquotes
=begin
    if @quoted_dist_input_video_str == '""' && @dquoted_dist_input_audio_str != '""'
      @mode = "audio"
    elsif @quoted_dist_input_video_str != '""' && @dquoted_dist_input_audio_str == '""'
      @mode = "video"
    elsif @quoted_dist_input_video_str != '""' && @dquoted_dist_input_audio_str != '""'
      @mode = "merge"
    end

    if @quoted_dist_input_video_str == '""' 
      @mode = "audio"
      @quoted_distinguished_principal_filename = @quoted_dist_input_audio_str 
      @principal_file_extension = (File.extname @audio_file_name).downcase
    elsif @dquoted_dist_input_audio_str == '""'
      @mode = "video"
      @quoted_distinguished_principal_filename = @quoted_dist_input_video_str
      @principal_file_extension = (File.extname @filename_builder.video_file_name).downcase
    else
      @mode = "merge"
      @quoted_distinguished_principal_filename = @quoted_dist_input_video_str
      @principal_file_extension = (File.extname @filename_builder.video_file_name).downcase
    end
    @mode == "audio" ? @quoted_distinguished_principal_filename = @quoted_dist_input_audio_str : @quoted_distinguished_principal_filename = @quoted_dist_input_video_str
    @mode == "audio" ? @principal_file_extension = (File.extname @audio_file_name).downcase :  @principal_file_extension = (File.extname @filename_builder.video_file_name).downcase
    @quoted_distinguished_principal_filename = @filename_builder.quoted_distinguished_principal_filename 
    @principal_file_extension = @filename_builder.principal_file_extension 
=end


    if (@audio_file_name[0,2].to_i > 0) && (@audio_file_name[2,2].to_i > 0) && (@audio_file_name[4,2].to_i > 0)
      @date_with_month_in_text = @audio_file_name[4,2] + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].downcase + @audio_file_name[0,2]
      @date_with_month_in_text_and_spaces = @audio_file_name[4,2] + ' ' + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].capitalize + ' 20' + @audio_file_name[0,2]
    else
      @date_with_month_in_text = ""
      @date_with_month_in_text_and_spaces = ""
    end

    @derived_tit2 = @artist + ', ' + @composer + ', ' + @song + ' ' + @handover_hash['opus'] + ', ' + @comment + ' ' + @date_with_month_in_text_and_spaces

    #@calculated_extensionless_output_filename = @adjusted_artist + (@distinguisher != "" ? @distinguisher + '_' : "") + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
    @calculated_extensionless_output_filename = @filename_builder.calculated_extensionless_output_filename 
    #@calculated_extensionless_output_filename = @calculated_extensionless_output_filename.gsub(/,/,'') 
    @discard_before_total_seconds = (@discard_before_hours * 3600) + (@discard_before_minutes * 60) + (@discard_before_seconds)
    @discard_before_cmd = '-ss ' + @discard_before_total_seconds.to_s
    @discard_after_total_seconds  = (@discard_after_hours * 3600)  + (@discard_after_minutes * 60)  + (@discard_after_seconds)
    @calculated_duration_in_secs = @discard_after_total_seconds - @discard_before_total_seconds
    @discard_after_cmd = ' -t ' + @calculated_duration_in_secs.to_s
    if @mode == "video" || @mode == "merge"
      unless @process_this_line == "n"
	@video_ffmpeg = FFMPEG::Movie.new @dist_input_video_pth.full_path 
        @video_ffmpeg_duration = @video_ffmpeg.duration
	  if @calculated_duration_in_secs == 0
	    @video_file_duration = @video_ffmpeg.duration
	  elsif @discard_before_total_seconds == 0 && @discard_after_total_seconds > 0
	    @video_file_duration = @discard_after_total_seconds
	  elsif @discard_before_total_seconds > 0 && @discard_after_total_seconds == 0
	    @video_file_duration = @video_ffmpeg.duration - @discard_before_total_seconds
	  elsif @discard_before_total_seconds > 0 && @discard_after_total_seconds > 0
	    @video_file_duration = @calculated_duration_in_secs 
	  else @video_file_duration = 0
	  end
	@fade_out_start = @video_file_duration - 1
      end
    end
  end
  def fade_trimmed_file
    if @fade == "y" && @process_this_line != "n"
      'ffmpeg -i ' + @filename_builder.quoted_dist_trimmed_temp_output_filename + ' -vf "fade=type=in:duration=1,fade=type=out:duration=1:start_time=' + @fade_out_start.to_s + '" -c:a copy ' + @filename_builder.q_fade_trim_calcd_dist_oput_fname 
    else ""
    end
  end

  def simple_trim
    if (@discard_before_hours + @discard_before_minutes  + @discard_before_seconds  + @discard_after_hours  + @discard_after_minutes  + @discard_after_seconds) > 0 
    'ffmpeg ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @filename_builder.quoted_distinguished_principal_filename + ' -vcodec copy -acodec copy ' + @filename_builder.quoted_dist_trimmed_temp_output_filename
    else ""
    end
  end

  def av_trim_merge
    if @mode == "merge"
      'ffmpeg ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @quoted_dist_input_audio_str + ' ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @quoted_dist_input_video_str + ' ' + @filename_builder.quoted_distinguished_calculated_trimmed_output_filename
    else ""
    end
  end
  def av_simple_merge
    if @mode == "merge" && (@discard_before_total_seconds + @discard_after_total_seconds == 0)
      'ffmpeg -i ' + @quoted_dist_input_audio_str + ' -i ' + @quoted_dist_input_video_str + ' ' + @filename_builder.quoted_distinguished_calculated_output_filename_str
    else ""
    end
  end
  def av_delayed_merge
    'ffmpeg -i ' + @audio_file_name + ' -itsoffset ' + @handover_hash['audio_delay'] + ' -i ' + @filename_builder.video_file_name + ' -map 0:a -map 1:v -c copy ' + @filename_builder.quoted_distinguished_calculated_output_filename_str
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
  attr_reader :audio_file_name
  attr_reader :video_file_name
  attr_reader :mode
  attr_reader :video_file_location
  attr_reader :audio_file_location
  attr_reader :destination_folder
  attr_reader :temp_folder
  attr_reader :artist
  attr_reader :concat_file_name
  attr_reader :concat_order

  attr_reader :quoted_dist_input_audio_str 
  attr_reader :quoted_dist_input_video_str #

  attr_reader :calculated_extensionless_output_filename
  attr_reader :quoted_distinguished_principal_filename 
  attr_reader :quoted_distinguished_calculated_output_filename_str 
  attr_reader :calculated_extensionless_trimmed_output_filename
  attr_reader :quoted_distinguished_calculated_trimmed_output_filename
  attr_reader :unquoted_distinguished_calculated_trimmed_output_filename
  attr_reader :fade_trim_calcd_extnless_oput_fname 
  attr_reader :q_fade_trim_calcd_dist_oput_fname 
  attr_reader :quoted_dist_trimmed_temp_output_filename
  attr_reader :quoted_dist_tmp_folder
  attr_reader :unquoted_dist_tmp_folder
  attr_reader :principal_file_extension
  attr_reader :dist_concat_file_name
  attr_reader :concat_line
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
    @destination_folder = options['destination_folder'].to_s || ""
    @temp_folder = options['temp_folder'].to_s || ""
    @concat_file_name = options['concat_file_name'].to_s || ""
    @concat_order = options['concat_order'].to_s || ""

    options['concat_file_name'].to_s ? @concat_file_name = 'concat_' + @concat_file_name + '.txt': @concat_file_name
#FilenameBuilder
    if (@audio_file_name[0,2].to_i > 0) && (@audio_file_name[2,2].to_i > 0) && (@audio_file_name[4,2].to_i > 0)
      @date_with_month_in_text = @audio_file_name[4,2] + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].downcase + @audio_file_name[0,2]
      @date_with_month_in_text_and_spaces = @audio_file_name[4,2] + ' ' + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].capitalize + ' 20' + @audio_file_name[0,2]
    else
      @date_with_month_in_text = ""
      @date_with_month_in_text_and_spaces = ""
    end

    @adjusted_comment = @comment != "" ? @comment.downcase.gsub(/ /,'-') + '_' : ""
    @adjusted_opus = (@opus + '_').downcase.gsub(/ /,'-')
    @adjusted_artist = (@artist + '_').downcase.gsub(/ /,'-').gsub(/,/,'-').gsub(/--/,'-').gsub(/'/,'-')

    @dist_input_video_pth = Path.new :path => @video_file_location, :extra => @video_file_name
    @quoted_dist_input_video_str = @dist_input_video_pth.full_path_in_dquotes
    @quoted_dist_input_audio_str = (Path.new :path => @audio_file_location, :extra => @audio_file_name).full_path_in_dquotes
    principal_file == "audiofile" ? @quoted_distinguished_principal_filename = @quoted_dist_input_audio_str : @quoted_distinguished_principal_filename = @quoted_dist_input_video_str 
    principal_file == "audiofile" ? @principal_file_extension = (File.extname @audio_file_name).downcase :  @principal_file_extension = (File.extname @video_file_name).downcase

#FilenameBuilder

    @calculated_extensionless_output_filename = @adjusted_artist + (@distinguisher != "" ? @distinguisher + '_' : "") + @adjusted_opus + @adjusted_comment + @date_with_month_in_text

    @quoted_distinguished_calculated_output_filename_str = (Path.new :path => @destination_folder, :extra => @calculated_extensionless_output_filename, :extension_to_add => @principal_file_extension).full_path_in_dquotes

    @dist_input_video_pth = (Path.new :path => @video_file_location, :extra => @video_file_name).full_path_in_dquotes
    @quoted_dist_input_audio_str = (Path.new :path => @audio_file_location, :extra => @audio_file_name).full_path_in_dquotes
    #@quoted_dist_input_video_str = (Path.new :path => @video_file_location, :extra => @video_file_name).full_path_in_dquotes
    @calculated_extensionless_trimmed_output_filename = @adjusted_artist + 'tr' + @distinguisher + '_' + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
    @fade_trim_calcd_extnless_oput_fname              = @adjusted_artist + 'tf' + @distinguisher + '_' + @adjusted_opus + @adjusted_comment + @date_with_month_in_text
    @quoted_distinguished_calculated_trimmed_output_filename = (Path.new :path => @destination_folder, :extra => @calculated_extensionless_trimmed_output_filename, :extension_to_add => @principal_file_extension).full_path_in_dquotes
    @unquoted_distinguished_calculated_trimmed_output_filename = (Path.new :path => @destination_folder, :extra => @calculated_extensionless_trimmed_output_filename, :extension_to_add => @principal_file_extension).full_path
    @q_fade_trim_calcd_dist_oput_fname = (Path.new :path => options['destination_folder'], :extra => @fade_trim_calcd_extnless_oput_fname, :extension_to_add => @principal_file_extension).full_path_in_dquotes
    @quoted_dist_tmp_folder = (Path.new :path => options['destination_folder'], :extra => @temp_folder).full_path_in_dquotes
    @quoted_dist_trimmed_temp_output_filename = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => @calculated_extensionless_trimmed_output_filename, :extension_to_add => @principal_file_extension).full_path_in_dquotes
    @unquoted_dist_tmp_folder = (Path.new :path => options['destination_folder'], :extra => @temp_folder).full_path

    @dist_concat_file_name = (Path.new :path => options['destination_folder'], :extra => @temp_folder, :extr2 => concat_file_name).full_path
    @concat_line = @concat_order + "file '" + @unquoted_distinguished_calculated_trimmed_output_filename + "'"
  end

#FilenameBuilder

  def get_mode
    @mode = "dunno"
    if (@quoted_dist_input_video_str == '""') && (@quoted_dist_input_audio_str != '""')
      @mode = "audio"
    elsif (@quoted_dist_input_video_str != '""') && (@quoted_dist_input_audio_str != '""')
      @mode = "merge"
    elsif (@quoted_dist_input_video_str != '""') && (@quoted_dist_input_audio_str == '""')
      @mode = "video"
    end
    @mode
  end
  def principal_file
    if self.get_mode == "audio"
      @principal_filename = "audiofile"
    elsif self.get_mode == "video" || self.get_mode == "merge"
      @principal_filename = "videofile"
    else
      @principal_filename = "prin-din"
    end
    @principal_filename
  end
#FilenameBuilder
end

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
