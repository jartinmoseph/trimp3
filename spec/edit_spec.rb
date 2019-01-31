require 'rspec'
require './lib/edit.rb'
require '../rspec_book_etc/hash_mod/lib/hash_mod.rb'

describe 'Edit' do
  context 'generate predicted_filename'
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'file_name' => "180919_0688.MP3" 'discard_before'=> "0.53", 'discard_after' => "2", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"
      @array_version_of_data = [["file_name", "discard_before", "discard_after", "artist", "album", "song", "genre", "TYER", "TIT2"]
      @array_version_of_data = {'file_name' => "180919_0688.MP3" 'discard_before'=> "0.53", 'discard_after' => "2", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"
      #mp3splt 180919_0688.MP3 0.53 2.00

    end


  context 'Basic Edit' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'track' => "3", 'discard_before' => "27.5", 'discard_after' => "28.21", 'file_name' => "schmn39-48_luxford-evans_1901-12nov18.mp3", 'artist' => "C Luxford D Evans", 'album' => "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", 'song' => "Die Rose", 'genre' => "32", 'year' => "2018"}
      @array_version_of_data = [["track", "discard_before", "discard_after", "file_name", "artist", "album", "song", "genre", "year"], ["3", "27.5", "28.21", "schmn39-48_luxford-evans_1901-12nov18.mp3", "C Luxford D Evans", "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", "Die Rose", "32", "2018"]]
      options_hash = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      #options_hash = {:tag_list => "genre,year,artist", :hash => {:track => "3", :discard_before => "27.5", :discard_after => "28.21", :file_name => "schmn39-48_luxford-evans_1901-12nov18.mp3", :artist => "C Luxford D Evans", :album => "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", :song => "Die Rose", :genre => "32", :year => "2018"}, :array=>[["track", "discard_before", "discard_after", "file_name", "artist", "album", "song", "genre", "year"], ["3", "27.5", "28.21", "schmn39-48_luxford-evans_1901-12nov18.mp3", "C Luxford D Evans", "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", "Die Rose", "32", "2018"]]}
      #puts "in edit_spec.rb, options_hash is: " + options_hash.inspect
      #options_hash = {:hash_version => { :track =>"3", :discard_before => "27.5"}}
      #@edit1 = Edit.new :file_name => '180908_0688.MP3', :discard_before => '02.18', :discard_after => '03.00'
      #@edit1 = Edit.new [['file_name', 'discard_before', 'discard_after'],['180908_0688.MP3', '02.18', '03.00']]
      @edit1 = Edit.new options_hash
    end
    subject {@edit1}
    it {should respond_to :split_command}
    it {should respond_to :predicted_filename}
    it 'predicts the filename resulting from the split' do
      expect(@edit1.predicted_filename).to eq('180919_0688_27m_50s__28m_21s')
    end
    it 'produces a command to split the file at the split point' do
      expect(@edit1.split_command).to eq('mp3splt schmn39-48_luxford-evans_1901-12nov18.mp3 27.50 28.21')
    end
    xit 'produces a command to add tags to the file' do
      expect(@edit1.tag_command).to eq('id3v2 schmn39-48_luxford-evans_1901-12nov18.mp3 --artist "C Luxford D Evans" --genre "32" --year "2018"')
    end
  end
  xcontext 'no split parameters' do
    before :each do    
      options2_hash = {:tag_list => "genre,year,artist", :hash => {:track => "3", :discard_before => "", :discard_after => "", :file_name => "schmn39-48_luxford-evans_1901-12nov18.mp3", :artist => "C Luxford D Evans", :album => "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", :song => "Die Rose", :genre => "32", :year => "2018"}, :array=>[["track", "discard_before", "discard_after", "file_name", "artist", "album", "song", "genre", "year"], ["3", "27.5", "28.21", "schmn39-48_luxford-evans_1901-12nov18.mp3", "C Luxford D Evans", "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", "Die Rose", "32", "2018"]]}
      @edit_no_split =Edit.new options2_hash
      end  
      subject {@edit_no_split}
      it 'does not respond produce a split command unless discard_before and discard_after are present' do
        expect(@edit_no_split.split_command).to eq('')
      end
    end
  end
