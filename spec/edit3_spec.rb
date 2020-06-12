require 'rspec'
require './lib/edit.rb'
describe 'Edit' do
  context 'combine audio and video files' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {
'audio_delay' => "1.2", 
'video_file_name' => "MVI_2424_no3_rach.MP4",
 'destination_folder' => "/Users/martinpick/Dropbox/videos/2020",
 'distinguisher' => "3",
 'audio_file_name' => "testsound.mp3",
 'discard_before_hours' => "0",
 'discard_before_minutes' => "0",
 'discard_before_seconds' => "0",
 'discard_after_hours' => "0",
 'discard_after_minutes' => "0",
 'discard_after_seconds' => "0",
 'discard_before' => "0",
 'discard_after' => "0",
 'artist' => "Sue Clark, David Winder",
 'album' => "Alberti",
 'song' => "Sonata in D",
 'opus' => "K381",
 'comment_used_as_location' => "Thornbridge Hall",
 'genre' => "32",
 'TYER' => "2018",
 'TIT2' => "Sue Clark, David Winder, Mozart, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018",
 'TCOM' => "Mozart"}
      @array_version_of_data = [[
"destination_folder",
 "distinguisher",
 "audio_delay",
 "video_file_name",
 "audio_file_name",
 "discard_before_hours",
 "discard_before_mins",
 "discard_before_seconds",
 "discard_before",
 "discard_after_hours",
 "discard_after_mins",
 "discard_after_seconds",
 "discard_after",
 "artist",
 "album",
 "song",
 "opus",
 "genre",
 "TYER",
 "TIT2",
 "TCOM"],
["/Users/martinpick/Dropbox/sqbx/2019/2019_alberti",
 "3",
 "1.2",
 "MVI_2424_no3_rach.MP4",
 "190917_0688.MP3",
 "0",
 "0",
 "0",
 "0",
 "0",
 "0",
 "0",
 "0",
 "Sue Clark, David Winder",
 "Alberti",
 "Sonata in D",
 "K381",
 "Thornbridge Hall",
 "32",
 "2018",
 "Sue Clark, David Winder, Mozart, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018",
 "Mozart"]]
      options_ffmpeg = {:original_file_location => "/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/", :tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit5_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit5_ffmpeg}
    it 'produces a file which merges audio and video from separate files' do
      expect(@edit5_ffmpeg.av_simple_merge).to eq('ffmpeg -i testsound.mp3 -i MVI_2424_no3_rach.MP4 -c copy MVI_2424_no3_rach_dubbed.mp4')
    end 
    subject {@edit5_ffmpeg}
    xit 'produces a file with video from mp4 and audio from mp3 with delayed audio' do
      expect(@edit5_ffmpeg.av_delayed_merge).to eq('ffmpeg -i testsound.mp3 -itsoffset 1.2 -i MVI_2424_no3_rach.MP4 -map 0:a -map 1:v -c copy delayed12.mp4')
    end 
  end
