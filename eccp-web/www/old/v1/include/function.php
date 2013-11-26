<?php


function get_roles_from_machine_roles($roles, $str_roles) {
	$role_list = explode(',',$str_roles);
	
	$roles_result = array();
	
	foreach ($roles as $role) {
		$role_temp = NULL;
		foreach ($role_list as $role_id) {
			if ($role_id == $role['id']) {
				$role_temp = $role;
			}
		}
		if ($role_temp != NULL) {
			array_push($roles_result, $role);
		}
	}
	
	return $roles_result;
}

function insert_role_into_role_list($role, $role_list) {
	$count = count($role_list);
	
	for($i=0; $i<$count; $i++) {
		if ($role_list[$i]['id'] == $role['id']) {
			return $role_list;
		}
	}
	
	$role_result = array();
	$position = $count;
	
	for($i=0; $i<$count; $i++) {
		if ($role_list[$i]['power'] > $role['power']) {
			$position = $i;
			break;
		}
	}
	
	
	$role_result = array_splice ($role_list, 0, $position);
	array_push($role_result, $role);
	$role_list = array_merge ($role_result, $role_list);
	
	
	return $role_list;
}

function delete_role_from_role_list($role, $role_list) {
	$count = count($role_list);
	$role_result = array();
	for($i=0; $i<$count; $i++) {
		if ($role_list[$i]['id'] != $role['id']) {
			array_push($role_result, $role_list[$i]);
		}
	}
	
	return $role_result;
}

function get_rolestr_from_role_list($role_list) {
	$count = count($role_list);
	if($count<1) return '';
	
	$str_roles = '';
	for($i=0; $i<$count-1; $i++) {
		$str_roles .= $role_list[$i]['id'].',';
	}
	
	$str_roles .= $role_list[$count-1]['id'];
	return $str_roles;
}