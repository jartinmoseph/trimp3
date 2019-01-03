require "csv"

puts "SYNTAX: ruby trimp3.rb something.conf something.csv"
CsvFile = ARGV[1]
CSV.foreach CsvFile do |row|
  puts row.inspect
  puts row.class
  EditHash = Hash.new
end
#I need to create an option hash, using the first line of this array as the key
