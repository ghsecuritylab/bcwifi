<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato RAF Transmission GUI
	Copyright (C) 2007-2011 Shibby
	http://openlinksys.info
	For use with Tomato RAF Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] Nas: BT客户端</title>

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
//	<% nvram("bt_enable,bt_binary,bt_binary_custom,bt_custom,bt_port,bt_dir,bt_settings,bt_settings_custom,bt_incomplete,bt_rpc_enable,bt_rpc_wan,bt_auth,bt_login,bt_password,bt_port_gui,bt_dl_enable,bt_dl,bt_ul_enable,bt_ul,bt_peer_limit_global,bt_peer_limit_per_torrent,bt_ul_slot_per_torrent,bt_ratio_enable,bt_ratio,bt_ratio_idle_enable,bt_ratio_idle,bt_dht,bt_pex,bt_lpd,bt_utp,bt_blocklist,bt_blocklist_url,bt_sleep,bt_check,bt_check_time,bt_dl_queue_enable,bt_dl_queue_size,bt_ul_queue_enable,bt_ul_queue_size,bt_message"); %>

var btgui_link = '&nbsp;&nbsp;<a href="http://' + location.hostname +':<% nv('bt_port_gui'); %>" target="_blank"><i>[点击这里打开传输界面]</i></a>';

