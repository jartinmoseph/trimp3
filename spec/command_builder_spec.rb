require 'rspec'
require './lib/command_builder.rb'
require '../rspec_book_etc/hash_mod/lib/hash_mod.rb'

describe 'CommandBuilder' do
  xcontext '--Only listed columns are selected--' do
    before :each do
      @command3 = CommandBuilder.new :command => 'id3v2', :csv_array => [["track", "discard_before", "discard_after", "file_name", "artist", "album", "song", "stars", "genre", "year"], ["3", "27.5", "28.21", "schmn39-48_luxford-evans_1901-12nov18", "C Luxford, D Evans", "C Luxford, D Evans, Schumann Liede, 1901 Arts, Nov 2018", "Die Rose", "1", "Classical", "2018"]], :columns => ["artist","album","song","year"]
    end
    subject {@command3}
    it {should respond_to :convert_csv_to_hash}
    it 'should return a hash containing stuff' do
      expect(@command3.convert_csv_to_hash['year']).to eq '2018'
    end
    it 'should return a hash' do
      temp_class = @command3.class
      expect(@command3.class).to eq temp_class
    end
    it 'has a command' do
      expect(@command3.command).to eq "id3v2"
    end
  end
  xcontext '--Only listed columns are selected--' do
    before :each do
      @command2 = CommandBuilder.new :command => 'id3v2', :csv_array => [["track", "discard_before", "discard_after", "file_name", "artist", "album", "song", "stars", "genre", "year"], ["3", "27.5", "28.21", "schmn39-48_luxford-evans_1901-12nov18", "C Luxford, D Evans", "C Luxford, D Evans, Schumann Liede, 1901 Arts, Nov 2018", "Die Rose", "1", "Classical", "2018"]], :columns => ["artist","album","song","year"]
    end
    subject {@command2}
    it 'returns the song title' do
      expect(@command2.convert_csv_to_hash['song']).to eq "Die Rose"
    end
    it 'returns the artist' do
      expect(@command2.convert_csv_to_hash['artist']).to eq "C Luxford, D Evans"
    end
    it 'does not return the year' do
      expect(@command2.convert_csv_to_hash['year']).to eq "2018"
    end
  end

  xcontext 'Basic' do
    before :each do
      @command1 = CommandBuilder.new :command => 'id3v2', :csv_array => [["track", "discard_before", "discard_after", "file_name", "artist", "album", "song", "stars", "genre", "year"], ["3", "27.5", "28.21", "schmn39-48_luxford-evans_1901-12nov18", "C Luxford, D Evans", "C Luxford, D Evans, Schumann Liede, 1901 Arts, Nov 2018", "Die Rose", "1", "Classical", "2018"]], :columns => ["artist","album","song","comment","genre","year","track"]
    end
    subject {@command1}
    it {should respond_to :command}
    it 'returns the command' do
      expect(@command1.command).to eq('id3v2')
    end
    it 'returns a song title' do
      expect(@command1.convert_csv_to_hash['song']).to eq "Die Rose"
    end
    it 'returns a track number' do
      expect(@command1.convert_csv_to_hash['track']).to eq "3"
    end
    xit 'returns a hash' do
      expect(@command1.convert_csv_to_hash.class).to eq "Hash"
    end
  end
end
