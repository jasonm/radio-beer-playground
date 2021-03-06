require 'json'
require 'json/ext'
JSON.parser = JSON::Ext::Parser

require 'socket'
require 'couchrest'
require 'logger'


class CouchLogger
  def initialize(config)
    @config = config
    @logger = Logger.new(STDOUT)
    if config['debug']
      @logger.level = Logger::DEBUG
    else
      @logger.level = Logger::WARN
    end

    @evdev_mappings = config['input']

    if config['output']['couchdb_url']
      @db = CouchRest.database(config['output']['couchdb_url'])
      logger.debug("Connected to CouchDB at #{config['output']['couchdb_url']}")
      @emit_method = :emit_to_couchdb
    elsif config['output']['stdout']
      logger.debug("Emitting events to the console.")
      @emit_method = :emit_to_stdout
    end
  end

  attr_writer :rfid_reader

  def start
    @rfid_reader ||= begin
      require_relative './rfid_reader'
      RfidReader.new
    end

    @rfid_reader.debug_mode = @config['debug']

    @evdev_mappings.each do |filename, description, reader_id|
      logger.debug("Registering to #{filename}")
      @rfid_reader.on(filename: filename) do |_, unique_id, tag_id|
        publish_scan_event({
          type: 'rfid-scan',
          created_at: Time.now.to_s,
          agent_hostname: hostname,
          agent_public_ip: public_ip,
          agent_local_ips: local_ips,
          agent_pid: pid,
          reader_id: reader_id,
          tag_id: tag_id
        })
      end
    end

    @rfid_reader.open
  end

  def stop
    @rfid_reader.close
  end

  def any_unregistered_device_tokens?
    @config['input'].any? { |reader_attributes_array| reader_attributes_array.size == 2 }
  end

  def register_new_device_tokens
    @config['input'].each do |reader_attributes_array|
      evdev_filename, description, database_id = reader_attributes_array

      if database_id.nil?
        response = @db.save_doc({
          type: 'rfid-reader',
          created_at: Time.now.to_s,
          reader_description: description,
          reader_evdev_filename: evdev_filename,
          agent_hostname: hostname,
          agent_public_ip: public_ip,
          agent_local_ips: local_ips,
          agent_pid: pid
        })

        new_id = response['id']
        logger.info "Registered device #{evdev_filename}: '#{description}' as id: #{new_id}"
      end
    end
  end

  private

  def logger
    @logger
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
