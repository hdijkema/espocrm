<?php
#  vi: set sw=4 ts=4:  

session_start();

$flagged = array();

foreach($_SESSION as $id => $value) {
	$idx = strpos($id, '_flagged');
	if ($idx > 0) {
		if ($_SESSION[$id]) {
			$_SESSION[$id] = false;
			array_push($flagged, substr($id, 0, $idx));
		}
	}
}

$obj = (object)[];
$obj->flagged = $flagged;
$obj->n_flagged = count($flagged);

$json = json_encode($obj);

echo $json;
?>
