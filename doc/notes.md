radio-beer
==========

Notes for the `radio-beer` project.

The Vision
----------

Homebrew party.  200 people.  16 taps.  Everybody has a tasting glass and a smartphone.

Your tasting glass has an RFID tag in it, along with a printed label with
nickname.  Each tap has a RFID reader.  When a bartender pours, the tap tells
the system that Tap A poured Beer B into Cup C.

Then, you sync your glass with your smartphone app, and can not only see
which beers you drank but also a host of background information about the beers:
production details, pictures of the brewers picking out hops, temp and gravity during
fermentation.

You can also find out where to buy them, or order a few bottles delivered to your home.

You can rate and keep notes, of course.  You can see who else has a similar taste profile.

A slick projected display behind the bar visualizes the popularity of each beer,
current estimated tap levels, other fun associations.

A walkabout photographer will snap photos of people that they check-in to by "cheers"ing
their glasses (rfid scan to connect).

The Core
--------

The core of this project is comprised of a few moving parts:

* RFID labels + taps hardware system
* Data schema, repository, and API

The higher-level features would be implemented as API clients on top of this;
say, an HTML5 mobile app for smartphone users and a separate D3.js-based
bar visualization.

Hardware layer
--------------

An RFID cost estimate for 2 bars, 16 taps total:

    Item                 Qty     Ea      Total
    Raspberry Pi         2       35.00    70.00
    Pi Case              2       17.95    35.90
    Pi Wifi              2       15.99    31.98
    USB Hub              2       27.99    55.98
    RFID controller      16      13.00   208.00
    Printed RFID sticker 200      1.00   200.00
    Tasting glasses      200      1.80   360.00
    -------------------------------------------
                         Grand total:    961.86
                   Cost per attendee:      4.81

* Satechi Powered 12xUSB Hub http://www.amazon.com/Satechi-Power-Adapter-Control-Switches/dp/B0051PGX2I/ref=sr_1_1
* USB 125KHz RFID reader: http://www.amazon.com/gp/product/B005JWGU6C/ref=oh_details_o00_s00_i00
* RPi case: http://www.amazon.com/CY-Raspberry-Pi-Case-Blueberry/dp/B00A42HTLC/ref=lh_ni_t?ie=UTF8&psc=1
* RPi wifi: http://www.amazon.com/Edimax-EW-7811Un-Wireless-Adapter-Wizard/dp/B005CLMJLU/ref=sr_1_1

Aiming for 125KHz LF-RFID to work with the cheapo readers.
Otherwise, reader costs jump to 40/per, a $432 increase.
Not UHF RFID.  Not 13.56 MHz RFID/NFC.

Possible physical layouts:
* Tasting glasses with printed RFID stickers.  Finding it hard to source printed 125KHz.
* Tasting glasses with "beer charm" - like wine charm, but made of a keyfob.  Kinda janky.
* Tasting glasses with beer koozie, die/punch-cut out a hole for an RFID puck,
  overlay with sticker.  Best compromise of nice/janky?

Driver layer
------------

RFID USB HID via linux evdev to couchdb event log.  See rfid_reader, couch_logger programs.

Web software layer
------------------

Core entities:

* `beer`: an individual batch of brew
* `vessel`: how do we subdivide this into bottle etc
* `pour`: event
* `tag`: physical rfid tag

Pre-fill database with beers in vessels.
Smart taps publish `pour` events that link `beer` to a `tag`.

API clients
------------

* *Mobile web app* registers `tag` with a `user`, fetches contents via core api
  and displays `beer` information based on that.
* *Bar display* fetches information from core api like tallies of pours, synthesiszes it,
   and displays beautiful visualizations.

Related Works
-------------

* KegDroid—The Google-Powered Beer Tap
  * <http://gizmodo.com/5906483/kegdroidthe-google+powered-beer-tap>

* Flow sensor to Untappd
  * <http://hackaday.com/2012/07/18/kegerator-tallies-your-pints-on-untappd-while-you-sit-back-with-a-cold-one/>

* tokyohackerspace beer tap + rfid suggestion
  * <https://groups.google.com/forum/#!msg/tokyohackerspace/-sKrUmhuJpc/vP5E0tX6SNYJ>
