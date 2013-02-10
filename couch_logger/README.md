CouchLogger: Overview
===============================================================================

This is designed to run on a Linux system (requires evdev) with multiple USB
HID RFID readers and network connectivity.

It reads RFID tag events off the taggers and logs these events into CouchDB.

Event devices ("evdevs") are in `/dev/input/event*`.

Installing
-------------------------------------------------------------------------------

* Install ruby 1.9.3
* Install rubygems
* Install non-gem https://github.com/Spakman/ruby_evdev:
  `ruby extconf.rb && make && sudo make install`
* Install gem `couchrest`

Preflight
-------------------------------------------------------------------------------

Once you attach your RFID reader(s) via USB, run `bin/list_evdevs` to
see information about each.  You can then scan tags against the readers to
learn the mapping from a phyiscal reader to its evdev filename path.

Configuration
-------------------------------------------------------------------------------

Edit `.couch_logger.json` to configure.

Here's an example `.couch_logger.json` configuration file:

    {
      "input": [
        ["/dev/input/event0", "RPi Alpha hosting USB RFID Reader Waltz"],
        ["/dev/input/event1", "RPi Alpha hosting USB RFID Reader Foxtrot"],
        ["/dev/input/event2", "RPi Alpha hosting USB RFID Reader Tango"]
      ],
      "output": {
        "couchdb_url": "https://user:pass@whatever.couchdb.url.you.use.com/dbname"
      },
      "debug": "debug"
    }

Input is collected from one or more evdev filenames.  List the ones you would
like to read from, and give them friendly names.  Those friendly names will
appear in the CouchDB database, and serve as a point of consistent reference in
case you later plug the readers into different USB ports or machines entirely.

Output is emitted to a CouchDB database.  Specify it in URL format.

Remove the `{ "debug": "debug" }` key/value pair to disable debugging output.


Usage
-------------------------------------------------------------------------------

Run: `bin/couch_logger`

Testing
-------------------------------------------------------------------------------

If you would like to generate fake events, use a `/dev/input/fake_event*` filename
in your configuration and the app will emit fake events:

    {
      "input": [
        ["/dev/input/fake_event0", "My imaginary yellow USB RFID reader"],
        ["/dev/input/fake_event1", "My imaginary blue USB RFID reader"],
      ],
      "output": {
        "couchdb_url": "https://user:pass@whatever.couchdb.url.you.use.com/dbname"
      },
      "debug": "debug"
    }

You cannot mix real and fake devices.

If you would like to emit output to the console instead of a CouchDB database,
replace the `{ "couchdb_url": "https:..." }` key/value pair with `{ "stdout": "true" }`.

Output
-------------------------------------------------------------------------------

Output into the CouchDB database looks like this:

    {
       "_id": "c0ab75c3e61c0eb425bf5f41af847c91",
       "_rev": "1-7a394d8779685285098d24cb6588f0a4",
       "type": "event/rfid-scan",
       "local_timestamp": "2013-02-09 18:22:34 -0800",
       "tag_id": "0002066454",
       "reader_description": "Jason Raspberry Pi with 125KHz Reader #1",
       "reader_evdev_filename": "/dev/input/event0",
       "reader_evdev_unique_id": "FM8PU83-Ver0E-0000",
       "agent_hostname": "raspberrypi",
       "agent_public_ip": "50.193.55.161",
       "agent_local_ips": [
           "127.0.0.1",
           "192.168.1.108"
       ],
       "agent_pid": 3185
    }
