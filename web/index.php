<?php

$settings = false;
$file = dirname(__FILE__) . '/../data/settings.json';
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
  <meta name="robots" content="index,follow" />
  <meta name="google-site-verification" content="FPQzECfLnPDADF49UtsQYODlPybm5NsLP0haVlBTWYA" />

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
	  </div>
	  <div class="row">
		  <label>URL</label>
		  <input type="text" name="user[url]" value="<?php echo $settings['user']['url']; ?>" placeholder="http://somewhere.com" />
	  </div>

	  <h2>Storage</h2>
	  <div class="row">
		  <label>Temporary</label>
		  <input type="text" name="storage[temp]" value="<?php echo $settings['storage']['temp']; ?>" placeholder="/tmp" />
	  </div>
	  <div class="row">
		  <label>Final</label>
		  <input type="text" name="storage[final]" value="<?php echo $settings['storage']['final']; ?>" placeholder="/home/user/photos" />
	  </div>

	  <h2>Location</h2>
	  <div class="row">
		  <label>Latitude</label>
		  <input type="text" name="location[lat]" value="<?php echo $settings['location']['lat']; ?>" placeholder="30.2416795" />
	  </div>
	  <div class="row">
		  <label>Longitude</label>
		  <input type="text" name="location[lon]" value="<?php echo $settings['location']['lon']; ?>" placeholder="-81.4622782" />
	  </div>
	  <div class="row">
		  <label>Altitude</label>
		  <select name="location[alt]">
			  <option value="0">0&deg;</option>
			  <option value="-0.250">-0.250&deg;</option>
			  <option value="-0.583">-0.583&deg;</option>
			  <option value="-0.833">-0.833&deg;</option>
			  <option value="-6.000">-6&deg;</option>
			  <option value="-12">-12&deg;</option>
			  <option value="-15">-15&deg;</option>
			  <option value="-18">-18&deg;</option>
		  </select>
	  </div>

	  <h2>Camera</h2>
	  
  </form>
</body>
</html>
	  
