require "date"
require "fileutils"

class Edit
  attr_reader :discard_after_calculated_seconds
  attr_reader :adjusted_opus
  attr_reader :destination_folder
  attr_reader :dest_folder_path
  attr_reader :date_with_month_in_text_and_spaces
  attr_reader :derived_tit2
  attr_reader :principal_file_location
  attr_reader :principal_file_name
  attr_reader :principal_file_extension
  attr_reader :audio_file_name
  attr_reader :audio_file_location
  attr_reader :distinguished_principal_filename 
  attr_reader :quoted_distinguished_principal_filename 
  attr_reader :calculated_extensionless_output_filename
  attr_reader :quoted_distinguished_calculated_output_filename_str 
  attr_reader :distinguished_calculated_extensionless_output_filename_path

  def initialize (options = {})
    @handover_array = options[:array]
    @a2h_handover_hash = Hash.new
    @a2h_handover_hash.update :array_version => @handover_array
    @converter = AHHA.new @a2h_handover_hash
    @handover_hash = @converter.hash_version

    @tag_list = options[:tag_list].to_s || "tag list not set"
    @discard_before_hours = @handover_hash['discard_before_hours'].to_f || 0
    @discard_before_minutes = @handover_hash['discard_before_minutes'].to_f || 0
    @discard_before_seconds = @handover_hash['discard_before_seconds'].to_f || 0
    @discard_after_hours = @handover_hash['discard_after_hours'].to_f || 0
    @discard_after_minutes = @handover_hash['discard_after_minutes'].to_f || 0
    @discard_after_seconds = @handover_hash['discard_after_seconds'].to_f || 0
    @distinguisher = @handover_hash['distinguisher'].to_s || ""
    @comment = @handover_hash['comment_used_as_location'].to_s || ""
    @song = @handover_hash['song'].to_s || ""
    @video_file_name = @handover_hash['video_file_name'].to_s || ""
    @video_file_location = @handover_hash['video_file_location'].to_s || ""
    @audio_file_name = @handover_hash['audio_file_name'].to_s || ""
    @audio_file_location = @handover_hash['audio_file_location'].to_s || ""
    @destination_folder = @handover_hash['destination_folder'].to_s || ""
    @dest_folder_path = Path.new :path => @destination_folder
    @adjusted_opus = @handover_hash['opus'].downcase.gsub(/ /,'-')
    @artist = @handover_hash['artist'].to_s || ""
    @composer = @handover_hash['TCOM'].to_s || ""
    @distinguished_input_video_file_path = Path.new :path => @video_file_location, :extra => @video_file_name
    if @distinguished_input_video_file_path.path == ""
      @principal_file_name = @audio_file_name
      @principal_file_location = @audio_file_location
    else  
      @principal_file_name = @video_file_name
      @principal_file_location = @video_file_location
    end
    @principal_file_extension = (File.extname @principal_file_name).downcase
    @distinguished_principal_filename = Path.new(:path => @principal_file_location, :extra => @principal_file_name).extended
    @distinguished_principal_filename_path = Path.new :path => @distinguished_principal_filename 
    @quoted_distinguished_principal_filename = @distinguished_principal_filename_path.dquoty 
    if (@audio_file_name[0,2].to_i > 0) && (@audio_file_name[2,2].to_i > 0) && (@audio_file_name[4,2].to_i > 0)
      @date_with_month_in_text = @audio_file_name[4,2] + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].downcase + @audio_file_name[0,2]
      @date_with_month_in_text_and_spaces = @audio_file_name[4,2] + ' ' + Date::ABBR_MONTHNAMES[@audio_file_name[2,2].to_i].capitalize + ' 20' + @audio_file_name[0,2]
    else
      @date_with_month_in_text = ""
      @date_with_month_in_text_and_spaces = ""
    end
    @derived_tit2 = @artist + ', ' + @composer + ', ' + @song + ' ' + @handover_hash['opus'] + ', ' + @comment + ' ' + @date_with_month_in_text_and_spaces
    @calculated_extensionless_output_filename = @artist.downcase.gsub(/ /,'-').gsub(/,/,'-').gsub(/--/,'-').gsub(/'/,'-') + '_' + (@distinguisher != "" ? @distinguisher + '_' : "") + @adjusted_opus + '_' + (@comment != "" ? @comment.downcase.gsub(/ /,'-') + '_' : "") + @date_with_month_in_text
    @calculated_extensionless_output_filename = @calculated_extensionless_output_filename.gsub(/,/,'') 
    @distinguished_calculated_extensionless_output_filename_path = Path.new :path => @dest_folder_path.path, :extra => @calculated_extensionless_output_filename
    @distinguished_calculated_output_filename = (Path.new :path => @distinguished_calculated_extensionless_output_filename_path.extended, :extra => @principal_file_extension).with_extension
    @quoted_distinguished_calculated_output_filename_str = (Path.new :path => @distinguished_calculated_output_filename).dquoty
  end

  def edit_by_ffmpeg
    @discard_before_total_seconds = (@discard_before_hours * 3600) + (@discard_before_minutes * 60) + (@discard_before_seconds)
    @discard_before_cmd = '-ss ' + @discard_before_total_seconds.to_s
    @discard_after_total_seconds = (@discard_after_hours * 3600) + (@discard_after_minutes * 60) + (@discard_after_seconds)
    @discard_after_calculated_seconds = @discard_after_total_seconds - @discard_before_total_seconds
    @discard_after_cmd = ' -t ' + @discard_after_calculated_seconds.to_s

    'ffmpeg ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @quoted_distinguished_principal_filename + ' -acodec copy ' + @quoted_distinguished_calculated_output_filename_str 
  end

  def av_simple_merge
    'ffmpeg -i ' + @audio_file_name + ' -i ' + @video_file_name + ' ' + @quoted_distinguished_calculated_output_filename_str
  end
  def av_delayed_merge
    'ffmpeg -i ' + @audio_file_name + ' -itsoffset ' + @handover_hash['audio_delay'] + ' -i ' + @video_file_name + ' -map 0:a -map 1:v -c copy ' + @quoted_distinguished_calculated_output_filename_str
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
    @tag_command = 'id3v2 "' + @distinguished_calculated_output_filename + '"' + set_tags
  end
end

class Path < String
  attr_reader :path
  def initialize (options = {})
    @path = options[:path]
    @extra = options[:extra]
    @path.chars[-1] == '/' ?  @path = @path.chop : @path
  end
  def dquoty
    '"' + @path + '"'
  end
  def extended
    @path + '/' + @extra
  end
  def extension
    (File.extname @path).downcase
  end
  def with_extension
    @path + @extra
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
end

