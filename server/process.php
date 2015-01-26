<?php
# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Image processor/receiver
#
# version 1.0 [2015-01-25]

// includes
require('functions.php');

// get uploaded params
$email = empty($_POST['email']) ? null : trim($_POST['email']);
$latitude = empty($_POST['lat']) ? null : $_POST['lat'] * 1;
$longitude = empty($_POST['lon']) ? null : $_POST['lon'] * 1;

// validate post
$fileValid = validateFile('image');
$postValid = validateData($email, $latitude, $longitude);

if ($postValid && $fileValid) {
	// prepare storage
	$emailHash = md5($email);
	$finalPath = dirname(__FILE__) .  '/images/' . substr($emailHash, 0, 6) . '/' . $emailHash;

	if (!is_dir($finalPath)) {
		mkdir($finalPath, 0755, true);
	}

	// process file
	if (processFile($fileValid, $finalPath)) {
		echo "OK";
	} else {
		throw new Exception('POSTed image cannot be processed.');
	}
} else {
	throw new Exception('POSTed data is invalid.');
}
