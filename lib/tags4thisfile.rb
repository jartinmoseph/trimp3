require 'mp3info'

class TagsForThisFile
  attr_reader :file
  attr_reader :folder
  attr_reader :mp3_full_path
  attr_reader :this_file_tag_array
  attr_reader :id3v2_tag_array

  def initialize (options = {})
    @id3v2_tag_array = %w( filename  artist  album  song  comment  genre  year  track  TALB  TCON  TOFN  TPE1  TYER  TCOM  TIT2  COMM  AENC  APIC  COMR  ENCR  EQUA  ETCO  GEOB  GRID  IPLS  LINK  MCDI  MLLT  OWNE  PRIV  PCNT  POPM  POSS  RBUF  RVAD  RVRB  SYLT  SYTC  TBPM  TCOP  TDAT  TDLY  TENC  TEXT  TFLT  TIME  TIT1  TIT3  TKEY  TLAN  TLEN  TMED  TOAL  TOLY  TOPE  TORY  TOWN  TPE2  TPE3  TPE4  TPOS  TPUB  TRCK  TRDA  TRSN  TRSO  TSIZ  TSRC  TSSE  TXXX  UFID  USER  USLT  WCOM  WCOP  WOAF  WOAR  WOAS  WORS  WPAY  WPUB  WXXX) 
  @id3v2_tag_hash = Hash.new
  tag_count = 0 
  @id3v2_tag_array.each do |each_tag|
    @id3v2_tag_hash.store(each_tag, tag_count)
    tag_count += 1
  end

  @file = options[:file] || "nofile"
  @folder = options[:folder] || "nofolder"
  @mp3_full_path = @folder + '/' + @file
    if @mp3_full_path[-3..-1].downcase == 'mp3'
      @this_file_tag_array = Array.new
      @mp3_full_path_info = Mp3Info.open @mp3_full_path
      @id3v2_tag_array.each do |tag|
        @tag = tag.gsub/\x00//g
        @number_of_this_tag = @id3v2_tag_hash.fetch @tag
        @this_tag1_contents = @mp3_full_path_info.tag1.send @tag
        @this_tag2_contents = @mp3_full_path_info.tag2.send @tag 
        @this_tag_contents  = @this_tag1_contents || @this_tag2_contents 
        @this_file_tag_array[@number_of_this_tag] = @this_tag_contents
      end
      @this_file_tag_array[0] = @file
    end
  end
end

