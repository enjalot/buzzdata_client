require '../lib/buzzdata'

if ARGV.size != 1
  puts "Usage: ./download_data.rb dataset"
  puts "Example: ./download_data.rb eviltrout/kittens-born-by-month"
  exit(0)
end

# Download a Dataset
buzzdata = Buzzdata.new
puts buzzdata.download_data(ARGV[0])
