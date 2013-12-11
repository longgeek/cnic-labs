<?php
header('Content-type: text/plain'); 
require ('include/database.php');
require ('include/function.php');

$database =  new DataBase();
$machines = $database->select_machines();
$roles = $database->select_roles();

$items = Array();

foreach ($machines as $machine) {
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
	array_push($items, $item);
}

echo json_encode($items);



/*



$data = '
03
00-30-18-1A-2B-15
04
00-a9-za-fa-ds-00
05
';
06
$search = '/(?:[A-Fa-f0-9]{2}-){5}[A-Fa-f0-9]{2}/i';
07
preg_match_all($search, $data, $rr);
08
 
09
printf("<p>输出MAC地址数据为：</p><pre>%s</pre>\n",var_export( $rr ,TRUE));


*/