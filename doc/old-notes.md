Hardware layer
--------------

We could use NFC or RFID.  RFID is cheaper, but new fancy phones do NFC.
RFID lets you detect/identify objects.  NFC lets you read *and* write a little
bit of data to the tag.

NFC operates at 13.56MHz.  RFID has low and high frequency modes; LF is 125KHz,
HF is 13.56MHz; this means that (as far as I know) HF RFID and NFC are
generally interoperable.

The cheapo ($9) RFID readers only do 125KHz (RFID-LF).

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
    USB Hub              1       10.00    10.00
    NFC controller       16      39.00   624.00
    Printed NFC sticker  200      1.12   224.00
    Tasting glasses      200      1.80   360.00
    -------------------------------------------
                         Grand total:   1244.00
                   Cost per attendee:      6.22

Of course beer, taps, location, etc. are extra.

Another option instead of NFC is RFID.  NFC is two-way comm and read/write; but since
this is fundamentally an inventory tracking system (object tracking), RFID's
read-only mode suffices.  NFC lets you store small amounts of data onto the tag,
and NFC-p2p mode lets peer devices communicate.  RFID is a passive, activated read
technology.

* [EBay USD RFID readers are about $9 shipped.](http://www.ebay.com/itm/New-Black-Security-USB-RFID-ID-Proximity-Sensor-Smart-Card-Reader-125Khz-EM4100-/221046309121?pt=BI_Security_Fire_Protection&hash=item3377630101)

Some notes on using em:

* <http://thetransistor.com/2011/10/hacking-cheap-rfid-readers/>
* <http://electronics.stackexchange.com/questions/9899/seeking-cheap-rfid-reader-writer>
* <http://hackaday.com/2011/11/19/getting-useful-data-from-a-dirt-cheap-rfid-reader/>

Note that 13.56mhz and 125khz are different.

Multiple RFID reader on Arduino, serial demux
  http://bildr.org/2011/02/rfid-arduino/

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

Getting it running on OSX: a virtual USB keyboard?
* http://www.practicalarduino.com/projects/virtual-usb-keyboard
* https://github.com/practicalarduino/VirtualUsbKeyboard

