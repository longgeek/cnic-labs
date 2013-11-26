<?php
header('Content-type: text/plain');

require ('include/database.php');
require ('include/function.php');


$fetch =  $_REQUEST['fetch'];
$func = 'fetch_'.$fetch;

$func();

function fetch_roles_of_machine () {
	$database =  new DataBase();
	$roles = $database->select_roles();
	$id_machine =  $_REQUEST['id_machine'];
	
	$machine = $database->select_machine_with_id($id_machine);
	
	//print_r($machine);
	
	$role_list = get_roles_from_machine_roles($roles, $machine['roles']);
	echo json_encode($role_list, true);
}


function fetch_machines () {
	$database =  new DataBase();
	$machines = $database->select_machines();
	$roles = $database->select_roles();
	$length =  count($machines);
	
	for($i=0; $i<$length; $i++) {
		$machines[$i]['roles'] = get_roles_from_machine_roles($roles, $machines[$i]['roles']);
	}
	
	echo json_encode($machines, true);
}

function fetch_roles () {
	$database =  new DataBase();
	$roles = $database->select_roles();
	echo json_encode($roles, true);
}

function fetch_status () {
	$database =  new DataBase();
	$key =  $_REQUEST['key'];
	$status = $database->select_status_with_key($key);
	echo $status['value'];
}