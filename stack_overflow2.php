<?php
# This is my answer for http://stackoverflow.com/questions/18432914/convert-php-array-into-single-json-object/18433031#18433031
$foo = json_decode('[{"abc":"A123"},{"xyz":"B234"}]');
$bar = array();
foreach ($foo as $f) {
	foreach ($f as $k => $v) {
		$bar[$k] = $v;
	}
}

echo json_encode($foo)."\n";
echo json_encode($bar)."\n";
?>
