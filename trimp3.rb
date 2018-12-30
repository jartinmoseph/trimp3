require "csv"

CsvFile = ARGV[0]
CSV.foreach CsvFile do |row|
  puts row.inspect
  puts row.class
end

