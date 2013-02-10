require 'digest/md5'

class FakeRfidReader
  def initialize(config = {})
    @reads = config['reads'] || []
    @fake_devices = config['input'] || [['/dev/input/fake_event0', 'My Fake RFID USB HID Reader']]
    @subscriptions = {}
    @running = false
  end

  def debug_mode=(enable_debugging)
  end

  def open
    @running = true
  end

  def emit_fakes
    return unless @running

    @fake_devices.each do |filename, descriptor|
      @subscriptions.each do |matcher, handlers|
        if (matcher == :all) || (matcher[:filename] == filename)
          handlers.each do |handler|
            unique_id = "fake-rfid-#{Digest::MD5.hexdigest(descriptor)}"
            handler.call(filename, unique_id, next_read)
          end
        end
      end
    end
  end

  def close
    @running = false
  end

  def on(matcher, &blk)
    @subscriptions[matcher] ||= []
    @subscriptions[matcher] << blk
  end

  private

  def next_read
    @reads.pop || (rand * 10000000000).to_i
  end
end
