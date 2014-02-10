<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 无线认证：第三方认证</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='v8.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("hotspot_enable,hotspot_authurl,hotspot_whiteurl,hotspot_whiteip,hotspot_timeout,hotspot_kickout,inject_enable,inject_jsurl,hijack_enable,hijack_targeturl,hijack_hijackurl,pushing_enable,pushing_interval,pushing_url"); %>


function reset_settings()
{
	E('_hotspot_authurl').value = '';
	E('_hotspot_whiteurl').value = 'sina,qq';	
	E('_hotspot_whiteip').value = '';
	E('_hotspot_timeout').value = '600';
	E('_hotspot_kickout').value = '0';
}
	
function verifyFields(focused, quiet)
{
	return 1;
}

function save()
{
	var fom;

	if (!verifyFields(null, false)) return;

	fom = E('_fom');
	fom.hotspot_enable.value = E('_f_hotspot_enable').checked ? 1 : 0;
	fom.inject_enable.value = E('_f_inject_enable').checked ? 1 : 0;
	fom.hijack_enable.value = E('_f_hijack_enable').checked ? 1 : 0;
	fom.pushing_enable.value = E('_f_pushing_enable').checked ? 1 : 0;
	form.submit(fom, 1);
}
</script>
</head>
<body>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
<div class='version'></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<input type='hidden' name='_nextpage' value='hotspot.asp'>
<input type='hidden' name='_service' value='hotspot-restart'>

<input type='hidden' name='hotspot_enable'>
<input type='hidden' name='inject_enable'>
<input type='hidden' name='hijack_enable'>
<input type='hidden' name='pushing_enable'>

<div class='section-title'>第三方认证</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用第三方认证', name: 'f_hotspot_enable', type: 'checkbox', value: nvram.hotspot_enable == '1' },
	{ title: '第三方认证地址', name: 'hotspot_authurl', type: 'text', value: nvram.hotspot_authurl },
	{ title: '超时登陆时间(单位s)', name: 'hotspot_timeout', type: 'text',value: nvram.hotspot_timeout },
	{ title: '强制认证时间(单位s)', name: 'hotspot_kickout', type: 'text',value: nvram.hotspot_kickout },
	{ title: '外部域名白名单', name: 'hotspot_whiteurl', type: 'textarea', value: nvram.hotspot_whiteurl ,suffix:'<br><small>域名与域名之间用,隔开</small>'},
	{ title: '内部IP 白名单', name: 'hotspot_whiteip', type: 'textarea', value: nvram.hotspot_whiteip, suffix:'<br><small>IP和IP之间用,隔开</small>' }
]);
</script>
<input type='button' class='controls' onclick='reset_settings()' value='恢复默认设置'>
</div>

<div class='section-title'>网页注入</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用网页注入', name: 'f_inject_enable', type: 'checkbox', value: nvram.inject_enable == '1' },
	{ title: 'JS注入地址', name: 'inject_jsurl', type: 'text', value: nvram.inject_jsurl 	},
]);
</script>
</div>

<div class='section-title'>网页劫持</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用网页劫持', name: 'f_hijack_enable', type: 'checkbox', value: nvram.hijack_enable == '1' },
	{ title: '劫持到页面 http://', name: 'hijack_targeturl', type: 'text', value: nvram.hijack_targeturl 	},	
	{ title: '被劫持页面', name: 'hijack_hijackurl', type: 'textarea', value: nvram.hijack_hijackurl,suffix:'<br><small>网址与网址之间用,符号隔开,且网址无须输入http:// 字段</small>'}
]);
</script>
</div>

<div class='section-title'>网页推送</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用网页推送', name: 'f_pushing_enable', type: 'checkbox', value: nvram.pushing_enable == '1' },
	{ title: '推送间隔(单位s)', name: 'pushing_interval', type: 'text', value: nvram.pushing_interval 	},	
	{ title: '推送页面 http://', name: 'pushing_url', type: 'text', value: nvram.pushing_url 		}	
]);
</script>
</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>verifyFields(null, true);</script>
</body>
</html>
