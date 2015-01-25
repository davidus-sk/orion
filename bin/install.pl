#!/usr/bin/perl

# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Installer
#
# version 1.0 [2015-01-24]

##
## libraries
##

use strict;
use warnings;

use Scalar::Util qw(looks_like_number);
use FindBin qw($Bin);

##
## variables
##

my ($binary, $lat, $lon, $email, $file, $contents);

##
## code
##

print "ORION installer\n================\n\n";

print "First, lets determine where you are located. This is needed to calculate sunset\n";
print "and sunrise times for your location. If you are not sure what your latitude and\n";
print "longitude values are, please consult Google. Press CTRL-C to abort installation.\n";
print "Latitude and longitude are entered in signed degree format, e.g. -30.12345.\n\n";

print "Please enter your latitude [e.g. 30.2416795]: ";
while (1) {
	$lat = <STDIN>;
	chomp $lat;

	if (looks_like_number($lat) && ($lat >= -90) && ($lat <= 90)) {
		$lat = $lat * 1;
		last;
	} else {
		print "Invalid. Try again: ";
	}
}

print "Please enter your longitude [e.g. -81.4622782]: ";
while (1) {
	$lon = <STDIN>;
	chomp $lon;

	if (looks_like_number($lon) && ($lon >= -180) && ($lon <= 180)) {
		$lon = $lon * 1;
		last;
	} else {
		print "Invalid. Try again: ";
	}
}

print "\nIf you want to share your stacked sky images with other ORION users and receive\n";
print "notifications when your stacking has finished, please provide your email address.\n";
print "If not, hit ENTER. Your email address will not be shared with anyone.\n\n";
print "Your email address [e.g. me\@raspberry.pi]: ";
$email = <STDIN>;
chomp $email;

print "\n================\n\nStarting installation. Please be patient. This might take few minutes. Internet connectivity is required.\n\n";

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

#
print "\n================\n\nUpdating settings file.\n";

use IO::All;

$file = io("$Bin/../data/settings.json");

if ($file->exists) {
	$contents = $file->all;
	$contents =~ s/"lon":[0-9"\.+\-]+/"lon":$lon/g;
	$contents =~ s/"lat":[0-9"\.+\-]+/"lat":$lat/g;

	if ($email ne "") {
		$contents =~ s/"email":"[^"]*"/"email":"$email"/g;
		$contents =~ s/"email":null/"email":"$email"/g;
	}

	$file->buffer($contents);
	$file->write;
}
