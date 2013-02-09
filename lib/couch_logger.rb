$: << File.dirname(__FILE__)
# require 'rfid_reader'
require 'fake_rfid_reader'
require 'json'
require 'socket'
require 'couchrest'

class CouchLogger

  def initialize(config_hash)
    @evdev_mappings = config_hash['input']
    @couchdb_url = config_hash['output']['couchdb_url']
    @debug_mode = config_hash['debug']
  end

  attr_writer :rfid_reader

  def start
    @rfid_reader ||= RfidReader.new

    @evdev_mappings.each do |filename, description|
      @rfid_reader.on(filename) do |_, unique_id, tag_id|
        publish_scan_event({
          tag_id: tag_id,
          reader_description: description,
          reader_evdev_filename: filename,
          reader_evdev_unique_id: unique_id,
          agent_hostname: hostname,
          agent_public_ip: public_ip,
          agent_local_ips: local_ips,
          agent_pid: pid
        })
      end
    end
  end


  private

  def publish_scan_event(event_hash)
    puts "JSONning it up: #{event_hash.to_json}"
  end

  def hostname
    @hostname ||= Socket.gethostname
  end

  def public_ip
    @public_ip ||= (`curl -s icanhazip.com`.strip rescue 'unknown')
  end

  def local_ips
    @local_ips ||= Socket.ip_address_list.map(&:inspect_sockaddr)
  end

  def pid
    @pid ||= Process.pid
  end

end

if __FILE__ == $0
  puts 'Test mode:'

  config_file_path = ENV['CONFIG_FILE'] || File.join(Dir.pwd, '.couch_logger.json')
  config = JSON.parse(File.open(config_file_path).read)

  fake_rfid_reader = FakeRfidReader.new
  couch_logger = CouchLogger.new(config)
  couch_logger.rfid_reader = fake_rfid_reader
  couch_logger.start

  trap("SIGINT") { couch_logger.stop }

  while(true) do; 
    sleep 1
    config['input'].each do |evdev_filename, description|
      evdev_id = evdev_filename.match(/\d+/)
      unique_id = "unique-evdev-#{evdev_id}"
      fake_rfid_reader.emit_fake(evdev_filename, unique_id)
    end
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
