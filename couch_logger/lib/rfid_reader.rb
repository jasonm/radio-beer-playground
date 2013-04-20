require 'evdev'
require 'ostruct'
require 'logger'

# What happens if you #open, #on, #close, #open -- should the subscriptions persist?
class RfidReader
  attr_reader :devices, :subscriptions
  attr_accessor :logger, :evdev_open_method, :debug

  def initialize
    @devices = []
    @subscriptions = {}
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::WARN
    @evdev_open_method = Evdev::EventDevice.method(:open)
  end

  def debug_mode=(enable_debugging)
    if enable_debugging
      @logger.level = Logger::DEBUG
    else
      @logger.level = Logger::WARN
    end
  end

  def open
    if @devices.any?
      close
    end

    @connect_listener_thread = Thread.new do
      while(true) do
        logger.debug "Polling for new devices..."

        device_filenames.each do |filename|
          is_new_device = @devices.none? { |device| device.filename == filename }

          if is_new_device
            register_device(filename)
          end
        end

        sleep 1
      end
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
    @connect_listener_thread.kill

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
            handler.call(device_filename, matching_device.topology, read_string)
            called += 1
          end
        end
      end
    end

    logger.debug("#{device_filename} published #{read_string} to #{called} handlers")
  end

  def register_device(filename)
    logger.debug("#{filename} connecting...")
    handle = evdev_open_method.call(filename, "a+")

    thread = Thread.new do
      connected = true
      while(connected) do
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
        rescue Errno::ENODEV => e
          logger.debug("#{filename} disconnected.")
          @devices.reject! { |device| device.filename == filename }
          logger.debug("#{@devices.size} still connected.")
          handle.close
          connected = false
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
      topology: handle.topology,
      thread: thread
    })

    logger.debug("#{filename} Registered for #{device.name} #{device.topology}")

    @devices << device

    logger.debug("#{@devices.size} now connected.")
  end
end
