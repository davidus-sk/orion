<?php
# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Configuration form
#
# version 1.0 [2015-02-07]

$settings = false;
$file = dirname(__FILE__) . '/../data/settings.json';

if ($_POST['submit']) {
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

  <style type="text/css">
	  label {
		  display: block;
		  font-weight: bold;
		  padding-bottom: 5px;
	  }

	  input, select {
		  display: block;
		  padding: 5px;
		  border-radius: 5px;
		  border: 1px solid #ccc;
		  width: 80%;
	  }
	  
	  i {
		  display: block;
		  color: #ccc;
	  }

	  #wrapper {
		  font-family: Arial;
		  width: 800px;
		  margin: 20px auto 10px auto;
	  }

	  h1 {
		  border-bottom: 2px solid #ccc;
	  }

	  h2 {
		  padding: 2px 5px;
		  background: #eee;
		  border-bottom: 1px solid #ccc;
	  }

	  .row {
		  margin-bottom: 20px;
	  }

	  .daemon, .working {
		  display: inline-block;
		  padding: 2px 5px;
		  border-radius: 5px;
		  font-weight: bold;
	  }

	  .daemon {
		  background: #75D6FF;
		  color: #4985D6;
	  }

	  .working {
		  background: #0AFE47;
		  color: #2DC800;
	  }

	  .offline {
		  background: #ccc;
		  color: #aaa;
	  }
	  
	  .submit {
		  border-bottom: 2px solid #ccc;
		  padding-top: 20px;
	  }
  </style>

</head>
<body>
  <form id="wrapper" action="" method="post">
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
		  <input type="text" name="user[email]" value="<?php echo $settings['user']['email']; ?>" placeholder="raspberry@pi.com" />
		  <i>What email address to use for stacking image sharing (not stored on server).</i>
	  </div>
	  <div class="row">
		  <label>URL</label>
		  <input type="text" name="user[url]" value="<?php echo $settings['user']['url']; ?>" placeholder="http://orion.davidus.sk/process.php" />
		  <i>Where to upload stacked image after processing.</i>
	  </div>

	  <h2>Storage</h2>
	  <div class="row">
		  <label>Temporary</label>
		  <input type="text" name="storage[temp]" value="<?php echo $settings['storage']['temp']; ?>" placeholder="/tmp" />
		  <i>Temporary directory holding all timelapse photos.</i>
	  </div>
	  <div class="row">
		  <label>Final</label>
		  <input type="text" name="storage[final]" value="<?php echo $settings['storage']['final']; ?>" placeholder="/home/user/photos" />
		  <i>Final resting place for the stacked image.</i>
	  </div>

	  <h2>Location</h2>
	  <div class="row">
		  <label>Latitude</label>
		  <input type="text" name="location[lat]" value="<?php echo $settings['location']['lat']; ?>" placeholder="30.2416795" />
		  <i>Your latitude in decimal format.</i>
	  </div>
	  <div class="row">
		  <label>Longitude</label>
		  <input type="text" name="location[lon]" value="<?php echo $settings['location']['lon']; ?>" placeholder="-81.4622782" />
		  <i>Your longitude in decimal format.</i>
	  </div>
	  <div class="row">
		  <label>Altitude</label>
		  <select name="location[alt]">
			  <option value="0" <?php echo empty($settings['location']['alt']) ? 'selected="selected"' : ''; ?>>0&deg;</option>
			  <option value="-0.25" <?php echo $settings['location']['alt'] == -0.25 ? 'selected="selected"' : ''; ?>>-0.25&deg;</option>
			  <option value="-0.583" <?php echo $settings['location']['alt'] == -0.583 ? 'selected="selected"' : ''; ?>>-0.583&deg;</option>
			  <option value="-0.833" <?php echo $settings['location']['alt'] == -0.833 ? 'selected="selected"' : ''; ?>>-0.833&deg;</option>
			  <option value="-6" <?php echo $settings['location']['alt'] == -6 ? 'selected="selected"' : ''; ?>>-6&deg;</option>
			  <option value="-12" <?php echo $settings['location']['alt'] == -12 ? 'selected="selected"' : ''; ?>>-12&deg;</option>
			  <option value="-15" <?php echo $settings['location']['alt'] == -15 ? 'selected="selected"' : ''; ?>>-15&deg;</option>
			  <option value="-18" <?php echo $settings['location']['alt'] == -18 ? 'selected="selected"' : ''; ?>>-18&deg;</option>
		  </select>
	  </div>

	  <h2>Camera</h2>
	  <div class="row">
		  <label>Timelapse</label>
		  <input type="text" name="camera[timelapse]" value="<?php echo $settings['camera']['timelapse']; ?>" placeholder="1000" />
		  <i>Duration between images in milliseconds.</i>
	  </div>
	  <div class="row">
		  <label>ISO</label>
		  <select name="camera[iso]">
			  <option value="100" <?php echo $settings['camera']['exposure'] == '100' ? 'selected="selected"' : ''; ?>>100</option>
			  <option value="200" <?php echo $settings['camera']['exposure'] == '200' ? 'selected="selected"' : ''; ?>>200</option>
			  <option value="300" <?php echo $settings['camera']['exposure'] == '300' ? 'selected="selected"' : ''; ?>>300</option>
			  <option value="400" <?php echo $settings['camera']['exposure'] == '400' ? 'selected="selected"' : ''; ?>>400</option>
			  <option value="500" <?php echo $settings['camera']['exposure'] == '500' ? 'selected="selected"' : ''; ?>>500</option>
			  <option value="600" <?php echo $settings['camera']['exposure'] == '600' ? 'selected="selected"' : ''; ?>>600</option>
			  <option value="700" <?php echo $settings['camera']['exposure'] == '700' ? 'selected="selected"' : ''; ?>>700</option>
			  <option value="800" <?php echo $settings['camera']['exposure'] == '800' ? 'selected="selected"' : ''; ?>>800</option>
		  </select>
		  <i>ISO sensitivity.</i>
	  </div>
	  <div class="row">
		  <label>Exposure</label>
		  <select name="camera[timelapse]">
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
		  <i>Duration between images in milliseconds.</i>
	  </div>
	  <div class="row">
		  <label>Shutter speed</label>
		  <input type="text" name="camera[shutter_speed]" value="<?php echo $settings['camera']['shutter_speed']; ?>" placeholder="1000000" />
		  <i>Camera shutter speed in microseconds.</i>
	  </div>
	  <div class="row">
		  <label>JPEG quality</label>
		  <input type="text" name="camera[quality]" value="<?php echo $settings['camera']['quality']; ?>" placeholder="80" />
		  <i>JPEG image quality (value between 0 and 100).</i>
	  </div>
	  <div class="row">
		  <label>Image width</label>
		  <input type="text" name="camera[width]" value="<?php echo $settings['camera']['width']; ?>" placeholder="80" />
		  <i>Image width in pixels.</i>
	  </div>
	  <div class="row">
		  <label>Image height</label>
		  <input type="text" name="camera[height]" value="<?php echo $settings['camera']['height']; ?>" placeholder="80" />
		  <i>Image height in pixels.</i>
	  </div>
	  <div class="row submit">
		  <input type="submit" name="submit" value="Save settings" />
	  </div>
  </form>
</body>
</html>
	  
