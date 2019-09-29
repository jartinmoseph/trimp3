require "csv"
require "mp3info"
require "rspec"
#require "lib/tags4thisfile"

puts "SYNTAX: tag1csv path_to_folder"
puts "OUTPUT: tag_list.csv in the above folder"
Id3v2TagArray = %w( filename  artist  album  song  comment  genre  year  track  AENC  APIC  COMM  COMR  ENCR  EQUA  ETCO  GEOB  GRID  IPLS  LINK  MCDI  MLLT  OWNE  PRIV  PCNT  POPM  POSS  RBUF  RVAD  RVRB  SYLT  SYTC  TALB  TBPM  TCOM  TCON  TCOP  TDAT  TDLY  TENC  TEXT  TFLT  TIME  TIT1  TIT2  TIT3  TKEY  TLAN  TLEN  TMED  TOAL  TOFN  TOLY  TOPE  TORY  TOWN  TPE1  TPE2  TPE3  TPE4  TPOS  TPUB  TRCK  TRDA  TRSN  TRSO  TSIZ  TSRC  TSSE  TXXX  TYER  UFID  USER  USLT  WCOM  WCOP  WOAF  WOAR  WOAS  WORS  WPAY  WPUB  WXXX) 
Id3v2TagHash = Hash.new
count = 0
Id3v2TagArray.each do |each_tag|
  Id3v2TagHash.store(each_tag, count)
  count += 1
end
Id3v2TagArray.freeze

@this_file_tag_array = Array.new
ThisFolderTagArray = Array.new
ThisFolderTagArray.push Id3v2TagArray
ThisFolderTagArray.push "\n"
FolderContainingMp3s = ARGV[0]
OutputFile = FolderContainingMp3s + 'tag_list.csv'
ListofFiles = Dir.entries(FolderContainingMp3s)
ListofFiles.each do |item|
  the_mp3 = item.downcase
  if the_mp3[-3..-1] == 'mp3'
    @this_file_tag_array[0] = the_mp3
    ThisFolderTagArray.push @this_file_tag_array
    the_mp3_info = Mp3Info.open FolderContainingMp3s + item 
    Id3v2TagArray.each do |the_tag|
      if the_mp3_info.tag2.send the_tag
        tag_count = Id3v2TagHash.fetch the_tag
        @this_file_tag_array[tag_count] = the_mp3_info.tag2.send the_tag
      end
    end
        p @this_file_tag_array
    the_mp3_info.close
  end
end

CSV.open(OutputFile, "w") do |entry|
  entry.puts ThisFolderTagArray
end
