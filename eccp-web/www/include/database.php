<?php

class DataBase {
	public $connction;
	
	function __construct() {
		try {
			$this->connction = new PDO('sqlite:data');
			$this->connction->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
		} catch (PDOException $e) {
			echo 'database connection failure: ' . $e->getMessage();
			die();
		}
	}
	
	function execute($sql) {
		$sth = $this->connction->prepare($sql);
		$sth->execute();
		return TRUE;
	}
	
	function fetch($sql) {
		$sth = $this->connction->prepare($sql);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
	
	function fetchAll($sql) {
		$sth = $this->connction->prepare($sql);
		$sth->execute();
		$result = $sth->fetchAll();
		return $result;
	}
	
	function select_machine_with_id($id) {
		$sth = $this->connction->prepare('SELECT * FROM `machine` WHERE `id` = :id;');
		$sth->bindParam(':id', $id, PDO::PARAM_STR);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
	
	function delete_machine_with_id($id) {
		$sth = $this->connction->prepare('DELETE FROM `machine` WHERE `id` = :id;');
		$sth->bindParam(':id', $id, PDO::PARAM_STR);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
	
	function select_machines() {
		$sth = $this->connction->prepare('SELECT * FROM `machine`');
		$sth->execute();
		$result = $sth->fetchAll();
		return $result;
	}
	
	function select_roles() {
		$sth = $this->connction->prepare('SELECT * FROM `role` ORDER BY `power`');
		$sth->execute();
		$result = $sth->fetchAll();
		return $result;
	}
	
	function select_role_with_id($id) {
		$sth = $this->connction->prepare('SELECT * FROM `role` WHERE `id` = :id;');
		$sth->bindParam(':id', $id, PDO::PARAM_STR);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
	
	function modify_machine_role_with_id($id, $roles) {
		$sth = $this->connction->prepare('UPDATE `machine` SET `roles` = :roles WHERE `id` = :id;');
		$sth->bindParam(':id', $id, PDO::PARAM_STR);
		$sth->bindParam(':roles', $roles, PDO::PARAM_STR);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
	
	function insert_machine($address_physical, $address_ipv4, $hostname, $ipmi_hostname, $ipmi_username, $ipmi_password) {
		$sth = $this->connction->prepare('INSERT INTO `machine` (`address_physical`,`address_ipv4`, `hostname`, `ipmi_hostname`, `ipmi_username`, `ipmi_password`) VALUES (:address_physical,:address_ipv4,:hostname,:ipmi_hostname,:ipmi_username,:ipmi_password);');
		$sth->bindParam(':address_physical', $address_physical, PDO::PARAM_STR);
		$sth->bindParam(':address_ipv4', $address_ipv4, PDO::PARAM_STR);
		$sth->bindParam(':hostname', $hostname, PDO::PARAM_STR);
		$sth->bindParam(':ipmi_hostname', $ipmi_hostname, PDO::PARAM_STR);
		$sth->bindParam(':ipmi_username', $ipmi_username, PDO::PARAM_STR);
		$sth->bindParam(':ipmi_password', $ipmi_password, PDO::PARAM_STR);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
	
	function update_machine($address_physical, $address_ipv4, $hostname, $ipmi_hostname, $ipmi_username, $ipmi_password, $id) {
		$sth = $this->connction->prepare('UPDATE `machine` SET `address_physical`=:address_physical,`address_ipv4`=:address_ipv4, `hostname`=:hostname, `ipmi_hostname`=:ipmi_hostname, `ipmi_username`=:ipmi_username, `ipmi_password`=:ipmi_password WHERE `id`=:id;');
		$sth->bindParam(':address_physical', $address_physical, PDO::PARAM_STR);
		$sth->bindParam(':address_ipv4', $address_ipv4, PDO::PARAM_STR);
		$sth->bindParam(':hostname', $hostname, PDO::PARAM_STR);
		$sth->bindParam(':ipmi_hostname', $ipmi_hostname, PDO::PARAM_STR);
		$sth->bindParam(':ipmi_username', $ipmi_username, PDO::PARAM_STR);
		$sth->bindParam(':ipmi_password', $ipmi_password, PDO::PARAM_STR);
		$sth->bindParam(':id', $id, PDO::PARAM_STR);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
	
	function select_status_with_key($key) {
		$sth = $this->connction->prepare('SELECT * FROM `status` WHERE `key` = :key;');
		$sth->bindParam(':key', $key, PDO::PARAM_STR);
		$sth->execute();
		$result = $sth->fetch();
		return $result;
	}
}