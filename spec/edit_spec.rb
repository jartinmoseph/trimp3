require 'rspec'
require './lib/edit.rb'
require '../rspec_book_etc/hash_mod/lib/hash_mod.rb'

describe 'Edit' do
  context 'Basic Edit' do
    before :each do
      @edit1 = Edit.new :file_name => '180908_0688.MP3', :discard_before => '02.18', :discard_after => '03.00'
    end
    subject {@edit1}
    it {should respond_to :split_command}
    it 'produces a command to split the file at the split point' do
      expect(@edit1.split_command).to eq('mp3splt 180908_0688.MP3 2.18 3.00')
    end
  end
  context 'Tagging' do
    before :each do
        @tag_edit = Edit.new :file_name => '180908_0688.MP3', :genre => 'Classical'
    end
    subject {@tag_edit}
    it 'produces a command to add a genre tag to the file' do
      expect(@tag_edit.tag_command).to eq('tag 180908_0688.MP3 --genre "Classical"')
    end
  end
end

