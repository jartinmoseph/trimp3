require 'rspec'
require './lib/edit.rb'
require '../rspec_book_etc/hash_mod/lib/hash_mod.rb'

describe 'Edit' do
  context 'Basic Edit' do
    before :each do
      options_hash = {:tag_list => "genre,year,artist", :hash => {:track => "3", :discard_before => "27.5", :discard_after => "28.21", :file_name => "schmn39-48_luxford-evans_1901-12nov18.mp3", :artist => "C Luxford D Evans", :album => "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", :song => "Die Rose", :genre => "32", :year => "2018"}, :array=>[["track", "discard_before", "discard_after", "file_name", "artist", "album", "song", "genre", "year"], ["3", "27.5", "28.21", "schmn39-48_luxford-evans_1901-12nov18.mp3", "C Luxford D Evans", "C Luxford D Evans Schumann Liede 1901 Arts Nov 2018", "Die Rose", "32", "2018"]]}
      #puts "in edit_spec.rb, options_hash is: " + options_hash.inspect
      #options_hash = {:hash_version => { :track =>"3", :discard_before => "27.5"}}
      #@edit1 = Edit.new :file_name => '180908_0688.MP3', :discard_before => '02.18', :discard_after => '03.00'
      #@edit1 = Edit.new [['file_name', 'discard_before', 'discard_after'],['180908_0688.MP3', '02.18', '03.00']]
      @edit1 = Edit.new options_hash
    end
    subject {@edit1}
    it {should respond_to :split_command}
    it {should respond_to :genre}
    it 'produces a command to split the file at the split point' do
      expect(@edit1.split_command).to eq('mp3splt schmn39-48_luxford-evans_1901-12nov18.mp3 27.50 28.21')
    end
    it 'returns a genre' do
      expect(@edit1.genre).to eq('32')
    end
    it 'produces a command to add a genre tag to the file' do
      expect(@edit1.tag_command).to eq('id3v2 schmn39-48_luxford-evans_1901-12nov18.mp3 --artist "C Luxford D Evans" --genre "32" --year "2018"')
    end
  end
end
