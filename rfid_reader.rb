# class Rfid:
# generic input buffering and suscription:
# * gives a list of rfid devices
# * allows you to on/off for updates from any/all

# class RfidDevice: <file: '...', description: '...'>
# rfid = Rfid.new
# rfid.devices # => [{ :file => '/dev...', :description => '...' }, ...]

# class RfidE
# rfid = Rfid.new
# rfid.open do
#   rfid.on(:device => rfid_device) { |fn, event| ... }         # device filename and the event
#   rfid.on(:file => '/dev/input/event0') { |fn, event| ... }
#   rfid.on(:name => 'USB Whatever 123456') { |fn, event| ... }
#   rfid.on(:all) { |fn, event| ... }
# end # or rfid.close if no block provided

require 'evdev'
require 'ostruct'
require 'logger'


# What happens if you #open, #on, #close, #open -- should the subscriptions persist?
class RfidReader
  # struct Registration
  #   filename
  #   name
  #   unique_id
  #   handle

  attr_reader :devices, :subscriptions
  attr_accessor :logger, :evdev_open_method, :debug

  def initialize
    @devices = []
    @subscriptions = {}
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @evdev_open_method = Evdev::EventDevice.method(:open)
  end

  def open
    if @devices.any?
      close
    end

    device_filenames.each do |filename|
      register_device(filename)
    end

    if block_given?
      begin
        yield
      ensure
        close
      end
    end
  end

  def close
    @devices.each do |device|
      logger.debug("Killing thread for #{device.filename} #{device.thread}")
      logger.debug("Closing handle for #{device.filename} #{device.handle}")

      device.thread.kill
      device.handle.close
    end

    @devices = []
    @subscriptions = {}
  end

  def on(matcher, &blk)
    unless matcher.is_a?(Hash) || matcher == :all
      # TODO maybe also accept the literal ostruct objects
      raise ArgumentError.new("matcher must be :all or a hash, but got:\n#{matcher.inspect}")
    end

    logger.debug("Subscribing to #{matcher.inspect} for #{blk}")

    @subscriptions[matcher] ||= []
    @subscriptions[matcher] << blk
  end

  private

  def matching_devices(matcher)
    if matcher == :all
      @devices
    else
      @devices.select { |device|
        matcher.all? { |key, value|
          device.send(key) == value
        }
      }
    end
  end

  def device_filenames
    devices = Dir['/dev/input/event*']
  end

  def publish_scan_event(device_filename, read_string)
    logger.debug("#{device_filename} publishing #{read_string}")

    called = 0
    @subscriptions.each do |matcher, handlers|
      matching_devices(matcher).each do |matching_device|
        if matching_device.filename == device_filename
          handlers.each do |handler|
            handler.call(device_filename, read_string)
            called += 1
          end
        end
      end
    end

    logger.debug("#{device_filename} published #{read_string} to #{called} handlers")
  end

  def register_device(filename)
    logger.debug("#{filename} Probing...")
    handle = evdev_open_method.call(filename, "a+")

    thread = Thread.new do
      while(true) do
        begin
          read_string = ""
          event = nil
          until (event && event.feature.name == "ENTER" && event.value == 0)
            event = handle.read_event
            if %w(0 1 2 3 4 5 6 7 8 9).include?(event.feature.name) && event.value == 1
              read_string += event.feature.name
            end
          end
          publish_scan_event(filename, read_string)
        rescue Exception => e
          logger.error("#{filename} Exception in reader thread:")
          logger.error("#{e.class}: #{e.message}")
          e.backtrace.each { |line| logger.error("  #{line}") }
        end
      end
    end

    device = OpenStruct.new({
      filename: filename,
      handle: handle,
      name: handle.device_name,
      unique_id: handle.unique_id,
      thread: thread
    })

    logger.debug("#{filename} Registered for #{device.name} #{device.unique_id}")

    @devices << device
  end
end

if __FILE__ == $0
  puts "Test mode:"

  r = RfidReader.new
  r.logger.level = Logger::DEBUG
  r.open

  trap("SIGINT") { puts "Closing..." ; r.close ; exit }

  Dir['/dev/input/event*'].each do |filename|
    r.on(filename: filename) do |_, read_string|
      puts "Specific handler received: #{filename} - #{read_string}"
    end
  end

  r.on(:all) do |filename, read_string|
    puts "Matchall handler received: #{filename} - #{read_string}"
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
