#!/usr/bin/perl -w
use strict;
use Device::SerialPort; 
use HTML::TokeParser::Simple;
use Data::Dumper;
use sigtrap qw/handler signal_handler normal-signals/;

package main;

my $debug = 1;

my $directory = '/var/cache/envi';
if ( ! -d $directory) {
  `mkdir -p $directory`
}
my $temperatureFile = 'temp.val';
my $wattsFile = 'watts.val';
my $pauseTime = '5';

$main::port = Device::SerialPort->new("/dev/ttyUSB0");

unless ($main::port) {
 print STDERR "Failed to open port - $!\n";
 exit (1);
}
# screen /dev/ttyUSB0 57600 cs8

$main::port->baudrate(57600);
$main::port->parity("none");
$main::port->handshake("none");
$main::port->databits(8);
$main::port->stopbits(1);
$main::port->read_char_time(0);
$main::port->read_const_time(1000);

my $STALL_DEFAULT=100; # how many seconds to wait for new input 
my $timeout=$STALL_DEFAULT;

#my $chars=0;
 my $buffer="";
 while ($timeout>0) {
print STDERR "In read loop\n" if $debug;
        my ($count,$saw)=$main::port->read(2048); # will read _up to_ 2048 chars
print STDERR "Read ${count} bytes\n" if $debug;
        if ($count > 0 and $saw !~ /hist/) {               
               my $xmlline = HTML::TokeParser->new(\$saw);
               unless ($xmlline) { print STDERR "Failed to create xml object\n"; }
               my $token = $xmlline->get_tag("tmpr");
               my $temperature = $xmlline->get_text("/tmpr");
                  $token = $xmlline->get_tag("watts");
               my $watts = int($xmlline->get_text("/watts"));
               if ($watts       =~ /[0-9]+/)   { `echo '$watts' > $directory/$wattsFile` };
               if ($temperature =~ /[\.0-9]+/) { `echo '$temperature' > $directory/$temperatureFile` };
               print STDERR "read: $saw\n" if $debug;
               print STDERR "t: $temperature\n" if $debug;
               print STDERR "w: $watts\n" if $debug;
# Message Format --------------------------------------------------------------------------------------------------------------------------------------------------------
# <msg><src>CC128-v0.11</src><dsb>00240</dsb><time>15:49:38</time><tmpr>26.1</tmpr><sensor>0</sensor><id>00077</id><type>1</type><ch1><watts>00895</watts></ch1></msg>
                #$chars+=$count;
        }
        else {
#                $timeout--;
        }
   sleep $pauseTime;
 }

sub signal_handler {
    $main::port->close;
    print STDERR "Closing port and exiting\n";
    exit (0);
}

