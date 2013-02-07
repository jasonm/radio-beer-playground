require 'evdev'

module Evdev
  class Feature
    def naming
      CodeMappings.feature_name(@type.code, @code)
    end
  end
end

t = Evdev::EventDevice.open("/dev/input/event0" , "a+")
puts "interface Version is #{t.event_interface_version}"
puts "bustype is #{t.bus_type_code}"
puts "bustype is #{t.bus_type_name}"
puts "vendor is #{t.vendor}"
puts "product is #{t.product}"
puts "version is #{t.version}"
puts "name is #{t.device_name}"
puts "topology is #{t.topology}"
puts "uniqueid is #{t.unique_id}"
puts "activated keys: #{t.activated_keys().inspect}"
puts t.write_event(17,2,1); # turn scrollock led on
puts "activated leds: #{t.activated_leds().inspect}"
# puts t.parameters_for_axis(0).inspect
t.supported_feature_types.each { | feature |
  begin
    puts "feature #{feature}: #{feature.supported_features.join(', ') }"
    # puts "feature #{feature}: #{feature.supported_features.map { |sf| sf.name }.join(', ') }"
    # puts feature.naming
  rescue IOError
  end
}

f = t.supported_feature_types.detect { |feature| feature.name == 'KEY' }

# race condition against multiple machines overlapping, producer/consumer safely demux it later
def get_read(ifile = '/dev/input/event0')
  t = Evdev::EventDevice.open(ifile, "a+")
  ev = nil
  readstring = ""
  until (ev && ev.feature.naming == "ENTER")
    ev = t.read_event
    if %w(0 1 2 3 4 5 6 7 8 9).include?(ev.feature.naming) && ev.value == 1
      readstring += ev.feature.naming
    end
  end

  t.close
  return readstring
end
