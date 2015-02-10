<?php
# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Configuration form
#
# version 1.0 [2015-02-07]

require 'functions.php';

$settings = false;
$file = dirname(__FILE__) . '/../data/settings.json';

// if new data posted, process
if (isset($_POST['submit'])) {
	// clean few things
	$_POST['user']['email'] = empty($_POST['user']['email']) ? null : trim($_POST['user']['email']);
	$_POST['location']['lat'] = $_POST['location']['lat'] * 1;
	$_POST['location']['lon'] = $_POST['location']['lon'] * 1;
	$_POST['location']['alt'] = $_POST['location']['alt'] * 1;
	$_POST['camera']['timelapse'] = $_POST['camera']['timelapse'] * 1;
	$_POST['camera']['iso'] = $_POST['camera']['iso'] * 1;
	$_POST['camera']['timelapse'] = $_POST['camera']['timelapse'] * 1;
	$_POST['camera']['shutter_speed'] = $_POST['camera']['shutter_speed'] * 1;
	$_POST['camera']['quality'] = $_POST['camera']['quality'] * 1;
	$_POST['camera']['width'] = $_POST['camera']['width'] * 1;
	$_POST['camera']['height'] = $_POST['camera']['height'] * 1;
	unset($_POST['submit']);

	// write to file
	file_put_contents($file, json_encode($_POST));
}

if (file_exists($file)) {
	$contents = file_get_contents($file);
	$settings = json_decode($contents, true);
}
?>
<!DOCTYPE html>
<html>
<head>
	<title>Orion</title>

	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
	<meta name="keywords" content="" />
	<meta name="description" content="" />

	<link href="//fonts.googleapis.com/css?family=Oswald" rel="stylesheet" type="text/css">
	<link href="//fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="css/style.css" media="all">
