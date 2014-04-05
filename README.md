#currentcost-envi#
================

## Introduction ##
Simple application to read the current wattage and temperature from a Current Cost envi device.

The script connects to /dev/ttyUSB0 and starts reading. If it detects a power usage update string it extracts the Wattage and the Temperatue and writes them to a watts.val and temp.val file respectively within '/var/cache/envi'.

* envi.initd - Simple init-d script
* envi.pl - Perl script to read from the ttyUSB0 device

##Pre-Requisite##
* Perl Device::SerialPort
* Perl HTML::TokeParser::Simple

## Usage ##

```Shell
cp envi.initd /etc/init.d/envi
ln -s /etc/init.d/envi /etc/rc2.d/ 
mkdir -p /opt/envi
cp envi.pl /opt/envi
chmod +x /opt/envi
/etc/init.d/envi start
```

```Shell
cat /var/cache/envi/watts.val
cat /var/cache/envi/temp.val
```

## Notes ##
The variables holding the location of the tty and output files are at the top of the perl script for easy changing. 

