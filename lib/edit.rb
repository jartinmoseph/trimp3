require "date"

class Edit
  #attr_reader :predicted_filename
  #attr_reader :wildcard_filename
  #attr_reader :split_command
  #attr_reader :extensionless_filename
  #attr_reader :edit_by_ffmpeg
  attr_reader :discard_after_calculated_seconds
  attr_reader :adjusted_opus
  attr_reader :destination_folder
  attr_reader :original_file_location
  attr_reader :date_with_month_in_text_and_spaces
  attr_reader :derived_tit2
  attr_reader :calculated_filename

  def initialize (options = {})
    @handover_hash = options[:hash]
    @handover_array = options[:array]
    @tag_list = options[:tag_list].to_s || "tag list not set"
    @original_file_location = options[:original_file_location] || ""
    if options[:original_file_location] && @original_file_location[-1] == '/'
    elsif options[:original_file_location]
      @original_file_location = @original_file_location + '/'
    else
    end
    @discard_before_hours = @handover_hash['discard_before_hours'].to_f || 0
    @discard_before_minutes = @handover_hash['discard_before_minutes'].to_f || 0
    @discard_before_seconds = @handover_hash['discard_before_seconds'].to_f || 0
    @discard_after_hours = @handover_hash['discard_after_hours'].to_f || 0
    @discard_after_minutes = @handover_hash['discard_after_minutes'].to_f || 0
    @discard_after_seconds = @handover_hash['discard_after_seconds'].to_f || 0
    @distinguisher = @handover_hash['distinguisher'].to_s || ""
    @comment = @handover_hash['comment_used_as_location'].to_s || ""
    @song = @handover_hash['song'].to_s || ""
    @destination_folder = @handover_hash['destination_folder'].to_s || ""
    if @handover_hash['destination_folder'] && @destination_folder[-1] == '/'
    elsif @handover_hash['destination_folder']
      @destination_folder = @destination_folder + '/'
    else
    end
    @original_file_name = @handover_hash['file_name'] || @handover_hash[:file_name] || "original_file_name not set"
    #@extensionless_filename = @original_file_name.gsub(/\..*/, '')
    @adjusted_opus = @handover_hash['opus'].downcase.gsub(/ /,'-')
    @distinguished_original_filename = @original_file_location + @original_file_name
    @artist = @handover_hash['artist'].to_s || ""
    @composer = @handover_hash['TCOM'].to_s || ""
    @date_with_month_in_text = @original_file_name[4,2] + Date::ABBR_MONTHNAMES[@original_file_name[2,2].to_i].downcase + @original_file_name[0,2]
    @date_with_month_in_text_and_spaces = @original_file_name[4,2] + ' ' + Date::ABBR_MONTHNAMES[@original_file_name[2,2].to_i].downcase + ' 20' + @original_file_name[0,2]

    @derived_tit2 = @artist + ', ' + @composer + ', ' + @song + ' ' + @handover_hash['opus'] + ', ' + @comment + ' ' + @date_with_month_in_text_and_spaces
    @calculated_filename = 
@artist.downcase.gsub(/ /,'-').gsub(/,/,'-').gsub(/--/,'-').gsub(/'/,'-') + '_' + (@distinguisher != "" ? @distinguisher + '_' : "") + @adjusted_opus + '_' + (@comment != "" ? @comment.downcase.gsub(/ /,'-') + '_' : "") + @date_with_month_in_text + '.mp3'
    @calculated_filename = @calculated_filename.gsub(/,/,'') 
    @distinguished_calculated_filename = @destination_folder + @calculated_filename
  end

  def edit_by_ffmpeg
    @discard_before_total_seconds = (@discard_before_hours * 3600) + (@discard_before_minutes * 60) + (@discard_before_seconds)
    @discard_before_cmd = '-ss ' + @discard_before_total_seconds.to_s
    @discard_after_total_seconds = (@discard_after_hours * 3600) + (@discard_after_minutes * 60) + (@discard_after_seconds)
    @discard_after_calculated_seconds = @discard_after_total_seconds - @discard_before_total_seconds
    @discard_after_cmd = ' -t ' + @discard_after_calculated_seconds.to_s

    'ffmpeg ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @distinguished_original_filename + ' -acodec copy ' + @distinguished_calculated_filename
  end

  def tag_command
    set_tags = String.new
    @handover_hash.each do |key, value|
      if @tag_list.include? key.to_s 
        if value != ""
          set_tags = set_tags + ' --' + key.to_s + ' "' + value.to_s + '"'
        end
      end
    end
    @tag_command = 'id3v2 "' + @distinguished_calculated_filename + '"' + set_tags
  end
end
=begin
  def derive_tit2
    @year = @handover_hash['TYER']
    derived_tit2 = String.new
    derived_tit2 = @year
  end
=end
