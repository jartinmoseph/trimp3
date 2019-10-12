#THIS IS tags4thisfile_spec.rb
require 'rspec'
require './lib/tags4thisfile.rb'

describe 'TagsForThisFile' do
  context 'given a file, return its tags in an array' do
    before :each do
      @folder = '/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/bwv775'
      @file = 'bwv775_martin-pickersgill_1-14ttb-26mar17.mp3' 
      options = {:file => @file, :folder => @folder}
      @tags = TagsForThisFile.new options
    end
    subject {@tags}
    it 'returns an array containing the file tags' do
      expect(@tags.this_file_tag_array).to eq([nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "14TTB", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, "Home", nil, "J S Bach", "(32)", nil, nil, nil, nil, nil, nil, nil, nil, "Martin Pickersgill, J S Bach, 2 pt Invention D Min BWV775,  14TTB, March 2017", nil, nil, nil, nil, nil, nil, "170326_0141.MP3", nil, nil, nil, nil, "Martin Pickersgill", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil])
    end
    it 'can return the folder and file' do
      expect(@tags.folder).to eq("/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/bwv775")
      expect(@tags.file).to eq("bwv775_martin-pickersgill_1-14ttb-26mar17.mp3")
    end
  end
  context 'folder ends without forward slash' do
    before :each do
      @folder = '/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/bwv775'
      @file = 'bwv775_martin-pickersgill_1-14ttb-26mar17.mp3' 
      options = {:file => @file, :folder => @folder}
      @t2gs = TagsForThisFile.new options
    end
    subject {@t2gs}
    it 'can return the folder and file' do
      expect(@t2gs.mp3_full_path).to eq("/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/bwv775/bwv775_martin-pickersgill_1-14ttb-26mar17.mp3")
      expect(@t2gs.folder).to eq("/Users/martinpick/Dropbox/sqbx/1car/LS_14_MP/bwv775")
      expect(@t2gs.file).to eq("bwv775_martin-pickersgill_1-14ttb-26mar17.mp3")
    end
  end
end

##########################
=begin	
require 'rspec'
require './lib/edit.rb'
#require '../rspec_book_etc/hash_mod/lib/hash_mod.rb'

describe 'Edit' do
  context 'split by ffmpeg, and use distinguisher, and also use the comment field as a location' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'distinguisher' => "3", 'file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "0", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0", 'discard_after' => "0", 'artist' => "Tara O'Rourke, Sue Clark, David Winder", 'album' => "Alberti", 'song' => "BWV847", 'comment' => "14TTB", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Sue Clark, David Winder, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["distinguisher", "file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "song", "genre", "TYER", "TIT2"],["3", "180919_0688.MP3", "0", "0", "0", "0", "0", "0", "0", "0", "Sue Clark, David Winder", "Alberti", "BWV847", "14TTB", "32", "2018", "Tara O'Rourke, Sue Clark, David Winder, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit3_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit3_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit3_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg  -i 180919_0688.MP3 -acodec copy bwv847_tara-o-rourke-sue-clark-david-winder_3-14ttb-19sep18.mp3')
    end
  end
  context 'split by ffmpeg with neither discard_before nor discard_after values' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "0", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0", 'discard_after' => "0", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "song", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "0", "0", "0", "0", "0", "0", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit3_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit3_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit3_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg  -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end
  context 'split by ffmpeg with no discard_after values' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "53", 'discard_after_hours' => "0", 'discard_after_minutes' => "0", 'discard_after_seconds' => "0", 'discard_before' => "0.53", 'discard_after' => "0", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "song", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "53", "0.53", "0", "0", "0", "0", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit2_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit2_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit2_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 53.0 -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end
  context 'split by ffmpeg with no discard_before values' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'file_name' => "180919_0688.MP3", 'discard_before_hours' => "", 'discard_before_minutes' => "", 'discard_before_seconds' => "", 'discard_after_hours' => "0", 'discard_after_minutes' => "2", 'discard_after_seconds' => "0", 'discard_before' => "", 'discard_after' => "2", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["file_name", "discard_before_hours", "discard_before_mins", "discard_before_seconds", "discard_before", "discard_after_hours", "discard_after_mins", "discard_after_seconds", "discard_after", "artist", "album", "song", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "0", "0.0", "0", "2", "0", "2", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit_ffmpeg}
    it 'can return an ffmpeg command without -ss if all discard_before values are zero' do
      expect(@edit_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg  -t 120.0 -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end

  context 'split by ffmpeg' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "53", 'discard_after_hours' => "0", 'discard_after_minutes' => "2", 'discard_after_seconds' => "0", 'discard_before' => "0.53", 'discard_after' => "2", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["file_name", 
"discard_before_hours", 
"discard_before_mins", 
"discard_before_seconds", 
"discard_before",
"discard_after_hours", 
"discard_after_mins", 
"discard_after_seconds", 
"discard_after", 
"artist", "album", "song", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "53", "0.53", "0", "2", "0", "2", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit1_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit1_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file' do
      expect(@edit1_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 53.0 -t 67.0 -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end
  context 'split by ffmpeg' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'file_name' => "180919_0688.MP3", 'discard_before_hours' => "0", 'discard_before_minutes' => "0", 'discard_before_seconds' => "52", 'discard_after_hours' => "0", 'discard_after_minutes' => "5", 'discard_after_seconds' => "0", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["file_name", 
"discard_before_hours", 
"discard_before_mins", 
"discard_before_seconds", 
"discard_before",
"discard_after_hours", 
"discard_after_mins", 
"discard_after_seconds", 
"discard_after", 
"artist", "album", "song", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0", "0", "52", "0.53", "0", "5", "0", "1", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit1_ffmpeg = Edit.new options_ffmpeg
    end
    subject {@edit1_ffmpeg}
    it {should respond_to :edit_by_ffmpeg}
    it 'can return an ffmpeg command to split the file using hours minutes seconds' do
      expect(@edit1_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 52.0 -t 248.0 -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
    it 'can return an ffmpeg command to split the file using hours minutes seconds, subtracting the time taken off the beginning to allow the original elapsed time to be put in the spreadsheet, for both beginning and end points' do
      expect(@edit1_ffmpeg.edit_by_ffmpeg).to eq('ffmpeg -ss 52.0 -t 248.0 -i 180919_0688.MP3 -acodec copy bwv847_martin-pickersgill_19sep18.mp3')
    end
  end
end
=end

=begin
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
