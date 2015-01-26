<?php
# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Server helper functions
#
# version 1.0 [2015-01-25]

/**
 * Validate POSTed data
 *
 * @param string $email
 * @param double $latitude
 * @param double $longitude
 * @return boolean
 */
function validateData($email, $latitude, $longitude) {
	// check email, good enough :)
	if (!preg_match('/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$/i', $email)) {
		return false;
	}

	// check latitude 
	if (($latitude < -90) || ($latitude > 90)) {
		return false;
	}

	// check longitude
	if (($longitude < -180) || ($longitude > 180)) {
		return false;
	}

	return true;
}

/**
 * Validate POSTed file
 *
 * @param array $file
 * @return mixed
 */
function validateFile($file) {
	if (!empty($_FILES[$file]) && ($_FILES[$file]['error'] == UPLOAD_ERR_OK)) {
		$fileInfo = new finfo(FILEINFO_MIME_TYPE);
		$mimeType = $fileInfo->file($_FILES[$file]['tmp_name']);

		if (in_array($mimeType, array('image/jpeg', 'image/jpg'))) {
			return $_FILES[$file]['tmp_name'];
		}
	}

	return false;
}

/**
 * Create thumbs and save
 *
 * @param string $filePath
 * @param string $destinationDirectory
 * @return mixed
 */
function processFile($filePath, $destinationDirectory) {
	$image = new Imagick($filePath);

	if ($image && is_dir($destinationDirectory)) {
		$fileName = microtime(true);

		$image->thumbnailImage(800, 600);
		$image->writeImage($destinationDirectory . '/' . $fileName . '_large.jpg');
		$image->cropThumbnailImage(300,300);
		$image->writeImage($destinationDirectory . '/' . $fileName . '_thumb.jpg');

		$image->clear();
	}
}
