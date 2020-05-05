<?php
$obj = (object)[];
session_start();
if (isset($_GET['id'])) {
	$obj->ok = true;
	$id = $_GET['id'];
	if (isset($_SESSION[$id])) {
		$obj->status = 'overwritten';
	} else {
		$obj->status = 'new';
	}
	$_SESSION[$id] = true;
	$_SESSION[$id . "_flagged"] = false;
} else {
	$obj->ok = false;
}
$json = json_encode($obj);
echo $json;
?>
