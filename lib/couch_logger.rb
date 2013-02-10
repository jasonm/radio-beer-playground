$: << File.dirname(__FILE__)
require 'json'
require 'socket'
require 'couchrest'
require 'logger'

class CouchLogger
  def initialize(config_hash)
    @logger = Logger.new(STDOUT)
    if config_hash['debug']
      @logger.level = Logger::DEBUG
    else
      @logger.level = Logger::WARN
    end

    @evdev_mappings = config_hash['input']

    if config_hash['output']['couchdb_url']
      @db = CouchRest.database!(config_hash['output']['couchdb_url'])
      logger.debug("Connected to CouchDB at #{config_hash['output']['couchdb_url']}")
      @emit_method = :emit_to_couchdb
    elsif config_hash['output']['stdout']
      logger.debug("Emitting events to the console.")
      @emit_method = :emit_to_stdout
    end
  end

  attr_writer :rfid_reader

  def start
    @rfid_reader ||= RfidReader.new

    @evdev_mappings.each do |filename, description|
      load_reader_driver(filename)

      @rfid_reader.on(filename: filename) do |_, unique_id, tag_id|
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

  def stop
    @rfid_reader.close
  end

  private

  def logger
    @logger
  end

  def load_reader_driver(filename)
    if filename =~ %r{/dev/input/fake_event}
      require 'fake_rfid_reader'
    else
      require 'rfid_reader'
    end
  end

  def publish_scan_event(event_hash)
    self.send(@emit_method, event_hash)
  end

  def emit_to_couchdb(event_hash)
    response = @db.save_doc(event_hash)
    logger.debug("Emitting event: #{event_hash.inspect} - saved to CouchDB as #{response.inspect}")
  end

  def emit_to_stdout(event_hash)
    logger.info("Emitting event: #{event_hash.inspect}")
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
  logger = Logger.new(STDOUT)
  logger.debug('CouchLogger test mode.')

  config_file_path = ENV['CONFIG_FILE'] || File.join(Dir.pwd, '.couch_logger.json')
  config = JSON.parse(File.open(config_file_path).read)
  logger.debug('Configuration loaded.')

  require 'fake_rfid_reader'
  couch_logger = CouchLogger.new(config)
  fake_rfid_reader = FakeRfidReader.new(config)
  couch_logger.rfid_reader = fake_rfid_reader
  couch_logger.start

  running = true
  trap("SIGINT") do
    logger.debug('Shutting down...')
    couch_logger.stop 
    running = false
  end

  interval = 1
  logger.debug("Emitting fake events every #{interval} second(s)...")
  while(running) do
    fake_rfid_reader.emit_fakes
    sleep interval
  end
end