function verifyFields(focused, quiet)
{
	var ok = 1;

	var a = E('_f_bt_enable').checked;
	var c = E('_f_bt_rpc_enable').checked;
	var d = E('_f_bt_dl_enable').checked;
	var e = E('_f_bt_ul_enable').checked;
	var g = E('_f_bt_ratio_enable').checked;
	var h = E('_f_bt_auth').checked;
	var i = E('_f_bt_blocklist').checked;
	var k = E('_f_bt_dl_queue_enable').checked;
	var l = E('_f_bt_ul_queue_enable').checked;
	var m = E('_f_bt_check').checked;
	var n = E('_f_bt_ratio_idle_enable').checked;

	E('_bt_custom').disabled = !a;
	E('_bt_binary').disabled = !a;
	E('_bt_dir').disabled = !a;
	E('_bt_port').disabled = !a;
	E('_bt_sleep').disabled = !a;
	E('_f_bt_incomplete').disabled = !a;
	E('_f_bt_check').disabled = !a;
	E('_bt_check_time').disabled = !a || !m;
	E('_bt_settings').disabled = !a;
	E('_f_bt_rpc_enable').disabled = !a;
	E('_bt_port_gui').disabled = !a || !c;
	E('_f_bt_auth').disabled = !a || !c;
	E('_bt_login').disabled = !a || !c || !h;
	E('_bt_password').disabled = !a || !c | !h;
	E('_f_bt_rpc_wan').disabled = !a || !c || !h;
	E('_f_bt_dl_enable').disabled = !a;
	E('_bt_dl').disabled = !a || !d;
	E('_f_bt_ul_enable').disabled = !a;
	E('_bt_ul').disabled = !a || !e;
	E('_bt_peer_limit_global').disabled = !a;
	E('_bt_peer_limit_per_torrent').disabled = !a;
	E('_bt_ul_slot_per_torrent').disabled = !a;
	E('_f_bt_ratio_enable').disabled = !a;
	E('_bt_ratio').disabled = !a || !g;
	E('_f_bt_ratio_idle_enable').disabled = !a;
	E('_bt_ratio_idle').disabled = !a || !n;
	E('_f_bt_dht').disabled = !a;
	E('_f_bt_pex').disabled = !a;
	E('_f_bt_lpd').disabled = !a;
	E('_f_bt_utp').disabled = !a;
	E('_f_bt_blocklist').disabled = !a;
	E('_bt_blocklist_url').disabled = !a || !i;
	E('_f_bt_dl_queue_enable').disabled = !a;
	E('_bt_dl_queue_size').disabled = !a || !k;
	E('_f_bt_ul_queue_enable').disabled = !a;
	E('_bt_ul_queue_size').disabled = !a || !l;
	E('_bt_message').disabled = !a;

	var o = (E('_bt_settings').value == 'custom');
	elem.display('_bt_settings_custom', o && a);

	var p = (E('_bt_binary').value == 'custom');
	elem.display('_bt_binary_custom', p && a);

	if (!v_length('_bt_custom', quiet, 0, 2048)) ok = 0;

	var s = E('_bt_custom');
	if (s.value.search(/"rpc-enable":/) == 0)  {
		ferror.set(s, '“RPC启用”选项，在这里无法设置。你可以将它设置在Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"peer-port":/) == 0)  {
		ferror.set(s, '不能设置“同行端口”选项。你可以将它设置在', quiet);
		ok = 0; }

	if (s.value.search(/"speed-limit-down-enabled":/) == 0)  {
		ferror.set(s, '“速度跌停启用”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"speed-limit-up-enabled":/) == 0)  {
		ferror.set(s, '不能设置“限速功能”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"speed-limit-down":/) == 0)  {
		ferror.set(s, '不能设置“限速减”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"speed-limit-up":/) == 0)  {
		ferror.set(s, '不能设置“速度极限”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"rpc-port":/) == 0)  {
		ferror.set(s, '“RPC端口”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"rpc-whitelist-enabled":/) == 0)  {
		ferror.set(s, '不能设置“RPC启用白名单”选项。始终禁用白名单', quiet);
		ok = 0; }

	if (s.value.search(/"rpc-username":/) == 0)  {
		ferror.set(s, '不能设置“RPC用户名”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"rpc-password":/) == 0)  {
		ferror.set(s, '不能设置“RPC密码”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"download-dir":/) == 0)  {
		ferror.set(s, '不能设置“下载目录”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"incomplete-dir-enabled":/) == 0)  {
		ferror.set(s, '“不完整的目录启用”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"incomplete-dir":/) == 0)  {
		ferror.set(s, '“不完全目录”选项，在这里无法设置。如果不完整的目录启用时，所有未完成的文件将被下载到“/ download_dir/.incomplete的”目录。', quiet);
		ok = 0; }

	if (s.value.search(/"peer-limit-global":/) == 0)  {
		ferror.set(s, '不能设定“限制对全局”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"peer-limit-per-torrent":/) == 0)  {
		ferror.set(s, '不能设定“peer-limit-per-torrent”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"upload-slots-per-torrent":/) == 0)  {
		ferror.set(s, '不能设置“upload-slots-per-torrent”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"dht-enabled":/) == 0)  {
		ferror.set(s, '“DHT-启用”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"pex-enabled":/) == 0)  {
		ferror.set(s, '“PEX-启用”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"lpd-enabled":/) == 0)  {
		ferror.set(s, '“LPD启用”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"utp-enabled":/) == 0)  {
		ferror.set(s, '不能设置“UTP-启用”选项，在这里。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"ratio-limit-enabled":/) == 0)  {
		ferror.set(s, '不能设置“的比例限制，启用”选项，在这里。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"ratio-limit":/) == 0)  {
		ferror.set(s, '不能设置“ratio-limit”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"rpc-authentication-required":/) == 0)  {
		ferror.set(s, '不能设置“RPC需要验证”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"blocklist-enabled":/) == 0)  {
		ferror.set(s, '无法设置“阻止列表功能”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"blocklist-url":/) == 0)  {
		ferror.set(s, '不能设置“阻止列表URL”选项，在这里。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"download-queue-enabled":/) == 0)  {
		ferror.set(s, '不能设置“启用下载队列”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"download-queue-size":/) == 0)  {
		ferror.set(s, '不能设置“下载队列大小”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"seed-queue-enabled":/) == 0)  {
		ferror.set(s, '“种子队列启用”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"seed-queue-size":/) == 0)  {
		ferror.set(s, '“种子队列大小”选项，在这里无法设置。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"idle-seeding-limit-enabled":/) == 0)  {
		ferror.set(s, '不能设置“空闲播种限制功能”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"idle-seeding-limit":/) == 0)  {
		ferror.set(s, '不能设置“空闲播种限制”选项。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	if (s.value.search(/"message-level":/) == 0)  {
		ferror.set(s, '不能设置“消息”选项，在这里。你可以将它设置在 Tomato GUI', quiet);
		ok = 0; }

	return ok;
}

function save()
{
  if (verifyFields(null, 0)==0) return;
  var fom = E('_fom');
  fom.bt_enable.value = E('_f_bt_enable').checked ? 1 : 0;
  fom.bt_incomplete.value = E('_f_bt_incomplete').checked ? 1 : 0;
  fom.bt_check.value = E('_f_bt_check').checked ? 1 : 0;
  fom.bt_rpc_enable.value = E('_f_bt_rpc_enable').checked ? 1 : 0;
  fom.bt_auth.value = E('_f_bt_auth').checked ? 1 : 0;
  fom.bt_rpc_wan.value = E('_f_bt_rpc_wan').checked ? 1 : 0;
  fom.bt_dl_enable.value = E('_f_bt_dl_enable').checked ? 1 : 0;
  fom.bt_ul_enable.value = E('_f_bt_ul_enable').checked ? 1 : 0;
  fom.bt_ratio_enable.value = E('_f_bt_ratio_enable').checked ? 1 : 0;
  fom.bt_ratio_idle_enable.value = E('_f_bt_ratio_idle_enable').checked ? 1 : 0;
  fom.bt_dht.value = E('_f_bt_dht').checked ? 1 : 0;
  fom.bt_pex.value = E('_f_bt_pex').checked ? 1 : 0;
  fom.bt_lpd.value = E('_f_bt_lpd').checked ? 1 : 0;
  fom.bt_utp.value = E('_f_bt_utp').checked ? 1 : 0;
  fom.bt_blocklist.value = E('_f_bt_blocklist').checked ? 1 : 0;
  fom.bt_dl_queue_enable.value = E('_f_bt_dl_queue_enable').checked ? 1 : 0;
  fom.bt_ul_queue_enable.value = E('_f_bt_ul_queue_enable').checked ? 1 : 0;

  if (fom.bt_enable.value == 0) {
  	fom._service.value = 'bittorrent-stop';
  }
  else {
  	fom._service.value = 'bittorrent-restart'; 
  }
	form.submit('_fom', 1);
}

function init()
{
}
</script>
</head>

<body onLoad="init()">
<table id='container' cellspacing=0>

<tr id='body'>
<td id='content'>

<div class='section-title'>基本设置</div>
<div class='section' id='config-section'>
<form id='_fom' method='post' action='tomato.cgi'>
<input type='hidden' name='_nextpage' value='nas-bittorrent.asp'>
<input type='hidden' name='_service' value='bittorrent-restart'>
<input type='hidden' name='bt_enable'>
<input type='hidden' name='bt_incomplete'>
<input type='hidden' name='bt_check'>
<input type='hidden' name='bt_rpc_enable'>
<input type='hidden' name='bt_auth'>
<input type='hidden' name='bt_rpc_wan'>
<input type='hidden' name='bt_dl_enable'>
<input type='hidden' name='bt_ul_enable'>
<input type='hidden' name='bt_blocklist'>
<input type='hidden' name='bt_ratio_enable'>
<input type='hidden' name='bt_ratio_idle_enable'>
<input type='hidden' name='bt_dht'>
<input type='hidden' name='bt_pex'>
<input type='hidden' name='bt_lpd'>
<input type='hidden' name='bt_utp'>
<input type='hidden' name='bt_dl_queue_enable'>
<input type='hidden' name='bt_ul_queue_enable'>

<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用洪客户端', name: 'f_bt_enable', type: 'checkbox', value: nvram.bt_enable == '1', suffix: ' <small>*</small>' },
	{ title: '传输二进制路径', multi: [
		{ name: 'bt_binary', type: 'select', options: [
/* BBT-BEGIN */
			['internal','Internal (/usr/bin)'],
/* BBT-END */
			['optware','Optware (/opt/bin)'],
			['custom','Custom'] ], value: nvram.bt_binary, suffix: ' <small>*</small> ' },
		{ name: 'bt_binary_custom', type: 'text', maxlen: 40, size: 40, value: nvram.bt_binary_custom }
	] },
	{ title: '保持连接', name: 'f_bt_check', type: 'checkbox', value: nvram.bt_check == '1', suffix: ' <small>*</small>' },
	{ title: '检查每个连接', indent: 2, name: 'bt_check_time', type: 'text', maxlen: 5, size: 7, value: nvram.bt_check_time, suffix: ' <small>分钟（范围：1 - 55，默认值：15）</small>' },
	{ title: '启动延迟', name: 'bt_sleep', type: 'text', maxlen: 5, size: 7, value: nvram.bt_sleep, suffix: ' <small>秒 (范围：1 - 60;默认：10)</small>' },
	{ title: '监听端口', name: 'bt_port', type: 'text', maxlen: 5, size: 7, value: nvram.bt_port, suffix: ' <small>*</small>' },
	{ title: '下载目录', name: 'bt_dir', type: 'text', maxlen: 40, size: 40, value: nvram.bt_dir },
	{ title: '使用 .incomplete/', indent: 2, name: 'f_bt_incomplete', type: 'checkbox', value: nvram.bt_incomplete == '1' }
]);
</script>
	<ul>
		<li><b>启用BT客户端</b> - 注意！ - 如果你的路由器只有32MB的RAM，你将不得不使用交换。
		<li><b>传输二进制路径</b> Path to the directory containing transmission-daemon etc.
		<li><b>保持连接</b> - 如果启用，传输保持进程将在指定的时间间隔进行检查，并在系统崩溃后重新启动。
		<li><b>监听端口</b> - BT客户端使用的端口。确保不使用此端口。
	</ul>
</div>
<div class='section-title'>远程访问<script>W(btgui_link);</script></div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用GUI', name: 'f_bt_rpc_enable', type: 'checkbox', value: nvram.bt_rpc_enable == '1' },
	{ title: '监听GUI移植', indent: 2, name: 'bt_port_gui', type: 'text', maxlen: 32, size: 5, value: nvram.bt_port_gui, suffix: ' <small>*</small>' },
	{ title: '需要验证', name: 'f_bt_auth', type: 'checkbox', value: nvram.bt_auth == '1', suffix: ' <small>*</small>' },
	{ title: '用户名', indent: 2, name: 'bt_login', type: 'text', maxlen: 32, size: 15, value: nvram.bt_login },
	{ title: '密码', indent: 2, name: 'bt_password', type: 'password', maxlen: 32, size: 15, value: nvram.bt_password },
	{ title: '允许远程访问', name: 'f_bt_rpc_wan', type: 'checkbox', value: nvram.bt_rpc_wan == '1', suffix: ' <small>*</small>' }
]);
</script>
	<ul>
		<li><b>监听图形用户界面端口</b> - 端口用于传输界面。确保在不使用此端口。
		<li><b>需要验证</b> - 认证需要<b><i>强制认证</i></b>. 图形用户界面将提示用户名/密码。
		<li><b>允许远程访问</b> - 此选项将打开传输界面端口，并允许来自WAN端GUI来从互联网上访问。
	</ul>
</div>
<div class='section-title'>范围</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '下载限制', multi: [
		{ name: 'f_bt_dl_enable', type: 'checkbox', value: nvram.bt_dl_enable == '1', suffix: '  ' },
		{ name: 'bt_dl', type: 'text', maxlen: 10, size: 7, value: nvram.bt_dl, suffix: ' <small>kB/s</small>' } ] },
	{ title: '上传限制', multi: [
		{ name: 'f_bt_ul_enable', type: 'checkbox', value: nvram.bt_ul_enable == '1', suffix: '  ' },
		{ name: 'bt_ul', type: 'text', maxlen: 10, size: 7, value: nvram.bt_ul, suffix: ' <small>kB/s</small>' } ] },
	{ title: '停止播种率', multi: [
		{ name: 'f_bt_ratio_enable', type: 'checkbox', value: nvram.bt_ratio_enable == '1', suffix: '  ' },
		{ name: 'bt_ratio', type: 'select', options: [['0.0000','0.0'],['0.1000','0.1'],['0.2000','0.2'],['0.5000','0.5'],['1.0000','1.0'],['1.5000','1.5'],['2.0000','2.0'],['2.5000','2.5'],['3.0000','3.0']], value: nvram.bt_ratio } ] },
	{ title: '如果闲置，停止播种', multi: [
		{ name: 'f_bt_ratio_idle_enable', type: 'checkbox', value: nvram.bt_ratio_idle_enable == '1', suffix: '  ' },
		{ name: 'bt_ratio_idle', type: 'text', maxlen: 10, size: 7, value: nvram.bt_ratio_idle, suffix: ' <small>分钟（范围：1 - 55，默认：30)</small>' } ] },
	{ title: '全球同行限制', name: 'bt_peer_limit_global', type: 'text', maxlen: 10, size: 7, value: nvram.bt_peer_limit_global, suffix: ' <small>(范围：10 - 1000默认值：150)</small>' },
	{ title: '同行限制每个torrent', name: 'bt_peer_limit_per_torrent', type: 'text', maxlen: 10, size: 7, value: nvram.bt_peer_limit_per_torrent, suffix: ' <small>(范围：1 - 200;默认：30)</small>' },
	{ title: '上传插槽每个torrent', name: 'bt_ul_slot_per_torrent', type: 'text', maxlen: 10, size: 7, value: nvram.bt_ul_slot_per_torrent, suffix: ' <small>(范围：1 - 50;默认：10)</small>' }
]);
</script>
</div>
<div class='section-title'>队列种子</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '下载排队', multi: [
		{ name: 'f_bt_dl_queue_enable', type: 'checkbox', value: nvram.bt_dl_queue_enable == '1', suffix: '  ' },
		{ name: 'bt_dl_queue_size', type: 'text', maxlen: 5, size: 7, value: nvram.bt_dl_queue_size, suffix: ' <small>(范围：1 - 30，默认：5) *</small>' }
		] },
	{ title: '种子排队', multi: [
		{ name: 'f_bt_ul_queue_enable', type: 'checkbox', value: nvram.bt_ul_queue_enable == '1', suffix: '  ' },
		{ name: 'bt_ul_queue_size', type: 'text', maxlen: 5, size: 7, value: nvram.bt_ul_queue_size, suffix: ' <small>(范围：1 - 30，默认：5) *</small>' }
		] }
]);
</script>
	<ul>
		<li><b>下载队列</b> - 如果启用，此选项将限制一次可以下载多少
		<li><b>种子队列</b> - 如果启用，此选项将限制多少种子可以上传/接种一次。
	</ul>
</div>
<div class='section-title'>高级设置</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '寻找更多的同龄人使用', multi: [
		{ suffix: '&nbsp; DHT &nbsp;&nbsp;&nbsp;', name: 'f_bt_dht', type: 'checkbox', value: nvram.bt_dht == '1' },
		{ suffix: '&nbsp; PEX &nbsp;&nbsp;&nbsp;', name: 'f_bt_pex', type: 'checkbox', value: nvram.bt_pex == '1' },
		{ suffix: '&nbsp; LPD &nbsp;&nbsp;&nbsp;', name: 'f_bt_lpd', type: 'checkbox', value: nvram.bt_lpd == '1' },
		{ suffix: '&nbsp; uTP &nbsp;&nbsp;&nbsp;', name: 'f_bt_utp', type: 'checkbox', value: nvram.bt_utp == '1' }
		] },
	{ title: '消息level', name: 'bt_message', type: 'select', options: [ ['0','无'], ['1','错误'], ['2','信息'], ['3','调试'] ], value: nvram.bt_message, suffix: ' ' },
	{ title: '保存设置位置', multi: [
		{ name: 'bt_settings', type: 'select', options: [
			['down_dir','在“下载目录中（推荐）'],
/* JFFS2-BEGIN */
			['/jffs','JFFS2'],
/* JFFS2-END */
/* CIFS-BEGIN */
			['/cifs1','CIFS 1'],['/cifs2','CIFS 2'],
/* CIFS-END */
			['/tmp','RAM（暂行）'], ['custom','Custom'] ], value: nvram.bt_settings, suffix: ' ' },
		{ name: 'bt_settings_custom', type: 'text', maxlen: 60, size: 40, value: nvram.bt_settings_custom }
		] },
	{ title: '黑名单', multi: [
		{ name: 'f_bt_blocklist', type: 'checkbox', value: nvram.bt_blocklist == '1', suffix: '  ' },
		{ name: 'bt_blocklist_url', type: 'text', maxlen: 80, size: 80, value: nvram.bt_blocklist_url }
		] },
	null,
	{ title: '<a href="https://trac.transmissionbt.com/wiki/EditConfigFiles" target="_new">传输</a><br>自定义配置', name: 'bt_custom', type: 'textarea', value: nvram.bt_custom }
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
