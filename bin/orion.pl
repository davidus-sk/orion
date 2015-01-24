#!/usr/bin/perl

# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# version 1.0 [2015-01-23]

use strict;
use warnings;

use IO::All;
use Time::Piece;
use DateTime;
use DateTime::Event::Sunrise;

use FindBin qw($Bin);
use lib "$Bin/../lib";

use Orion::Helper qw(prepare_directory prepare_stack_command prepare_capture_command);;

# global variables
my $imaging_flag_file = "/var/run/orion.imaging";
my $processing_flag_file = "/var/run/orion.processing";
my $temp_dir = "/var/www/temp";
my $temp_file = "orion-%08d.jpg";
my $destination_dir = "/var/www";
my $destination_file = "orion-%s.jpg";

my $longitude = -81.4622782;
my $latitude = 30.2416795;
my $altitude = -15;

my ($destination, $command);

# hello


# main loop
while (1) {

	# get sunrise/sunset times
	my $sun = DateTime::Event::Sunrise->new(longitude => $longitude, latitude  => $latitude, altitude => $altitude);
	my $time_now = DateTime->now();
	my $sun_set = $sun->sunset_datetime($time_now);
	my $time_tomorrow = $sun_set->clone()->add_duration(DateTime::Duration->new(days => 1));
	my $sun_rise = $sun->sunrise_datetime($time_tomorrow);
	my $duration_minutes = $sun_rise->subtract_datetime($sun_set)->in_units("minutes");

	print "Latitude: " . $latitude . "\n";
	print "Longitude: " . $longitude . "\n";
	print "Altitude: " . $altitude . "\n\n";

	print "Now: " . $time_now->datetime() . "\n";
	print "Sunset: " . $sun_set->datetime() . "\n";
	print "Sunrise: " . $sun_rise->datetime() . "\n";
	print "Duration: " . $duration_minutes . "m\n\n";

	# read settings
	my $timeout = $duration_minutes * 60 * 1000;
	my $timelapse = 1100;
	my $iso = 400;
	my $ex = "night";
	my $shutter_speed = 1000000;
	my $quality = 80;
	my $width = 800;
	my $height = 600;

	print "Imaging duration: " . $timeout . "ms\n";
	print "Time between shots: " . $timelapse . "ms\n";
	print "Shutter speed: " . ($shutter_speed/1000) . "ms\n";

	# prepare directories
	$temp_dir = prepare_directory($temp_dir);
	$destination_dir = prepare_directory($destination_dir);

	# capture if after sunset and before sunrise
	if ((DateTime->compare($time_now, $sun_rise) == -1) && (DateTime->compare($time_now, $sun_set) == 1)) {
		print "Starting imaging at " . localtime() . "\n";

		# write flag
		`touch $imaging_flag_file`;

		# prepare temp file
		$destination = $temp_dir . "/" . $temp_file;

		# assemble command
		$command = prepare_capture_command($timeout, $timelapse, $iso, $ex, 1, $shutter_speed, $quality, $width, $height, $destination);

		# take shots
		`$command`;

		# remove flag
		`rm -f $imaging_flag_file`;

		print "Stopped imaging at " . localtime() . "\n";
	}

	# process images if any
	if (!io($temp_dir)->empty) {
		print "Starting stacking at " . localtime() . "\n";

		# write flag
		`touch $processing_flag_file`;

		# prepare final image
		my $date = localtime()->strftime('%F');
		$destination = $destination_dir . "/" . sprintf($destination_file, $date);

		# assemble command
		$command = prepare_stack_command($temp_dir, $destination, "max");

		# stack
		`$command`;

		# remove flag
		`rm -f $processing_flag_file`;

		print "Stopped stacking at " . localtime() . "\n";

		print "Cleaning up temp dir: " . $temp_dir . "\n";

		# clean up
		`rm -f $temp_dir/*.jpg`;
	}

	# hmmm, delicious sleep
	sleep(30);
}
