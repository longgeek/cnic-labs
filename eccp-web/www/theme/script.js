// JavaScript Document

var global_machines;
var global_roles;
var global_statscic = {};

String.prototype.replaceAll = function(s1,s2){   
	var r = new RegExp(s1.replace(/([\(\)\[\]\{\}\^\$\+\-\*\?\.\"\'\|\/\\])/g,"\\$1"),"ig");
	return this.replace(r,s2);
}
$.fn.serializeObject = function()
{
   var o = {};
   var a = this.serializeArray();
   $.each(a, function() {
       if (o[this.name]) {
           if (!o[this.name].push) {
               o[this.name] = [o[this.name]];
           }
           o[this.name].push(this.value || '');
       } else {
           o[this.name] = this.value || '';
       }
   });
   return o;
};

function action_error() {
	alert("出现网络错误，请刷新重试。");
}

function action_role_add(id_machine) {
	id_role = $("#m_" + id_machine + "_roles_select").val()
	var jqxhr = $.get("action.php?action=role_add", { "id_machine": id_machine, "id_role": id_role }, function(data) {
		ui_update_roles_of_machine(id_machine);
		ui_update_statscic_machines();
	})
	.fail(function() { action_error() })
}

function action_role_del(id_machine, id_role) {
	var jqxhr = $.get("action.php?action=role_del", { "id_machine": id_machine, "id_role": id_role }, function(data) {
		ui_update_roles_of_machine(id_machine);
		ui_update_statscic_machines();
	})
	.fail(function() { action_error() })
}

function action_machine_add() {
	data = $('#form_machine_add').serializeObject();
	
	if (!validator_duplicate(data.address_physical, data.address_ipv4, data.hostname, null)) {
		alert('MAC地址、IP地址或者主机名有重复，请检查。');
		return false;
	}
	if (!validator('form_machine_add')) return false;

	var jqxhr = $.post("action.php?action=machine_add", data, function(data) {
		window.location.reload();
	})
	.fail(function() { action_error() })
}

function action_machine_del(id_machine) {
	ui_notice_show_loading()
	ui_notice_show ('删除');
	var jqxhr = $.get("action.php?action=machine_del",  { "id_machine": id_machine }, function(data) {
		result = $.parseJSON(data);
		if (result.return==1) {
			ui_notice_show_message('删除成功，注意，已经服务器上的程序和数据保持不变，请自行删除。')
		}
		//window.location.reload();
	})
	.fail(function() { action_error() })
}


function action_machine_reset(id_machine) {
	ui_notice_show_loading()
	ui_notice_show ('重置');
	var jqxhr = $.get("action.php?action=machine_reset",  { "id_machine": id_machine }, function(data) {
		result = $.parseJSON(data);
		if (result.return==1) {
			ui_notice_show_message('重置成功')
		}
	})
	.fail(function() { action_error() })
}


function action_machine_deploy(id_machine) {
	ui_notice_show_loading()
	ui_notice_show ('部署');
	
	var jqxhr = $.get("action.php?action=machine_deploy",  { "id_machine": id_machine }, function(data) {
		result = $.parseJSON(data);
		if (result.return==1) {
			ui_notice_show_message('部署成功')
		}
	})
	.fail(function() { action_error() })
}

function action_machine_modify(id_machine) {
	data = $('#form_machine_modify_' + id_machine).serializeObject();
	
	if (!validator_duplicate(data.address_physical, data.address_ipv4, data.hostname, id_machine)) {
		alert('MAC地址、IP地址或者主机名有重复，请检查。');
		return false;
	}
	if (!validator('form_machine_modify_' + id_machine)) return false;
	
	
	var jqxhr = $.get("action.php?action=machine_modify",  data, function(data) {
		window.location.reload();
	})
	.fail(function() { action_error() })
}




function action_deploy() {
	ui_notice_show_loading()
	ui_notice_show ('全部部署');
	
	var jqxhr = $.get("action.php?action=deploy",  { }, function(data) {
		result = $.parseJSON(data);
		if (result.return==1) {
			ui_notice_show_message('部署成功')
		}
	})
	.fail(function() { action_error() })
}


function ui_update_roles_of_machine(id_machine) {
	var jqxhr = $.getJSON("fetch.php?fetch=roles_of_machine", { "id_machine": id_machine}, function(data) {
		length = data.length;
		result = '';
		
		for (i=0; i<length; i++) {
			result += '<div class="machine_role"><span>' + data[i].title + '</span><input type="button" value="删除"  onclick="action_role_del ( ' + id_machine + ', ' + data[i].id + '); return false;" /></div>'
		}
		 
		  $('#m_' + id_machine + '_roles').html(result);
	})
	.fail(function() { action_error() })
}

function ui_update_roles_select_onselect (id_machine) {
	id_role = $("#m_" + id_machine + "_roles_select").val();
	if (id_role != -1) {
		$('#m_' + id_machine + '_roles_add').removeAttr('disabled');
	} else {
		$('#m_' + id_machine + '_roles_add').attr('disabled','disabled');
	}
}

function ui_update_roles_select () {
	$('.m_roles_select_option').attr('disabled','disabled');
	
	length_machines = global_machines.length;
	length_roles = global_roles.length;
	for (k=0; k< length_roles; k++) {
		count_temp = 0;
	
		for (i=0; i< length_machines; i++) {
			for (j=0; j< global_machines[i].roles.length; j++) {
				if (global_machines[i].roles[j].name==global_roles[k].name) {
					count_temp ++;
				}
			}
		}
		status = '正常';
		if ((global_roles[k].flag_unique == 1 && count_temp == 0) || (global_roles[k].flag_unique == 0)) {
			$('.m_roles_select > option[value="' + global_roles[k].id + '"]').removeAttr('disabled');
		}
	}
	
	for (i=0; i< length_machines; i++) {
		id_machine = global_machines[i].id;
		roles_select = $('#m_' + id_machine + '_roles_select');
		for (j=0; j< global_machines[i].roles.length; j++) {
			$('#m_' + id_machine + '_roles_select > option[value="' + global_machines[i].roles[j].id + '"]').attr('disabled','disabled');
			if (global_machines[i].roles[j].flag_exclusive == 1) {
				$('#m_' + id_machine + '_roles_select > .m_roles_select_option').attr('disabled','disabled');
			}
			
			for (k=0; k< length_roles; k++) {
				if (global_roles[k].flag_exclusive == 1) {
					$('#m_' + id_machine + '_roles_select > option[value="' + global_roles[k].id + '"]').attr('disabled','disabled');
				}
			}
		}
	}
}

function ui_notice_show(title) {
	$('#notice_title').text(title);
	$('#notice').animate({top:"0", opacity: 0},0).show();
	$('#background').fadeTo(500, 0.75);
    $('#notice').animate({top:"40%", opacity: 1},500);
}

function ui_notice_hide() {
	$('#background').fadeTo(500, 0, function() {$('#background').hide()});
    $('#notice').animate({top:"0", opacity: 0},500);
}

function ui_notice_show_loading() {
	$('#notice_content_middile').show();
    $('#notice_content_middile').html('<img src="theme/loading.gif" />');
}

function ui_notice_show_message(message) {
	$('#notice_content_middile').show();
    $('#notice_content_middile').html(message);
}


function ui_update_statscic () {
	ui_update_statscic_roles();
	ui_update_statscic_machines();
}

function ui_update_statscic_roles() {
	var jqxhr = $.getJSON("fetch.php?fetch=roles", {}, function(data) {
		length = data.length;
		global_roles = data;
	})
	.fail(function() { action_error() })
}

function data_get_roles_by_id(id, roles) {
	for (i=0; i< roles.length; i++) {
		if (roles[i].id == id) {
			return roles[i];
		}
	}
	return null;
}

function ui_update_statscic_machines() {
	
	$('.statscic_roles_line').remove();
	
	var jqxhr = $.getJSON("fetch.php?fetch=machines", {}, function(data) {
		length = data.length;
		global_machines = data;
		
		deploy_available = true;
		
		length_roles = global_roles.length;
		for (k=0; k< length_roles; k++) {
			count_temp = 0;
		
			for (i=0; i< length; i++) {
				for (j=0; j< data[i].roles.length; j++) {
					if (data[i].roles[j].name==global_roles[k].name) {
						count_temp ++;
					}
				}
			}
			
			status = '正常';
			
			if ((global_roles[k].flag_unique == 1) && count_temp > 1) {
				status = '<font color="red"><b>超量</b></font>';
				deploy_available = false;
			}
			
			if ((global_roles[k].flag_required == 1) && count_temp < 1) {
				status = '<font color="red"><b>缺失</b></font>';
				deploy_available = false;
			}
			
			$('#statscic_roles').append('<tr class="statscic_roles_line"><td><b>' + global_roles[k].title + '</b></td><td>' + count_temp + '</td><td>' + status + '</td></tr>');
			
		}
		
		$('#statscic_machines_count').html(length);
		
		
		if (deploy_available) {
			$('#deploy_button').removeAttr('disabled');
		} else {
			$('#deploy_button').attr('disabled','disabled');
		}
		
		ui_update_roles_select ();
		
	})
	.fail(function() { action_error() })
}

function validator(formid) {
	count = 0;
	$('#' + formid + ' .validator').each(function(index, element) {
		validator_data = $.parseJSON(element.attributes.validator.value);
        result = eval(validator_data.func+"('" + element.value + "')");
		
		if (result == true) return true;
		else {
			count ++;
			 $.each(validator_data.result ,function(key){
				 if (key == result) alert(validator_data.result[key]);
            });
		}
    });
	
	if (count == 0) return true;
	else return false;
}

function validator_duplicate (mac, ipv4, hostname, except) {
	
	duplicate = false;
	
	$.each(global_machines, function(index, machine) {
		if (except != machine['id'] && machine['address_physical'] == mac) duplicate = true;
		if (except != machine['id'] && machine['address_ipv4'] == ipv4) duplicate = true;
		if (except != machine['id'] && machine['hostname'] == hostname) duplicate = true;
	});
	
	return !duplicate;
}


function validator_mac(value) {
	value = value.replaceAll('-', ':'); 
	var reg_name=/^[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}:[A-F\d]{2}$/;  
	if(!reg_name.test(value.toUpperCase())){  
		return 'false';  
	} 
	return true;
}

function validator_ipv4(value) {
	var reg_name=/^((25[0-5]|2[0-4]\d|[0-1]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[0-1]?\d\d?)$/;  
	if(!reg_name.test(value.toUpperCase())){  
		return 'false';  
	} 
	return true;
}

function validator_hostname(value) {
	var reg_name=/^.*$/;  
	if(!reg_name.test(value.toUpperCase())){  
		return 'false';  
	} 
	return true;
}

function test() {
	alert("test");  
}

function debug() {
	ui_notice_show_loading()
	ui_notice_show ('debug');
}

