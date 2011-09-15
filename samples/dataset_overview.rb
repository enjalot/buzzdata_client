require '../lib/buzzdata'

if ARGV.size != 1
  puts "Usage: ./dataset_overview.rb dataset"
  puts "Example: ./dataset_overview.rb eviltrout/kittens-born-by-month"
  exit(0)
end

# Download a Dataset
buzzdata = Buzzdata.new
overview = buzzdata.dataset_overview(ARGV[0])

overview.each do |k, v|
  puts "#{k}: #{v}"
end
