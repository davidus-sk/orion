# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Helper library
#
# version 1.0 [2015-01-23]

package Orion::Helper;

##
## libraries
##

use strict;
use warnings;

use IO::All;
use JSON;
use DateTime;
use DateTime::Event::Sunrise;

use Exporter qw(import);

our @EXPORT_OK = qw(prepare_directory prepare_stack_command prepare_capture_command read_settings log_message get_sun_times);

##
## code
##

# Clean directory name and create if does not exists
#
# @param string directory path
# @return string
sub prepare_directory {
	my ($path) = @_;
	$path =~ s/\/$//;
	my $directory = io($path);

	if (!$directory->exists) {
		$directory->mkdir;
	}
	
	return $path;
}

# Prepare imagemagick stack command
#
# @param string temporary directory
# @param string destination file
# @param string stacking function
# @return string
sub prepare_stack_command {
	my ($temp_dir, $destination, $function) = @_;
	
	return "convert $temp_dir/*.jpg -evaluate-sequence $function $destination";
}

# Prepare raspistill capture command
#
# @param integer timeout for image collection
# @param integer delay between images
# @param integer ISO speed
# @param string exposure value
# @param boolean use image stabilization
# @param integer shutter speed
# @param integer JPEG image quality
# @param integer image width
# @param integer image height
# @param string captured image destination
# @return string
sub prepare_capture_command {
	my ($timeout, $timelapse, $iso, $exposure, $stabilization, $shutter_speed, $quality, $width, $height, $destination) = @_;
	
	return "raspistill -t $timeout -tl $timelapse -n -ISO $iso -ex $exposure " . ($stabilization ? "-vs" : "") . " -ss $shutter_speed -q $quality -w $width -h $height -o $destination > /dev/null 2>&1";
}

# Read configuration settings from file
#
# @param string path to settings file
# @retun hash
sub read_settings {
	my ($settings_file) = @_;
	my $file = io($settings_file);

	if ($file->exists) {
		my $json_data = $file->all;
		return %{decode_json($json_data)};
	}

	return ();
}

# Log debug message
#
# @param string message body
# @param booelan is daemon running
# @return void
sub log_message {
	my ($message, $is_daemon) = @_;

	if (!$is_daemon) {
		print $message;
	}
}

# Get sunset and sunrise for location
#
# @param double latitude
# @param double longitude
# @param double altitude
# @return double
sub get_sun_times {
	my ($latitude, $longitude, $altitude) = @_;

	my $sun = DateTime::Event::Sunrise->new(longitude => $longitude, latitude  => $latitude, altitude => $altitude);
	my $time_now = DateTime->now();
	my $sun_set = $sun->sunset_datetime($time_now);
	my $time_tomorrow = $sun_set->clone()->add_duration(DateTime::Duration->new(days => 1));
	my $sun_rise = $sun->sunrise_datetime($time_tomorrow);
	my $duration_minutes = $sun_rise->subtract_datetime($sun_set)->in_units("minutes");

	return ($sun_set, $sun_rise, $duration_minutes);
}
