<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" type="text/css" href="theme/style.css"/>
<script language="javascript" src="theme/jquery-1.10.2.min.js"></script>
<script language="javascript" src="theme/script.js"></script>
<title>ECCP 物理资源池管理</title>
</head>

<body>

<?php
require ('include/database.php');
require ('include/function.php');
?>

<div id="header">
<div class="frame">
    <div class="logo">ECCP 物理资源池管理</div>
</div>
</div>
      
<div id="navigator">
<div class="frame">
    <span><a href="./">首页</a></span>
    <span><a href="#" onclick="debug();" ><font color="#FF0000">DEBUG</font></a></span>
    <span><a href="output.php">测试输出</a></span>
</div>
</div>


<div id="bodyer">
<!-- BEIGIN BODYER_LEFT -->
<div id="bodyer_left">


<!-- BEIGIN TOOLBOX -->
<div class="toolbox">
<div class="toolbox_title">资源统计</div>
<div class="toolbox_block">

<table id="statscic_roles">
<tr><th width="220">服务名称</th><th>数量</th><th>状态</th></tr>
</table>

<p>
共有 <span id="statscic_machines_count">N/A</span> 台主机</p> <input id="deploy_button" type="button"  value="立即部署" onclick="action_deploy();" disabled="disabled" />
</div>
</div>
<!-- END TOOLBOX -->


<!-- BEIGIN TOOLBOX -->
<div class="toolbox">
<div class="toolbox_title">系统信息</div>
<div class="toolbox_block">
操作系统 <?php echo php_uname('s'); ?> <?php echo php_uname('r'); ?><br />
运行身份 <?php echo Get_Current_User(); ?><br />

</div>
</div>
<!-- END TOOLBOX -->


<!-- BEIGIN TOOLBOX -->
<div class="toolbox">
<div class="toolbox_title">添加机器</div>
<div class="toolbox_block">
<div class="machine_new">
<form id="form_machine_add">
<label>物理网卡</label> <input id="m_new_mac" name="address_physical" type="text" value=""  class="validator" validator='{"func":"validator_mac","result":{"false":"mac地址格式不正确！mac地址格式为XX:XX:XX:XX:XX:XX"}}' /><br />
<label>IPv4地址</label> <input type="text" name="address_ipv4" value="" class="validator" validator='{"func":"validator_ipv4","result":{"false":"格式不正确！"}}' /><br />
<label>主机名</label> <input type="text" name="hostname" value="" class="validator" validator='{"func":"validator_hostname","result":{"false":"不可以留空！"}}'/><br />
<br />
<label>远控卡地址</label> <input type="text" name="ipmi_hostname" value="" /><br />
<label>远控卡用户名</label> <input type="text" name="ipmi_username" value="" /><br />
<label>远控卡密码</label> <input type="text" name="ipmi_password" value="" /><br /><br />
</form>
<input type="button"  value="添加新机器" onclick="action_machine_add()" />
</div>
</div>
</div>
<!-- END TOOLBOX -->


</div>
<!-- END BODYER_LEFT -->
<div id="bodyer_right">
<div id="machines">
<?php

$database =  new DataBase();
$machines = $database->select_machines();
$roles = $database->select_roles();

foreach ($machines as $machine) {
	$item = Array();
	$item['power-type'] = 'ipmi';
	$item['power-address'] = $machine['ipmi_hostname'];
	$item['power-user'] = $machine['ipmi_username'];
	$item['power-pass'] = $machine['ipmi_password'];
	$item['type'] = $machine['roles'];
	
?>
<div class="machine" id="machine_<?php echo $machine['id'] ?>">
<div class="machine_title">物理机 #<?php echo $machine['id'] ?></div>
<div class="machine_content">
<div class="machine_basic">
<form id="form_machine_modify_<?php echo $machine['id'] ?>">
<input type="hidden" name="id_machine" value="<?php echo $machine['id'] ?>" />
<label>物理网卡</label> <input type="text" name="address_physical" value="<?php echo $machine['address_physical'] ?>" class="validator" validator='{"func":"validator_mac","result":{"false":"mac地址格式不正确！mac地址格式为XX:XX:XX:XX:XX:XX"}}' class="validator" validator='{"func":"validator_ipv4","result":{"false":"格式不正确！"}}'  /><br />
<label>IPv4地址</label> <input type="text" name="address_ipv4" value="<?php echo $machine['address_ipv4'] ?>" /><br />
<label>主机名</label> <input type="text" name="hostname" value="<?php echo $machine['hostname'] ?>" class="validator" validator='{"func":"validator_hostname","result":{"false":"不可以留空！"}}' /><br />
<br />
<label>远控卡地址</label> <input type="text" name="ipmi_hostname" value="<?php echo $machine['ipmi_hostname'] ?>" /><br />
<label>远控卡用户名</label> <input type="text" name="ipmi_username" value="<?php echo $machine['ipmi_username'] ?>" /><br />
<label>远控卡密码</label> <input type="text" name="ipmi_password" value="<?php echo $machine['ipmi_password'] ?>" /><br /><br />
</form>
<input type="button"  value="保存" onclick="action_machine_modify(<?php echo $machine['id'] ?>)" />
<input type="button"  value="删除" onclick="action_machine_del(<?php echo $machine['id'] ?>)" />
<input type="button"  value="部署" onclick="action_machine_deploy(<?php echo $machine['id'] ?>)" />
<!-- <input type="button"  value="重置" onclick="action_machine_reset(<?php echo $machine['id'] ?>)" /> -->
</div>
<div class="machine_roles">
<div id="m_<?php echo $machine['id'] ?>_roles" class="machine_list_roles">
</div>
<select class="m_roles_select" id="m_<?php echo $machine['id'] ?>_roles_select" onchange="ui_update_roles_select_onselect(<?php echo $machine['id'] ?>)">
<option class="m_roles_select_extra" value='-1'>请选择一个服务角色</option>
<?php foreach ($roles as $role) {
	?><option class="m_roles_select_option" value='<?php echo $role['id'] ?>'><?php echo $role['title'] ?></option><?php
} ?>
</select>
<input id="m_<?php echo $machine['id'] ?>_roles_add" disabled="disabled" type="button" value="添加" onclick="action_role_add(<?php echo $machine['id'] ?>); return false;" />
<script language="javascript">
ui_update_roles_of_machine(<?php echo $machine['id'] ?>);
</script>
</div>
</div>
</div>

<?php


}

?>

<script language="javascript">

$(document).ready(function() {
	ui_update_statscic();
	
	
	$(".machine_title").on("click", function (e) {
        if ($(this).hasClass("closed")) {
            $(this).next(".machine_content").slideDown(250);
            $(this).removeClass("closed");
        } else if (!$(this).hasClass("closed")) {
           $(this).addClass("closed");
           $(this).next(".machine_content").slideUp(250);
        }
    });
	
});

</script>


<?php

?>

</div>
</div>
</div>
     

<div id="footer">
<div class="frame">
	<span id="copyright">&copy; 北龙泽达（北京）数据科技有限公司 版权所有</span>
</div>
</div>
<div id="background"></div>
<div id="notice">
<div id="notice_title">111111111111111111</div>
<div id="notice_close" onclick="ui_notice_hide()">X</div>
<div id="notice_content">
<div id="notice_content_middile"></div>
</div>
</div>
</body>
</html>