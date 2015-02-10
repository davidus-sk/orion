<?php
# ORION - Automated timelapse image capture and stacking for Raspberry Pi and the Pi camera
# (c) 2015 David Ponevac (david at davidus dot sk) www.davidus.sk
#
# Configuration form functions
#
# version 1.0 [2015-02-09]

/**
 * Render select box
 * 
 * @param string $name
 * @param array $options
 * @param string $selected
 * @return string
 */
function selectBox($name, $options, $selected) {
	$html = '<select name="' . $name . '">';
	foreach ($option as $key=>$value) {
		$html .= '<option value="' . $key . '" '. ($selected == $key ? 'selected="selected"' : '') . '>' . $value . '</option>';
	}
	$html .= '</select>';
	
	return $html;
}
?>
