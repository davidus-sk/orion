# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Helper library
#
# version 1.0 [2015-01-23]

package Orion::Helper;

## libraries

use strict;
use warnings;

use IO::All;
use JSON;

use Exporter qw(import);

our @EXPORT_OK = qw(prepare_directory prepare_stack_command prepare_capture_command read_settings);

## code

# Clean directory name and create if does not exists
#
# @param string directory path
# @return string
sub prepare_directory {
	my $directory = @_;
	$directory  =~ s/\/$//;
	
	if (!io($directory)->exists) {
		io($directory)->mkdir;
	}
	
	return $directory;
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
	my $settings_file = @_;
	my $file = io($settings_file);

	if ($file->exists) {
		my $json_data = $file->all;
		return %{decode_json($json_data)};
	}

	return ();
}