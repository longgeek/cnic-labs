<?php
header('Content-type: text/plain'); 
require ('include/database.php');
require ('include/function.php');


$action =  $_REQUEST['action'];
$func = 'action_'.$action;

$func();

function action_role_add () {
	$database =  new DataBase();
	$roles = $database->select_roles();
	$id_machine =  $_REQUEST['id_machine'];
	$id_role =  $_REQUEST['id_role'];
	
	$machine = $database->select_machine_with_id($id_machine);
	
	//print_r($machine);
	
	$role_list = get_roles_from_machine_roles($roles, $machine['roles']);
	print_r($role_list);
	
	
	$role = $database->select_role_with_id($id_role);
	
	$role_list = insert_role_into_role_list($role, $role_list);
	print_r($role_list);
	
	$str_roles =  get_rolestr_from_role_list($role_list);
	$database->modify_machine_role_with_id($id_machine, $str_roles);
}

function action_role_del () {
	$database =  new DataBase();
	$roles = $database->select_roles();
	$id_machine =  $_REQUEST['id_machine'];
	$id_role =  $_REQUEST['id_role'];
	
	$machine = $database->select_machine_with_id($id_machine);
	
	//print_r($machine);
	
	$role_list = get_roles_from_machine_roles($roles, $machine['roles']);
	print_r($role_list);
	
	
	$role = $database->select_role_with_id($id_role);
	
	$role_list = delete_role_from_role_list($role, $role_list);
	print_r($role_list);
	
	$str_roles =  get_rolestr_from_role_list($role_list);
	$database->modify_machine_role_with_id($id_machine, $str_roles);
}

/*
address_physical
address_ipv4
hostname
ipmi_hostname
ipmi_username
ipmi_password
*/

function action_machine_add () {
	$database =  new DataBase();
	$address_physical =  $_REQUEST['address_physical'];
	$address_ipv4 =  $_REQUEST['address_ipv4'];
	$hostname =  $_REQUEST['hostname'];
	$ipmi_hostname =  $_REQUEST['ipmi_hostname'];
	$ipmi_username =  $_REQUEST['ipmi_username'];
	$ipmi_password =  $_REQUEST['ipmi_password'];
	
	
	$address_physical = strtoupper($address_physical);
	$address_physical = str_replace ('-', ':', $address_physical);
	
	$machine = $database->insert_machine($address_physical, $address_ipv4, $hostname, $ipmi_hostname, $ipmi_username, $ipmi_password);
}

function action_machine_modify () {
	$database =  new DataBase();
	$address_physical =  $_REQUEST['address_physical'];
	$address_ipv4 =  $_REQUEST['address_ipv4'];
	$hostname =  $_REQUEST['hostname'];
	$ipmi_hostname =  $_REQUEST['ipmi_hostname'];
	$ipmi_username =  $_REQUEST['ipmi_username'];
	$ipmi_password =  $_REQUEST['ipmi_password'];
	
	$id_machine =  $_REQUEST['id_machine'];
	
	$address_physical = strtoupper($address_physical);
	$address_physical = str_replace ('-', ':', $address_physical);
	
	$machine = $database->update_machine($address_physical, $address_ipv4, $hostname, $ipmi_hostname, $ipmi_username, $ipmi_password, $id_machine);
}



function generate_input_item_of_machine($machine, $roles) {
	
	$item = Array();
	$item['ip'] = $machine['address_ipv4'];
	$item['hostname'] = $machine['hostname'];
	$item['mac'] = str_replace('-', ':', $machine['address_physical']);
	$item['power-type'] = 'ipmi';
	$item['power-address'] = $machine['ipmi_hostname'];
	$item['power-user'] = $machine['ipmi_username'];
	$item['power-pass'] = $machine['ipmi_password'];
	$item['type'] = array();
	
	$role_list = get_roles_from_machine_roles($roles, $machine['roles']);

	foreach ($role_list as $role_temp) {
		array_push($item['type'], $role_temp['name']);
	}
	
	return $item;
}

function action_machine_deploy () {
	
	$database =  new DataBase();
	$id_machine =  $_REQUEST['id_machine'];
	$machine = $database->select_machine_with_id($id_machine);
	$roles = $database->select_roles();
	
	$items = Array();
	
		$item = generate_input_item_of_machine($machine, $roles);
		array_push($items, $item);
	
	$json_result =  json_encode($items);
	$str = 'python "/usr/bin/addnodes.py" \''.$json_result.'\'';

	exec('sudo -u root -S '.$str, $res, $rc);
	//exec('python test.py', $res, $rc);
	$count_line = count($res);
	if($count_line == 0) {
		echo '{"return": 0, "type": 0}';
	} else {
		echo $res[$count_line -1];
	}
}

function action_machine_del () {
	
	$database =  new DataBase();
	$id_machine =  $_REQUEST['id_machine'];
	$machine = $database->select_machine_with_id($id_machine);
	$roles = $database->select_roles();
	
	$items = Array();
	
		$item = generate_input_item_of_machine($machine, $roles);
		array_push($items, $item);
	
	$json_result =  json_encode($items);
	$str = 'python "/usr/bin/delnodes.py" \''.$json_result.'\'';

	//exec('sudo -u root -S '.$str, $res, $rc);
	//exec('python test.py', $res, $rc);
	//print_r($res);
	//echo $rc;
	
	
	
	$database =  new DataBase();
	$id_machine =  $_REQUEST['id_machine'];
	$database->delete_machine_with_id($id_machine);
	
	echo '{"return":1}';
}

function action_deploy () {
	
	$database =  new DataBase();
	$machines = $database->select_machines();
	$roles = $database->select_roles();
	
	$items = Array();
	
	foreach ($machines as $machine) {
		$item = generate_input_item_of_machine($machine, $roles);
		array_push($items, $item);
	}
	
	$json_result =  json_encode($items);
	$str = 'python "/usr/bin/addnodes.py" \''.$json_result.'\'';
	echo $str."\r\n";
	exec('sudo -u root -S '.$str, $res, $rc);
	//exec('python test.py', $res, $rc);
	print_r($res);
	echo $rc;
}


