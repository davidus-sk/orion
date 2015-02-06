#!/usr/bin/perl

# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Stacking daemon
#
# version 1.0 [2015-02-03]

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

use Orion::Helper qw(prepare_directory prepare_stack_command read_settings log_message is_defined);

##
## variables
##

# files and directories
my $stacking_flag_file = "/var/run/orion.stacking";
my $temp_dir = "/var/www/temp";
my $destination_dir = "/var/www";
my $destination_file = "orion-%s.jpg";
my $settings_file = "$Bin/../data/settings.json";
my $destination;

# cloud sharing
my $email;
my $url = "http://orion.davidus.sk/process.php";
my $longitude;
my $latitude;

# image stacking
my $command;
my $done = 0;

# daemon related
my $continue = 1;
my $is_daemon = defined($ARGV[0]) && ($ARGV[0] eq "-d") ? 1 : 0;

# read settings
my %settings = read_settings($settings_file);

##
## code
##

# init daemon
if ($is_daemon) {
	log_message("Starting stacking daemon at " . localtime() . "\n", $is_daemon);

	Proc::Daemon::Init;
	$continue = 1;
	$SIG{TERM} = sub { $continue = 0; };
}

# main loop
while ($continue) {
	# continuously read settings
	%settings = read_settings("$Bin/../data/settings.json");

	# set variables
	$temp_dir = is_defined($settings{storage}{temp}, $temp_dir);
	$destination_dir = is_defined($settings{storage}{final}, $destination_dir);

	$email = is_defined($settings{user}{email}, undef);
	$url =  is_defined($settings{user}{url}, undef);

	$longitude = is_defined($settings{location}{lon}, -81.4622782);
	$latitude = is_defined($settings{location}{lat}, 30.2416795);

	# prepare destination directory
	$destination_dir = prepare_directory($destination_dir);

	# if temp directory is not empty, process images within
	my $directory = io($temp_dir);

	if (!$directory->empty) {
		# filter out *.jpg files only
		my @files = $directory->filter(sub { $_->name =~ /.+\.jpg$/ })->all_files;
		my $count = scalar(@files);

		if ($count > 1) {
			# write flag
			`touch $stacking_flag_file`;

			# get first N items to process
			my $limit = $count > 20 ? 20 : $count;
			my @images = @files[0 .. $limit];

			# prepare final-temp image
			$destination = $temp_dir . "/0.jpg";

			# assemble command
			$command = prepare_stack_command(\@images, $destination, "max");

			# stack
			`$command`;

			# remove flag
			`rm -f $stacking_flag_file`;

			# clean up already processed images
			foreach (@images) {

				# skip the final-temp image
				if (defined($_) && ($_->filename ne "0.jpg")) {
					my $file = $_->name;
					`rm -f $file`;
				}
			}
			`rm -f /tmp/magic-*`;

			# reset done counter
			$done = 0;
		} else {
			# if no new images for 5 cycles, move final stacked image
			if ($done >= 5) {
				log_message("Finished stacking at " . localtime() . "\n", $is_daemon);

				# prepare final image
				my $date = localtime()->strftime('%F');
				$destination = $destination_dir . "/" . sprintf($destination_file, $date);
				my $temp_destination = $temp_dir . "/0.jpg";

				# move
				`mv $temp_destination $destination`;

				# upload to server
				if (io($destination)->exists) {
					if ($email && $url) {
						log_message("Starting image upload at " . localtime() . "\n", $is_daemon);

						`curl -F email=$email -F lat=$latitude -F lon=$longitude -F image=@$destination $url`;

						log_message("Finished upload at " . localtime() . "\n", $is_daemon);
					}
				} else {
					log_message("Failed to create stacked image\n", $is_daemon);
				}

				# final clean up
				`rm -f $temp_dir/*.jpg*`;
				`rm -f /tmp/magic-*`;
			}

			$done++;
		}
	}

	# wait for more images
	sleep(60);
}

log_message("Stopping stacking daemon at " . localtime() . "\n", $is_daemon);
