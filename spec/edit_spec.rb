require 'rspec'
require './lib/edit.rb'
require '../hash_mod/lib/hash_mod.rb'

describe 'Edit' do
  context 'Original' do
    before :each do
      @edit1 = Edit.new :file_name => '180908_0670.MP3', :split_point => '02:18:00'
    end
    subject {@edit1}
    it {should respond_to :split_command}
    it 'produces a command to split the file at the split point' do
      @edit1.split_command.should == 'mp3split 180908_0670.MP3 02:18:00'
    end
  end
end

