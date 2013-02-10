CouchLogger: Overview
===============================================================================

This is designed to run on a Linux system (requires evdev) with multiple USB
HID RFID readers and network connectivity.

It reads RFID tag events off the taggers and logs these events into CouchDB.

Event devices are in `/dev/input/event*`.

Installing
-------------------------------------------------------------------------------

* Install ruby 1.9.3.
* Install rubygems
* Install non-gem https://github.com/Spakman/ruby_evdev:
  `ruby extconf.rb && make && sudo make install`
* Install gem `couchrest`

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

Run:

    ruby couch_logger.rb

Testing
-------------------------------------------------------------------------------

If you would like to emit fake events, use a `/dev/input/fake_event*` filename
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
