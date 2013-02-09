class FakeRfidReader
  def initialize(reads = [])
    @reads = reads
    @subscriptions = {}
  end

  def debug_mode=(enable_debugging)
  end

  def open
    @subscriptions = {}
  end

  def emit_fake(evdev_filename = "/dev/fake_rfid_reader0", unique_id = "fake reader 0")
    @subscriptions.each do |matcher, handlers|
      handlers.each do |handler|
        handler.call(evdev_filename, unique_id, next_read)
      end
    end
  end

  def close
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
