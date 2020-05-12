#!/usr/bin/perl

# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Installer
#
# version 1.0 [2015-01-24]
# version 1.1 [2020-05-06]

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

my ($binary, $lat, $lon, $email, $file, $contents, $fh);

##
## code
##

print "ORION installer\n================\n\n";

print "\e[33mFirst, lets determine where you are located. This is needed to calculate sunset\n";
print "and sunrise times for your location. If you are not sure what your latitude and\n";
print "longitude values are, please consult Google. Press \e[31mCTRL-C\e[33m to abort installation.\n";
print "Latitude and longitude are entered in signed degree format, e.g. -30.12345.\e[0m\n\n";

print "Please enter your latitude [e.g. 30.2416795]: ";
while (1) {
	$lat = <STDIN>;
	chomp $lat;

	if (looks_like_number($lat) && ($lat >= -90) && ($lat <= 90)) {
		$lat = $lat * 1;
		last;
	} else {
		print "Invalid latitude. Try again: ";
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
		print "Invalid longitude. Try again: ";
	}
}

print "\n\e[33mIf you want to share your stacked sky images with other ORION users and receive\n";
print "notifications when your stacking has finished, please provide your email address.\n";
print "If not, hit ENTER. Your email address will not be shared with anyone.\e[0m\n\n";

print "Your email address [e.g. me\@raspberry.pi]: ";
while (1) {
	$email = <STDIN>;
	chomp $email;

	if (($email eq "") || ($email =~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$/i)) {
		last;
	} else {
		print "Invalid email. Try again: ";
	}
}

print "\n================\n\n";
print "\e[33mStarting installation. Please be patient. This might take few minutes. \e[31mInternet\n";
print "connectivity is required.\e[0m\n\n";

print "\e[32mUpdating sources...\e[0m\n\n";
`apt-get update -y`;

#
eval {
	require Proc::Daemon;
};

if($@) {
	print "\e[32mProc::Daemon\e[0m\n";
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
$binary = `which ntpdate`;

if ($binary eq "") {
	print "ntpdate\n";
	print " - Installing...\n";
	`apt-get install -y ntpdate`;
}

#
$binary = `which apache2`;

if ($binary eq "") {
	print "\e[32mapache2\e[0m\n";
	print " - Installing...\n";
	`apt-get install -y apache2`;
}

#
$binary = `which php`;

if ($binary eq "") {
	print "\e[32mPHP\e[0m\n";
	print " - Installing...\n";
	`apt-get install -y php libapache2-mod-php`;
	`a2enmod php`;
}

#
$binary = `which convert`;

if ($binary eq "") {
	print "ImageMagick\n";
	print " - Installing...\n";
	`apt-get install -y imagemagick`;
}

#
print "\n================\n\n\e[32mUpdating settings file...\e[0m\n";

$file = "$Bin/../data/settings.json";

if (-f $file) {
	open $fh, '<', $file or die "Couldn't open file: $!"; 
	$contents = join("", <$fh>);
	close $fh;

	$contents =~ s/"lon":[0-9"\.+\-]+/"lon":$lon/g;
	$contents =~ s/"lat":[0-9"\.+\-]+/"lat":$lat/g;

	if ($email ne "") {
		$contents =~ s/"email":"[^"]*"/"email":"$email"/g;
		$contents =~ s/"email":null/"email":"$email"/g;
	}

	open $fh, '>', $file or die "Couldn't open file: $!";
	print $fh $contents;
	close $fh;

	chmod 0777, $file;
}

print "Synchronizing time...\n";
`ntpdate -s time.google.com`;

print "Settings up configuration web tool...\n";

$file = "/etc/apache2/sites-available/000-default.conf";

if (-f $file) {
	open $fh, '+>>', $file or die "Couldn't open file: $!"; 
	seek $fh, 0, 0;
	$contents = join("", <$fh>); 

	if ($contents =~ /\/orion/) {
	} else {
		seek $fh, 0, 2;
		print $fh "\nAlias /orion $Bin/../web\n";
		print $fh "<Directory $Bin/../web>\n\tRequire all granted\n</Directory>\n";
	}

	close $fh;
}

# restart apache
`service apache2 restart`;
