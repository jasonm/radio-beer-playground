2013-01-30 BrewLabSF Hack Night
=================================

RFID toys:

* Reader:  http://www.ebay.com/itm/310350794677
* Keyfobs: http://www.ebay.com/itm/390496455125
* Tokens:  http://www.ebay.com/itm/150971085207

Ideas:
* Alternative to smartphone UI for rating:
  * Kiosk for self-identifying ratings & flavor ID; 1-10 scale on kiosk activated by RFID "Cheers!"ing your glass, or you associate and then touch screen
  * Bartender takes your glass, asks "what did you think?" and taps your glass to a thing where they then enter your rating

Cannot get a read via OSX HID.

Curious to try linux /dev/tty0
* Plugged into Pi; Pi died.  Hypothesis: power draw
  * Later determined the issue was just a flaky ethernet cable?  Anyway, power draw was OK.  But likely want a powered USB hub for many readers.

Opened up the device and found:
* IC (likely USB) is STC 15F104E H3T001A
  * Googling "STC 15F104E" yields results

USB snooping on OSX
* http://shivramk.net/2010/09/usb-snooping-on-mac-os-x/
* USB Prober.app does reveal the device, but still no information from it.

Tried it on the Pi on linux
* Got it with /dev/input/event0 !

But it emits gibberish.

Need to parse with evdev.

Tried this briefly, could not quickly figure it out.  Worth examining more closely:
  http://128.130.182.59:8888/ceat/git/index.php?p=ceatclient.git&a=blob&h=d5be91bcf14cee983afdb03cfe8172b8984ac629&hb=42b464b5a31541e77d9955940d408d1c4bb40f88&f=evdev3.py

Also tried to install this but linux-headers-3.27 were too large for the mostly-full 4GB ISO-derived rpi SD card disk image.

* http://gvalkov.github.com/python-evdev/
    * Requirements
      * evdev contains C extension modules and requires the Python development headers as well as the kernel headers.
      * On a Debian compatible OS:
        * $ apt-get install python-dev
        * $ apt-get install linux-headers-$(uname -r)
          * except on pi, getting headers is manual:
          * http://www.raspberrypi.org/phpBB3/viewtopic.php?f=71&t=17666

```
sudo bash
cd /usr/src
wget  https://github.com/raspberrypi/linux/tarball/rpi-3.2.27
# bailed on the next line with "no space left on device"
tar xzf rpi-3.2.27
cd raspberrypi-linux-*
zcat /proc/config.gz > .config
make oldconfig
make modules_prepare
```

2013-02-06 Pi Day!
===================

Raspberry Pi arrived yesterday, doing some early morning hacking today.

It works very smoothly, USB and HDMI and the tiny USB wireless N and all.

Also the RFID reader spits a nice 10 digits + CRLF to the input.

Gonna try some ruby evdev:
* http://technofetish.net/repos/buffaloplay/ruby_evdev/doc/
  * 1.9 update: git://github.com/Spakman/ruby_evdev.git

evdev info:
* http://gvalkov.github.com/python-evdev/moduledoc.html
* http://www.linuxjournal.com/article/6429

So first get ruby and rubygems.
* http://elinux.org/RPi_Ruby#Ruby_v1.9.x

Fooling around with keyboard | # ~ keys etc
* http://elinux.org/R-Pi_Troubleshooting#Re-mapping_the_keyboard_with_Debian_Squeeze
* http://www.drijf.net/linuxppc/ISOvsANSI.html

Got ruby_evdev working!

 > t = Evdev::EventDevice.open("/dev/input/event0" , "a+")
 > t.unique_id
=> "FM8PU83-Ver0E-0000"
 > t.device_name
=> "USB Reader With Keyboard USB Reader With Keyboard"
