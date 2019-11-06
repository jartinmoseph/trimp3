#require "../rspec_book_etc/hash_mod/lib/hash_mod"§§
require "date"

class Edit
  attr_reader :split_command
  attr_reader :predicted_filename
  attr_reader :wildcard_filename
  attr_reader :extensionless_filename
  attr_reader :edit_by_ffmpeg
  attr_reader :discard_after_calculated_seconds

  def initialize (options = {})
    @handover_hash = options[:hash]
    @handover_array = options[:array]
    @tag_list = options[:tag_list].to_s || "tag list not set"
    @discard_before_hours = @handover_hash['discard_before_hours'].to_f || 0
    @discard_before_minutes = @handover_hash['discard_before_minutes'].to_f || 0
    @discard_before_seconds = @handover_hash['discard_before_seconds'].to_f || 0
    @discard_after_hours = @handover_hash['discard_after_hours'].to_f || 0
    @discard_after_minutes = @handover_hash['discard_after_minutes'].to_f || 0
    @discard_after_seconds = @handover_hash['discard_after_seconds'].to_f || 0
    @distinguisher = @handover_hash['distinguisher'].to_s || ""
    @comment = @handover_hash['comment'].to_s || ""
    @file_name = @handover_hash['file_name'] || @handover_hash[:file_name] || "name_of_file not set"
    @extensionless_filename = @file_name.gsub(/\..*/, '')
    @output_filename = @handover_hash['song'].downcase.gsub(/ /,'-')
    @artist = @handover_hash['artist']
=begin
    #@discard_before = @handover_hash['discard_before'].to_f || "discard_before not set"
    #@discard_after  = @handover_hash['discard_after'].to_f || "discard_after not set"
    #@discard_before_mins = sprintf("%02d", @discard_before) + 'm_' + sprintf("%02d", (@discard_before % 1) * 100) + 's__' || "discard_before not set"
    #@discard_after_mins = sprintf("%02d", @discard_after) + 'm_' + sprintf("%02d", (@discard_after % 1) * 100) + 's'
    if @discard_after > 0
      #@split_command = 'mp3splt ' + @file_name + ' ' + sprintf("%.02f", @discard_before) + ' ' + sprintf("%.02f", @discard_after) 
    else
      #@split_command = 'mp3splt ' + @file_name + ' ' + sprintf("%.02f", @discard_before) + ' EOF'
    end

    #@predicted_filename = @extensionless_filename + '_' + @discard_before_mins + @discard_after_mins + '.mp3'
    #@wildcard_filename = @extensionless_filename + '_' + @discard_before_mins + '*.mp3'
=end
  end

  def edit_by_ffmpeg
    @discard_before_total_seconds = (@discard_before_hours * 3600) + (@discard_before_minutes * 60) + (@discard_before_seconds)
    @discard_before_cmd = '-ss ' + @discard_before_total_seconds.to_s
    @discard_after_total_seconds = (@discard_after_hours * 3600) + (@discard_after_minutes * 60) + (@discard_after_seconds)
    @discard_after_calculated_seconds = @discard_after_total_seconds - @discard_before_total_seconds
    @discard_after_cmd = ' -t ' + @discard_after_calculated_seconds.to_s
    @date_with_month_in_text = @file_name[4,2] + Date::ABBR_MONTHNAMES[@file_name[2,2].to_i].downcase + @file_name[0,2]

    @calculated_filename = @output_filename + '_' + @artist.downcase.gsub(/ /,'-').gsub(/,/,'-').gsub(/--/,'-').gsub(/'/,'-') + '_' + (@distinguisher != "" ? @distinguisher + '-' : "") + (@comment != "" ? @comment.downcase.gsub(/ /,'-') + '-' : "") + @date_with_month_in_text + '.mp3'
    @calculated_filename = @calculated_filename.gsub(/,/,'') 
    'ffmpeg ' + (@discard_before_total_seconds == 0 ? "" :  @discard_before_cmd) + (@discard_after_total_seconds <= 0 ? "" :  @discard_after_cmd) + ' -i ' + @file_name + ' -acodec copy ' + @calculated_filename
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
    @tag_command = 'id3v2 "' + @calculated_filename + '"' + set_tags
  end
end

