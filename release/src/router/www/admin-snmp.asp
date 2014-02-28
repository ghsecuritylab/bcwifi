<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2007-2011 Shibby
	http://openlinksys.info
	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 系统管理: SNMP设置</title>

<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/bootstrap.css'>
<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/new.css'>








 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='http://dev.plat.gionee.com/static/bootstrap.js'></script>
<style type='text/css'>
textarea {
 width: 98%;
 height: 15em;
}
</style>
<script type='text/javascript'>
//	<% nvram("snmp_enable,snmp_port,snmp_remote,snmp_remote_sip,snmp_location,snmp_contact,snmp_ro"); %>

function verifyFields(focused, quiet)
{
	var ok = 1;

	var a = E('_f_snmp_enable').checked;

	E('_snmp_port').disabled = !a;
	E('_f_snmp_remote').disabled = !a;
	E('_snmp_remote_sip').disabled = !a;
	E('_snmp_location').disabled = !a;
	E('_snmp_contact').disabled = !a;
	E('_snmp_ro').disabled = !a;
	E('_snmp_remote_sip').disabled = (!a || !E('_f_snmp_remote').checked);

	return ok;
}

function save()
{
  if (verifyFields(null, 0)==0) return;
  var fom = E('_fom');
  fom.snmp_enable.value = E('_f_snmp_enable').checked ? 1 : 0;
  fom.snmp_remote.value = E('_f_snmp_remote').checked ? 1 : 0;

  if (fom.snmp_enable.value == 0) {
  	fom._service.value = 'snmp-stop';
  }
  else {
  	fom._service.value = 'snmp-restart,firewall-restart'; 
  }
  form.submit('_fom', 1);
}

function init()
{
}
</script>
</head>

<body onLoad="init()">
<table id='container' cellspacing=0 class="table">

<tr id='body'>
<td id='content'>

<div class='section-title'>SNMP 设置</div>
<div class='section' id='config-section'>
<form id='_fom' method='post' action='tomato.cgi'>
<input type='hidden' name='_nextpage' value='admin-snmp.asp'>
<input type='hidden' name='_service' value='snmp-restart,firewall-restart'>
<input type='hidden' name='snmp_enable'>
<input type='hidden' name='snmp_remote'>

<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用SNMP', name: 'f_snmp_enable', type: 'checkbox', value: nvram.snmp_enable == '1' },
	null,
	{ title: '远程访问端口', name: 'snmp_port', type: 'text', maxlen: 5, size: 7, value: fixPort(nvram.snmp_port, 161) },
	{ title: '远程访问', indent: 2, name: 'f_snmp_remote', type: 'checkbox', value: nvram.snmp_remote == '1' },
	{ title: '允许远程管理的IP地址', indent: 2, name: 'snmp_remote_sip', type: 'text', maxlen: 512, size: 64, value: nvram.snmp_remote_sip,
			suffix: '<br><small>("空白" 不限制,可单一IP或范围;例: "1.1.1.1", "1.1.1.0/24", "1.1.1.1 - 2.2.2.2" or "me.example.com")</small>' },
	null,
	{ title: '主机名称', indent: 2, name: 'snmp_location', type: 'text', maxlen: 40, size: 64, value: nvram.snmp_location },
	{ title: '联系方式', indent: 2, name: 'snmp_contact', type: 'text', maxlen: 40, size: 64, value: nvram.snmp_contact },
	{ title: '所在社区', indent: 2, name: 'snmp_ro', type: 'text', maxlen: 40, size: 64, value: nvram.snmp_ro }
]);
</script>
</div>
</form>
</div>
</td></tr>
<tr><td id='footer' colspan=2>
 <form>
 <span id='footer-msg'></span>
 <input type='button' value='保存设置' id='save-button' onclick='save()'>
 <input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
 </form>
</div>
</td></tr>
</table>
<script type='text/javascript'>verifyFields(null, 1);</script>



</body>
</html>
