#!/usr/bin/perl

# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Main app
#
# version 1.0 [2015-01-23]

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

use Orion::Helper qw(prepare_directory prepare_stack_command prepare_capture_command read_settings log_message get_sun_times is_defined);

##
## variables
##

# files and directories
my $imaging_flag_file = "/var/run/orion.imaging";
my $processing_flag_file = "/var/run/orion.stacking";
my $temp_dir = "/var/www/temp";
my $temp_file = "orion-%08d.jpg";
my $destination_dir = "/var/www";
my $destination_file = "orion-%s.jpg";
my $destination = undef;
my $settings_file = "$Bin/../data/settings.json";

# cloud sharing
my $email = undef;
my $url = "http://orion.davidus.sk/process.php";

# image capture and stacking
my $timeout = 0;
my $timelapse = 5000;
my $iso = 400;
my $exposure = "night";
my $shutter_speed = 1000000;
my $quality = 80;
my $width = 800;
my $height = 600;
my $command = undef;

# daemon related
my $continue = 1;
my $is_daemon = defined $ARGV[0] && $ARGV[0] eq "-d" ? 1 : 0;

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

# init daemon
if ($is_daemon) {
	log_message("Starting daemon at " . localtime() . "\n", $is_daemon);

	Proc::Daemon::Init;
	$continue = 1;
	$SIG{TERM} = sub { $continue = 0; };
}

log_message("Next sunset: " . $sun_set->datetime() . ", next sunrise: " . $sun_rise->datetime() . "\n", $is_daemon);

# main loop
while ($continue) {
	# get current time
	my $time_now = DateTime->now();

	# continuously read settings
	%settings = read_settings("$Bin/../data/settings.json");

	# set variables
	$temp_dir = exists $settings{storage}{temp} ? $settings{storage}{temp} : $temp_dir;
	$destination_dir = exists $settings{storage}{final} ? $settings{storage}{final} : $destination_dir;

	$email = defined $settings{user}{email} ? defined $settings{user}{email} : undef;
	$url =  defined $settings{user}{url} ? defined $settings{user}{url} : undef;

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

	# prepare directories
	$temp_dir = prepare_directory($temp_dir);
	$destination_dir = prepare_directory($destination_dir);

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
	}

	# process images if any
	if (!io($temp_dir)->empty) {
		log_message("Starting stacking at " . localtime() . "\n", $is_daemon);

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

		log_message("Finished stacking at " . localtime() . "\n", $is_daemon);

		log_message("Cleaning up temp directory: " . $temp_dir . "\n", $is_daemon);

		# clean up
		`rm -f $temp_dir/*.jpg`;

		# upload to server
		if ($email && $url) {
			log_message("Starting image upload at " . localtime() . "\n", $is_daemon);

			`curl -F email=$email -F lat=$latitude -F lon=$longitude -F image=@$destination $url`;

			log_message("Finished upload at " . localtime() . "\n", $is_daemon);
		}

		# sync up time
		`rdate -s ntp1.csx.cam.ac.uk`;

		# get sunset/rise data
		($sun_set, $sun_rise, $duration_minutes) = get_sun_times($latitude, $longitude, $altitude);

		log_message("Next sunset: " . $sun_set->datetime() . ", next sunrise: " . $sun_rise->datetime() . "\n", $is_daemon);
	}

	# mmm, delicious sleep
	sleep(30);
}
