require './rfid_reader'
require 'yaml'

class CouchLogger

end

if __FILE__ == $0
  filename = ARGV[0] || '/dev/input/event0'

  puts "Test mode:"
  puts "Available evdevs: #{Dir['/dev/input/event*']}"

  r = RfidReader.new
  r.logger.level = Logger::DEBUG if ENV['DEBUG']
  r.open

  trap("SIGINT") { puts "Closing..." ; r.close ; exit }

  r.on(:all) do |filename, tag_id|
    puts "#{filename}: #{tag_id}"
  end

  while(true) do
    sleep 1
  end
end

# class CouchLogger
# end
# 
# # CouchLogger.setup
# setup mode:
# * displays existing couchdb db url, if any, and prompts to change
# * registers on all
# * prompts user to tag a reader
# * prompts user to associate reader with a device profile, or create a new device profile
# * prompt user to add another reader or continue into interactive mode
# 
# # CouchLogger.relay
# main mode:
# * relays scan events to couchdb url
# * shows streaming logs for each reader, one read at a time
