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
* NFC tags
  * <http://www.buynfctags.com/nfc-tags/stickers.html>
  * <http://rapidnfc.com/>

Cost estimate for 1 installation, assume 16 taps, 200 attendees:

    Item                 Qty     Ea      Total
    Raspberry Pi         1       35.00    35.00
    NFC controller       16      39.00   624.00
    NFC tags             200      1.00   200.00
    -------------------------------------------
                            Grand Total: 859.00
                      Cost per attendee:   4.30

Unaccounted costs: labels, tasting glasses.  Of course beer, taps, location, etc.

Core software layer
-------------------

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
