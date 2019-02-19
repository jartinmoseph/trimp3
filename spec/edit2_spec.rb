require 'rspec'
require './lib/edit.rb'
#require '../rspec_book_etc/hash_mod/lib/hash_mod.rb'

describe 'Edit' do
  context 'split by ffmpeg' do
    before :each do
      @tag_list = "genre,year,artist" 
      @hash_version_of_data = {'file_name' => "180919_0688.MP3", 'discard_before' => "0.53", 'discard_after' => "2", 'artist' => "Martin Pickersgill", 'album' => "Alberti", 'song' => "BWV847", 'genre' => "32", 'TYER' => "2018", 'TIT2' => "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"}
      @array_version_of_data = [["file_name", "discard_before", "discard_after", "artist", "album", "song", "genre", "TYER", "TIT2"],["180919_0688.MP3", "0.53", "2", "Martin Pickersgill", "Alberti", "BWV847", "32", "2018", "Martin Pickersgill, J S Bach, Prelude in C Minor, Bk 1, Alberti, 19 Sept 2018"]]
      options_ffmpeg = {:tag_list => @tag_list, :hash => @hash_version_of_data, :array => @array_version_of_data}
      @edit_ffmpeg = Edit.new options_predict
      #mp3splt 180919_0688.MP3 0.53 2.00
=begin
describe 'Calculator' do
  describe '#calculate' do
    it "returns a single-digit number" do
      result = Calculator.calculate
      expect(result).to be >= 0
      expect(result).to be <= 9
    end
  end
end
=end
    end
    subject {@edit_ffmpeg}
    it {should respond_to :extensionless_filename}
    it 'can give the filename without an extension' do
      expect(@edit_predict.extensionless_filename).to eq('180919_0688')
    end
    it 'predicts the filename resulting from the split' do
      expect(@edit_predict.predicted_filename).to eq('180919_0688_00m_53s__02m_00s.mp3')
    end
  end
end