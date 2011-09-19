require '../lib/buzzdata'

if ARGV.size != 1
  puts "Usage: ./dataset_overview.rb dataset"
  puts "Example: ./dataset_overview.rb eviltrout/kittens-born-by-month"
  exit(0)
end

# Retrieve a Dataset's Details
buzzdata = Buzzdata.new
overview = buzzdata.dataset_overview(ARGV[0])

puts "Dataset Details:"
overview.each do |k, v|
  puts "#{k}: #{v}"
end
puts

puts "Version History:"
buzzdata.dataset_history(ARGV[0]).each do |h|
  puts "=> #{h['version']} - Uploaded On: #{h['created_at']} by #{h['username']}"
end