end
=begin
  context 'make the TIT2 field from other data. Also, make the output filename artist_opus_location_date' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'destination_folder' => "/Users/martinpick/Dropbox/sqbx/2019/2019_alberti", 'distinguisher' => "3", 'audio_file_name' => "190917_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "0", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0", 'discard_after' => "0", 'artist' => "Sue Clark, David Winder", 'album' => "Alberti", 'song' => "Sonata in D", 'opus' => "K381", 'comment_used_as_location' => "Thornbridge Hall", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Sue Clark, David Winder, Mozart, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018", 'TCOM' => "Mozart"}
      @array_version_of_data = [["destination_folder", "distinguisher", "audio_file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "song", "opus", "genre", "TYER", "TIT2", "TCOM"],["/Users/martinpick/Dropbox/sqbx/2019/2019_alberti", "3", "190917_0688.MP3", "0", "0", "0", "0", "0", "0", "0", "0", "Sue Clark, David Winder", "Alberti", "Sonata in D", "K381", "Thornbridge Hall", "32", "2018", "Sue Clark, David Winder, Mozart, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018", "Mozart"]]
      options_ffmpeg = {:original_file_location => "/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/", :tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit5_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit5_ffmpeg}
    it 'produces an output filename of format artist_opus_location_date' do
      expect(@edit5_ffmpeg.calculated_filename).to eq('sue-clark-david-winder_3_k381_thornbridge-hall_17sep19.mp3')
    end 
    it 'uses the TIT2 tag from the spreadsheet if there is one' do
      expect(@edit5_ffmpeg.tag_command).to eq('id3v2 "/Users/martinpick/Dropbox/sqbx/2019/2019_alberti/sue-clark-david-winder_3_k381_thornbridge-hall_17sep19.mp3" --artist "Sue Clark, David Winder" --genre "32"')
    end
    it 'derives a TIT2 tag' do
      expect(@edit5_ffmpeg.derived_tit2).to eq('Sue Clark, David Winder, Mozart, Sonata in D K381, Thornbridge Hall 17 Sep 2019')
    end
    it 'derives the date from the original filename' do
      expect(@edit5_ffmpeg.date_with_month_in_text_and_spaces).to eq('17 Sep 2019') 
    end
  end

  context 'use absolute paths for original and resulting file, and quote the original path' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'destination_folder' => "/Users/martinpick/Dropbox/sqbx/2019/2019_alberti", 'distinguisher' => "3", 'audio_file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "0", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0", 'discard_after' => "0", 'artist' => "Tara O'Rourke, Sue Clark, David Winder", 'album' => "Alberti", 'opus' => "BWV847", 'comment_used_as_location' => "14TTB", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Sue Clark, David Winder, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["destination_folder", "distinguisher", "audio_file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "opus", "genre", "TYER", "TIT2"],["/Users/martinpick/Dropbox/sqbx/2019/2019_alberti", "3", "180919_0688.MP3", "0", "0", "0", "0", "0", "0", "0", "0", "Sue Clark, David Winder", "Alberti", "BWV847", "14TTB", "32", "2018", "Tara O'Rourke, Sue Clark, David Winder, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:original_file_location => "/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/", :tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit4_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit4_ffmpeg}
    it 'can produce an ffmpeg command with absolute paths' do
      expect(@edit4_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg  -i "/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/180919_0688.MP3" -acodec copy "/Users/martinpick/Dropbox/sqbx/2019/2019_alberti/tara-o-rourke-sue-clark-david-winder_3_bwv847_14ttb_19sep18.mp3"')
    end
    it 'has a destination folder ending in an oblique' do
      expect(@edit4_ffmpeg.destination_folder).to eq('/Users/martinpick/Dropbox/sqbx/2019/2019_alberti/')
    end
    it 'has an original file location' do
      expect(@edit4_ffmpeg.original_file_location).to eq('/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/')
    end
  end

  context 'split by ffmpeg, and use distinguisher, and also use the comment field as a location' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'distinguisher' => "3", 'audio_file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "0", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0", 'discard_after' => "0", 'artist' => "Tara O'Rourke, Sue Clark, David Winder", 'album' => "Alberti", 'opus' => "BWV847", 'comment_used_as_location' => "14TTB", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Sue Clark, David Winder, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["distinguisher", "audio_file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "opus", "genre", "TYER", "TIT2"],["3", "180919_0688.MP3", "0", "0", "0", "0", "0", "0", "0", "0", "Sue Clark, David Winder", "Alberti", "BWV847", "14TTB", "32", "2018", "Tara O'Rourke, Sue Clark, David Winder, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:original_file_location => "/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/", :tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit3_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit3_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit3_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg  -i "/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/180919_0688.MP3" -acodec copy "tara-o-rourke-sue-clark-david-winder_3_bwv847_14ttb_19sep18.mp3"')
    end
    it 'has an original file location which has an oblique at the end even if input without one' do
      expect(@edit3_ffmpeg.original_file_location).to eq('/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/')
    end
  end
  context 'split by ffmpeg with no discard_after values' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'audio_file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "53", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0.53", 'discard_after' => "0", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'opus' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["audio_file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "opus", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "53", "0.53", "0", "0", "0", "0", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit2_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit2_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit2_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 53.0 -i "180919_0688.MP3" -acodec copy "martin-pickersgill_bwv847_19sep18.mp3"')

    end
  end

  context 'split by ffmpeg' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'audio_file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "52", 'discard_after_hours' => "0", 'discard_after_minutes' => "5", 'discard_after_seconds' => "0", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'opus' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018", 'comment_used_as_location' => "Cross St Chapel"}
      @array_version_of_data = [["audio_file_name", 
"discard_before_hours", 
"discard_before_mins", 
"discard_before_seconds", 
"discard_before",
"discard_after_hours", 
"discard_after_mins", 
"discard_after_seconds", 
"discard_after", 
"artist", "album", "opus", "genre", "TYER", "TIT2", "comment_used_as_location"],["180919_0688.MP3", "0", "0", "52", "0.53", "0", "5", "0", "1", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018", "Cross St Chapel"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit1_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit1_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file using hours minutes seconds, subtracting the time taken off the beginning to allow the original elapsed time to be put in the spreadsheet, for both beginning and end points' do
      expect(@edit1_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 52.0 -t 248.0 -i "180919_0688.MP3" -acodec copy "martin-pickersgill_bwv847_cross-st-chapel_19sep18.mp3"')
    end
    it 'produces an output filename of format artist_opus_location_date' do
      expect(@edit1_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 52.0 -t 248.0 -i "180919_0688.MP3" -acodec copy "martin-pickersgill_bwv847_cross-st-chapel_19sep18.mp3"')
    end
  end
end


#rspec example with more than one expectation
describe 'Calculator' do
  describe '#calculate' do
    it "returns a single-digit number" do
      result = Calculator.calculate
      expect(result).to be >= 0
      expect(result).to be <= 9
    end
  end
end
 hh:mm:ss[.xxx] syntax is also supported in ffmpeg
=end


=begin
  xcontext 'split by ffmpeg with no discard_before values 6 Nov 19 discard_before has been removed' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'audio_file_name' => "180919_0688.MP3", 'discard_before_hours' => "", 'discard_before_minutes' => "", 'discard_before_seconds' => "", 'discard_after_hours' => "0", 'discard_after_minutes' => "2", 'discard_after_seconds' => "0", 'discard_before' => "", 'discard_after' => "2", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'opus' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["audio_file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "opus", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "0", "0.0", "0", "2", "0", "2", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit_ffmpeg}
    it 'can return an ffmpeg command without -ss if all discard_before values are zero 6 nov 19 discard_before has been removed' do
      expect(@edit_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg  -t 120.0 -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end

  xcontext 'split by ffmpeg with neither discard_before nor discard_after values 6 Nov 19 both these variables have been removed' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'audio_file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "0", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0", 'discard_after' => "0", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'opus' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["audio_file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "opus", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "0", "0", "0", "0", "0", "0", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit3_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit3_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit3_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg  -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end

  context 'split by ffmpeg' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'audio_file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "53", 'discard_after_hours' => "0", 'discard_after_minutes' => "2", 'discard_after_seconds' => "0", 'discard_before' => "0.53", 'discard_after' => "2", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'opus' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["audio_file_name", 
"discard_before_hours", 
"discard_before_mins", 
"discard_before_seconds", 
"discard_before",
"discard_after_hours", 
"discard_after_mins", 
"discard_after_seconds", 
"discard_after", 
"artist", "album", "opus", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "53", "0.53", "0", "2", "0", "2", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit1_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit1_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit1_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 53.0 -t 67.0 -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end
=end
