<?php
# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Stacked images gallery
#
# version 1.0 [2015-02-12]

// get all uploaded stacked files
$Directory = new RecursiveDirectoryIterator('images/');
$Iterator = new RecursiveIteratorIterator($Directory);
$Regex = new RegexIterator($Iterator, '/^.+\_thumb.jpg$/i', RecursiveRegexIterator::GET_MATCH);

// process them into an array
$files = array();

foreach($Regex as $name=>$object) {
	$mtime = filemtime($name);
	$files[$mtime][] =
		array(
			'thumb' => $name,
			'large' => str_replace('thumb', 'large', $name),
		);
}

// sort by timestamp
krsort($files)
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
	<style  type="text/css">
		/*site container*/
		.wrapper {
		  width: 900px;
		  margin: 0 auto;
		}

		.gallery:before, .gallery:after {
			content: " ";
			display: table;
		}

		.gallery:after {
			clear: both;
		}

		h1 {
		  padding: 30px 0px 10px 0px;
		  font: 25px Oswald;
		  color: #000;
		  text-transform: uppercase;
		  text-shadow: #ccc 0px 1px 5px;
		  margin: 0px 0px 30px 0px;
		  border-bottom: 2px solid #333;
		}

		.footer {
			padding: 10px 0px 30px 0px;
			font: 13px "Open Sans";
			color: #666;
			margin: 30px 0px 0px 0px;
			border-top: 2px solid #333;			
		}
		
		.footer a {
			color: #666;
		}

		.image {
			float: left;
			position: relative;
		}

		.image img {
			display: block;
		}
		
		.image .info {
			position: absolute;
			bottom: 0px;
			left: 0px;
			font: 13px "Open Sans";
			color: #fff;
			background: #000;
		}
	</style>
</head>
<body>
	<div class="wrapper">
		<h1>ORION</h1>

		<div class="gallery">
		<?php
		foreach ($files as $time=>$images) {
			foreach ($images as $key=>$image) {
		?>

		<div class="image">
			<a href="<?php echo $image['large']; ?>"><img src="<?php echo $image['thumb']; ?>" alt="" /></a>
			<div class="info"><?php echo date('Y-m-d', $time); ?></div>
		</div>

		<?php
			}
		}
		?>
		</div>

		<div class="footer">
			&copy; 2015 <a href="http://davidus.sk">davidus.sk</a>
		</div>
	</div>
</body>
</html>
