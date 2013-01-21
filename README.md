nfc-beer
========

Notes for the `nfc-beer` project.

The Vision
----------

Homebrew party.  200 people.  16 taps.  Everybody has a tasting glass and a smartphone.

Your tasting glass has an NFC tag in it.  Each tap has a proximity sensor + NFC controller.
When a bartender pours, the tap tells the system that Tap A poured Beer B into Cup C.

Then, you sync your glass with your smartphone via an app, and can not only see
which beers you drank but also a host of background information about the beers:
production details, pictures of the brewers picking out hops, temp and gravity during
fermentation.

(If your smartphone doesnt do NFC yet, dont sweat; the label has a QR code and/or
an alphanumeric shortcode you can fall back to.)

You can also find out where to buy them, or order a few bottles delivered to your home.

You can rate and keep notes, of course.  You can see who else has a similar taste profile.

A slick projected display behind the bar visualizes the popularity of each beer,
current estimated tap levels, other fun associations.

The Core
--------

The core of this project is comprised of a few moving parts:

* NFC labels + taps hardware system
* Data schema, repository, and API

The higher-level features would be implemented as API clients on top of this;
say, an HTML5 mobile app for smartphone users and a separate D3.js-based
bar visualization.

Hardware layer
--------------

NFC labels + controllers.

[ ] Select and vet hardware.
[ ] Is it better to use Pi + NFC breakout (adafruit 364) or Pi + Arduino shields?

* Adafruit NFC/RFID on Raspberry Pi
  * <http://learn.adafruit.com/adafruit-nfc-rfid-on-raspberry-pi/overview>
* PN532 NFC/RFID controller breakout board - v1.3
  * <https://www.adafruit.com/products/364>
* Adafruit PN532 NFC/RFID Controller Shield for Arduino + Extras
  * <http://www.adafruit.com/products/789>
* Alternative NFC Arduino shield
  * <http://www.seeedstudio.com/depot/nfc-shield-p-916.html?cPath=132_134>
* Possibly interface Pi with Arduino shield
  * <http://www.raspberrypi.org/archives/tag/arduino>
  * <http://omer.me/2012/05/introducing-ponte/>
  * <http://hackaday.com/2012/05/06/using-arduino-shields-with-the-raspberry-pi/>
* Possibly need to multiplex UART from Pi to NFC controllers
  * <http://raspberrypi.stackexchange.com/questions/3475/how-to-get-more-than-one-uart-interface>
* NFC chip types
  * <http://www.gototags.com/docs/display/NFC/NFC+Chip+Types>
* Printed NFC stickers
  * <http://www.buynfctags.com/nfc-tags/stickers/custom-printed-nfc-sticker-ul.html>
  * <http://www.buynfctags.com/custom-printed-nfc-sticker-ntag203.html>
* Other NFC retailers
  * <http://rapidnfc.com/>
* Tasting glasses
  * <http://beeradvocate.com/community/threads/4-oz-tasting-glasses-or-similar.14643/>

USB-based readers:
* <http://www.gototags.com/docs/display/NFC/NFC+Readers>
* USB NFC read/write $45, or $40.50 in qty > 10
  * <http://www.buynfctags.com/nfc-readers-and-writers/acs-acr122u-nfc-usb-reader-and-writer.html>

Cost estimate for 1 installation, assume 16 taps, 200 attendees:

    Item                 Qty     Ea      Total
    Raspberry Pi         1       35.00    35.00
    NFC controller       16      39.00   624.00
    Printed NFC sticker  200      1.12   224.00
    Tasting glasses      200      1.80   360.00
    -------------------------------------------
                         Grand total:   1234.00
                   Cost per attendee:      6.22

Of course beer, taps, location, etc. are extra.

Another option instead of NFC is RFID.  NFC is two-way comm and read/write; but since
this is fundamentally an inventory tracking system (object tracking), RFID's
read-only mode suffices.  NFC lets you store small amounts of data onto the tag,
and NFC-p2p mode lets peer devices communicate.  RFID is a passive, activated read
technology.

* EBay USD RFID readers are about $9 shipped.
  <http://www.ebay.com/itm/New-Black-Security-USB-RFID-ID-Proximity-Sensor-Smart-Card-Reader-125Khz-EM4100-/221046309121?pt=BI_Security_Fire_Protection&hash=item3377630101>


Driver layer
------------

The tap terminal machine will need drivers to receive NFC/RFID scans and
emit events upstream to the web software layer.

If we use NFC, the driver layer is ???

* http://code.google.com/p/nfc-tools/

If we use RFID, we receive 1 HID-keyboard device per reader which just types
a 10-digit code.  Can we demux these streams?

* <http://stackoverflow.com/questions/8676135/osx-hid-filter-for-secondary-keyboard>
* evdev on linux
  * [evdev-ruby](http://hewner.com/2006/08/21/evdev-for-ruby-with-morse-code/)
  * [stackoverflow evdev question](http://stackoverflow.com/questions/5834220/how-to-read-out-an-usb-rfid-reader-imitating-an-hid-keyboard-using-linux-and-pyt)
    * [python evdev](http://128.130.182.59:8888/ceat/git/index.php?p=ceatclient.git&a=blob&h=d5be91bcf14cee983afdb03cfe8172b8984ac629&hb=42b464b5a31541e77d9955940d408d1c4bb40f88&f=evdev3.py)


Web software layer
------------------

Core entities:

* `beer`: an individual batch of brew
* `vessel`: how do we subdivide this into bottle etc
* `pour`: event
* `tag`: physical nfc tag

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
