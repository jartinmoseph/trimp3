# trimp3
Trim and tag recordings
Arrays are easier to deal with than hashes for this
Go through the file, and for each line construct a hash with the column name as key pointing to the entry for that line.
Hand that hash to two command builder objects, one id3v2 and one mp3splt. Also hand the list of column names.
Each one returns the built command to trimp3.rb which creates two files, one to split and one to tag.
Splitting causes the filename to change, so it will be a two step process
