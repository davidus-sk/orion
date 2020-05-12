#!/usr/bin/perl

# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Imaging daemon
#
# version 1.1 [2015-01-23]
# version 1.2 [2020-05-06]

##
## libraries
##

use strict;
use warnings;

use Proc::Daemon;
use IO::All;
use Time::Piece;
use DateTime;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Orion::Helper qw(prepare_directory prepare_capture_command read_settings log_message get_sun_times is_defined);

##
## variables
##

# files and directories
my $running_flag_file = "/var/run/orion.imaging.running";
my $imaging_flag_file = "/var/run/orion.imaging";
my $processing_flag_file = "/var/run/orion.stacking";
my $temp_dir = "/var/www/temp";
my $temp_file = "orion-%08d.jpg";
my $settings_file = "$Bin/../data/settings.json";
my $destination;

# image capture
my $timeout = 0;
my $timelapse = 5000;
my $iso = 400;
my $exposure = "night";
my $shutter_speed = 1000000;
my $quality = 80;
my $width = 800;
my $height = 600;
my $command;

# daemon related
my $continue = 1;
my $is_daemon = defined($ARGV[0]) && ($ARGV[0] eq "-d") ? 1 : 0;

# read settings
my %settings = read_settings($settings_file);

my $longitude = is_defined($settings{location}{lon}, -81.4622782);
my $latitude = is_defined($settings{location}{lat}, 30.2416795);
my $altitude = is_defined($settings{location}{alt}, -15);

# get sunset/rise data
my ($sun_set, $sun_rise, $duration_minutes) = get_sun_times($latitude, $longitude, $altitude);

##
## code
##

# run only once
my $flag = io($running_flag_file);

if ($flag->exists) {
	die("$0 already running.\n");
} else {
	$flag->touch;
}

# init daemon
if ($is_daemon) {
	log_message("Starting imaging daemon at " . localtime() . "\n", $is_daemon);

	Proc::Daemon::Init;
	$continue = 1;
	$SIG{TERM} = sub { $continue = 0; $flag->unlink; };
	$SIG{KILL} = sub { $continue = 0; $flag->unlink; };

	# run stacker as a daemon
	`$Bin/stack.pl -d`;
}

# if ctrl-c
$SIG{INT} = sub { $continue = 0; $flag->unlink; };

# show info
log_message("Next sunset: " . $sun_set->datetime() . " " . $sun_set->time_zone()->name . ", next sunrise: " . $sun_rise->datetime() . " " . $sun_rise->time_zone()->name . "\n", $is_daemon);

# main loop
while ($continue) {
	# get current time
	my $time_now = DateTime->now();

	# continuously read settings
	%settings = read_settings("$Bin/../data/settings.json");

	# set variables
	$temp_dir = is_defined($settings{storage}{temp}, $temp_dir);

	$longitude = exists $settings{location}{lon} ? $settings{location}{lon} * 1 : $longitude;
	$latitude = exists $settings{location}{lat} ? $settings{location}{lat} * 1 : $latitude;
	$altitude = exists $settings{location}{alt} ? $settings{location}{alt} * 1 : $altitude;

	$timeout = $duration_minutes * 60 * 1000;
	$timelapse = exists $settings{camera}{timelapse} ? $settings{camera}{timelapse} * 1 : $timelapse;
	$iso = exists $settings{camera}{iso} ? $settings{camera}{iso} * 1 : $iso;
	$exposure = exists $settings{camera}{exposure} ? $settings{camera}{exposure} : $exposure;
	$shutter_speed = exists $settings{camera}{shutter_speed} ? $settings{camera}{shutter_speed} * 1 : $shutter_speed;
	$quality = exists $settings{camera}{quality} ? $settings{camera}{quality} * 1 : $quality;
	$width = exists $settings{camera}{width} ? $settings{camera}{width} * 1 : $width;
	$height = exists $settings{camera}{height} ? $settings{camera}{height} * 1 : $height;

	# prepare temp directory
	$temp_dir = prepare_directory($temp_dir);

	# capture if after sunset and before sunrise
	if ((DateTime->compare($time_now, $sun_rise) == -1) && (DateTime->compare($time_now, $sun_set) == 1)) {
		log_message("Starting imaging at " . localtime() . "\n", $is_daemon);

		# write flag
		`touch $imaging_flag_file`;

		# prepare temp file
		$destination = $temp_dir . "/" . $temp_file;

		# assemble command
		$command = prepare_capture_command($timeout, $timelapse, $iso, $exposure, 1, $shutter_speed, $quality, $width, $height, $destination);

		# take shots
		`$command`;

		# remove flag
		`rm -f $imaging_flag_file`;

		log_message("Finished imaging at " . localtime() . "\n", $is_daemon);

		# sync up time
		`rdate -s ntp1.csx.cam.ac.uk`;

		# get sunset/rise data
		($sun_set, $sun_rise, $duration_minutes) = get_sun_times($latitude, $longitude, $altitude);

		log_message("Next sunset: " . $sun_set->datetime() . ", next sunrise: " . $sun_rise->datetime() . "\n", $is_daemon);
	}

	# process images if any
	if (!$is_daemon && !io($temp_dir)->empty) {
		`$Bin/stack.pl`;
	}

	# mmm, delicious sleep
	sleep(30);
}

log_message("Stopping imaging daemon at " . localtime() . "\n", $is_daemon);
