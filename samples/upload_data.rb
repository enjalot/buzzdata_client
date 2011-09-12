#!/usr/bin/env ruby

require '../lib/buzzdata'

if ARGV.size != 2
  puts "Usage: ./upload_data.rb dataset filename"
  puts "Example: ./upload_data.rb eviltrout/kittens-born-by-month kittens_born.csv"
  exit(0)
end

buzzdata = Buzzdata.new

dataset_name, filename = *ARGV

# Upload a file to a dataset
print "Uploading #{filename}..."
upload = buzzdata.start_upload(dataset_name, File.new(filename))
puts "Done!"

# Wait while it's being processed
print "Waiting for processing to finish..."
while upload.in_progress?
  print "." 
  sleep(1)    # Let's not poll too frequently
end

if upload.success?
  puts "Done!"
else
  puts "ERROR! #{upload.status_message}"
end