</head>
<body>
	<div class="wrapper">
		<form id="form" action="" method="post">
			<h1>Orion</h1>
			<div class="row">
				<label>Imaging daemon</label>
				<?php if (file_exists('/var/run/orion.imaging.running')) { echo '<span class="daemon">Running</span>'; } else { echo '<span class="daemon offline">Offline</span>'; } ?>
				<?php if (file_exists('/var/run/orion.imaging')) { echo '<span class="working">Imaging</span>'; } else if (file_exists('/var/run/orion.imaging.running')) { echo '<span class="working offline">Sleeping</span>'; } ?>
			</div>
			<div class="row">
				<label>Stacking daemon</label>
				<?php if (file_exists('/var/run/orion.stacking.running')) { echo '<span class="daemon">Running</span>'; } else { echo '<span class="daemon offline">Offline</span>'; } ?>
				<?php if (file_exists('/var/run/orion.stacking')) { echo '<span class="working">Stacking</span>'; } else if (file_exists('/var/run/orion.stacking.running')) { echo '<span class="working offline">Sleeping</span>'; } ?>
			</div>

			<h2>User</h2>
			<div class="row">
				<label>Email</label>
				<input type="email" name="user[email]" value="<?php echo $settings['user']['email']; ?>" placeholder="raspberry@pi.com" />
				<p><i>What email address to use for stacking image sharing (not stored on server).</i></p>
			</div>
			<div class="row">
				<label>URL</label>
				<input type="url" name="user[url]" value="<?php echo $settings['user']['url']; ?>" placeholder="http://orion.davidus.sk/process.php" />
				<p><i>Where to upload stacked image after processing.</i></p>
			</div>

			<h2>Storage</h2>
			<div class="row">
				<label>Temporary</label>
				<input type="text" name="storage[temp]" value="<?php echo $settings['storage']['temp']; ?>" placeholder="/tmp" />
				<p><i>Temporary directory holding all timelapse photos.</i></p>
			</div>
			<div class="row">
				<label>Final</label>
				<input type="text" name="storage[final]" value="<?php echo $settings['storage']['final']; ?>" placeholder="/home/user/photos" />
				<p><i>Final resting place for the stacked image.</i></p>
			</div>

			<h2>Location</h2>
			<div class="row">
				<label>Latitude</label>
				<input type="text" name="location[lat]" value="<?php echo $settings['location']['lat']; ?>" placeholder="30.2416795" />
				<p><i>Your latitude in decimal format.</i></p>
			</div>
			<div class="row">
				<label>Longitude</label>
				<input type="text" name="location[lon]" value="<?php echo $settings['location']['lon']; ?>" placeholder="-81.4622782" />
				<p><i>Your longitude in decimal format.</i></p>
			</div>
			<div class="row">
				<label>Altitude</label>
				<?php echo selectBox("location[alt]", array(
					'0' => '0&deg;',
					'-0.25' => '-0.25&deg;',
					'-0.583' => '-0.583&deg;',
					'-0.833' => '-0.833&deg;',
					'-6' => '-6&deg;',
					'-12' => '-12&deg;',
					'-15' => '-15&deg;',
					'-18' => '-18&deg;',
				), $settings['location']['alt']); ?>
			</div>

			<h2>Camera</h2>
			<div class="row">
				<label>Timelapse</label>
				<input type="number" name="camera[timelapse]" value="<?php echo $settings['camera']['timelapse']; ?>" placeholder="1000" required="required" />
				<p><i>Duration between images in milliseconds.</i></p>
			</div>
			<div class="row">
				<label>ISO</label>
				<?php echo selectBox("camera[iso]", array(
					'100' => '100',
					'200' => '200',
					'300' => '300',
					'400' => '400',
					'500' => '500',
					'600' => '600',
					'700' => '700',
					'800' => '800',
				), $settings['camera']['iso']); ?>
				<p><i>ISO sensitivity.</i></p>
			</div>
			<div class="row">
				<label>Exposure</label>
				<select name="camera[exposure]">
					<option value="auto" <?php echo $settings['camera']['exposure'] == 'auto' ? 'selected="selected"' : ''; ?>>auto - Use automatic exposure mode</option>
					<option value="night" <?php echo $settings['camera']['exposure'] == 'night' ? 'selected="selected"' : ''; ?>>night - Select setting for night shooting</option>
					<option value="nightpreview" <?php echo $settings['camera']['exposure'] == 'nightpreview' ? 'selected="selected"' : ''; ?>>nightpreview</option>
					<option value="backlight" <?php echo $settings['camera']['exposure'] == 'backlight' ? 'selected="selected"' : ''; ?>>backlight - Select setting for back lit subject</option>
					<option value="spotlight" <?php echo $settings['camera']['exposure'] == 'spotlight' ? 'selected="selected"' : ''; ?>>spotlight</option>
					<option value="sports" <?php echo $settings['camera']['exposure'] == 'sports' ? 'selected="selected"' : ''; ?>>sports - Select setting for sports (fast shutter etc)</option>
					<option value="snow" <?php echo $settings['camera']['exposure'] == 'snow' ? 'selected="selected"' : ''; ?>>snow - Select setting optimized for snowy scenery</option>
					<option value="beach" <?php echo $settings['camera']['exposure'] == 'beach' ? 'selected="selected"' : ''; ?>>beach - Select setting optimized for beach</option>
					<option value="verylong" <?php echo $settings['camera']['exposure'] == 'verylong' ? 'selected="selected"' : ''; ?>>verylong - Select setting for long exposures</option>
					<option value="fixedfps" <?php echo $settings['camera']['exposure'] == 'fixedfps' ? 'selected="selected"' : ''; ?>>fixedfps - Constrain fps to a fixed value</option>
					<option value="antishake" <?php echo $settings['camera']['exposure'] == 'antishake' ? 'selected="selected"' : ''; ?>>antishake - Antishake mode</option>
					<option value="fireworks" <?php echo $settings['camera']['exposure'] == 'fireworks' ? 'selected="selected"' : ''; ?>>fireworks - Select settings</option>
				</select>
			</div>
			<div class="row">
				<label>Shutter speed</label>
				<input type="number" name="camera[shutter_speed]" value="<?php echo $settings['camera']['shutter_speed']; ?>" placeholder="1000000" required="required" />
				<p><i>Camera shutter speed in microseconds.</i></p>
			</div>
			<div class="row">
				<label>JPEG quality</label>
				<input type="number" name="camera[quality]" value="<?php echo $settings['camera']['quality']; ?>" placeholder="80" max="100" min="0" required="required" />
				<p><i>JPEG image quality (value between 0 and 100).</i></p>
			</div>
			<div class="row">
				<label>Image width</label>
				<input type="number" name="camera[width]" value="<?php echo $settings['camera']['width']; ?>" placeholder="80" required="required" />
				<p><i>Image width in pixels.</i></p>
			</div>
			<div class="row">
				<label>Image height</label>
				<input type="number" name="camera[height]" value="<?php echo $settings['camera']['height']; ?>" placeholder="80" required="required" />
				<p><i>Image height in pixels.</i></p>
			</div>
			<div class="row submit">
				<input type="submit" name="submit" value="Save settings" />
			</div>
		</form>
	</div>
</body>
</html>
	  
