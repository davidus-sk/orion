#!/usr/bin/perl

# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Installer
#
# version 1.0 [2015-01-24]

## libraries

use strict;
use warnings;

## variables

my $binary;

## code

print "ORION installer\n\nPlease be patient. This might take few minutes.\n\n";

print "Updating sources...\n\n";
`apt-get update -y`;

#
eval {
	require Proc::Daemon;
};

if($@) {
	print "Proc::Daemon\n";
	print " - Installing...\n";
	`apt-get install -y libproc-daemon-perl`;
}

#
eval {
	require Time::Piece;
};

if($@) {
	print "Time::Piece\n";
	print " - Installing...\n";
	`apt-get install -y libtime-piece-perl`;
}

#
eval {
	require DateTime::Event::Sunrise;
};

if($@) {
	print "DateTime::Event::Sunrise\n";
	print " - Installing...\n";
	`apt-get install -y libdatetime-event-sunrise-perl`;
}

#
eval {
	require IO::All;
};

if($@) {
	print "IO::All\n";
	print " - Installing...\n";
	`apt-get install -y libio-all-perl`;
}

#
eval {
	require JSON;
};

if($@) {
	print "JSON\n";
	print " - Installing...\n";
	`apt-get install -y libjson-perl`;
}

#
$binary = `which rdate`;

if ($binary eq "") {
	print "RDATE\n";
	print " - Installing...\n";
	`apt-get install -y rdate`;
}

#
$binary = `which apache2`;

if ($binary eq "") {
	print "APACHE2\n";
	print " - Installing...\n";
	`apt-get install -y apache2`;
}

#
$binary = `which convert`;

if ($binary eq "") {
	print "IMAGEMAGICK\n";
	print " - Installing...\n";
	`apt-get install -y imagemagick`;
}
