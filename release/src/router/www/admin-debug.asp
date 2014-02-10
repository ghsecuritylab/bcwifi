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
<title>[<% ident(); %>] 系统管理：调试</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='v8.css'>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("debug_nocommit,debug_cprintf,debug_cprintf_file,console_loglevel,t_cafree,t_hidelr,debug_ddns,debug_norestart"); %>

function nvramCommit()
{
	fields.disableAll('_fom', 1);
	form.submitHidden('nvcommit.cgi', { '_nextpage': myName() });
}

function verifyFields(focused, quiet)
{
	return 1;
}

function save()
{
	var fom = E('_fom');
	fom.debug_nocommit.value = fom.f_debug_nocommit.checked ? 1 : 0;
	fom.debug_cprintf.value = fom.f_debug_cprintf.checked ? 1 : 0;
	fom.debug_cprintf_file.value = fom.f_debug_cprintf_file.checked ? 1 : 0;
	fom.t_cafree.value = fom.f_cafree.checked ? 1 : 0;
	fom.t_hidelr.value = fom.f_hidelr.checked ? 1 : 0;
	fom.debug_ddns.value = fom.f_debug_ddns.checked ? 1 : 0;

	var a = [];
	if (fom.f_nr_crond.checked) a.push('crond');
	if (fom.f_nr_dnsmasq.checked) a.push('dnsmasq');
/* LINUX26-BEGIN */
	if (fom.f_nr_hotplug2.checked) a.push('hotplug2');
/* LINUX26-END */
/* IPV6-BEGIN */
	if (fom.f_nr_radvd.checked) a.push('radvd');
/* IPV6-END */
	if (fom.f_nr_igmprt.checked) a.push('igmprt');
	fom.debug_norestart.value = a.join(',');

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

<input type='hidden' name='_nextpage' value='admin-misc.asp'>

<input type='hidden' name='debug_nocommit'>
<input type='hidden' name='debug_cprintf'>
<input type='hidden' name='debug_cprintf_file'>
<input type='hidden' name='debug_ddns'>
<input type='hidden' name='debug_norestart'>
<input type='hidden' name='t_cafree'>
<input type='hidden' name='t_hidelr'>

<div class='section-title'>调试</div>
<div class='section'>
<script type='text/javascript'>
a = [];
for (i = 1; i <= 8; ++i) a.push([i, i]);
createFieldTable('', [
	{ title: '避免写入NVRAM', name: 'f_debug_nocommit', type: 'checkbox', value: nvram.debug_nocommit != '0' },
	{ title: '启用cprintf输出到终端', name: 'f_debug_cprintf', type: 'checkbox', value: nvram.debug_cprintf != '0' },
	{ title: '启用cprintf输出到 /tmp/cprintf', name: 'f_debug_cprintf_file', type: 'checkbox', value: nvram.debug_cprintf_file != '0' },
	{ title: '将 DDNS 输出至 /tmp/mdu-*', name: 'f_debug_ddns', type: 'checkbox', value: nvram.debug_ddns != '0' },
	{ title: '将缓存计入可用内存', name: 'f_cafree', type: 'checkbox', value: nvram.t_cafree == '1' },
	{ title: '不显示LAN到路由的连接', name: 'f_hidelr', type: 'checkbox', value: nvram.t_hidelr == '1' },
	{ title: '终端日志级别', name: 'console_loglevel', type: 'select', options: a, value: fixInt(nvram.console_loglevel, 1, 8, 1) },
	{ title: '若这些进程异常终止，禁止自动重启', multi: [
		{ name: 'f_nr_crond', type: 'checkbox', suffix: ' crond<br>', value: (nvram.debug_norestart.indexOf('crond') != -1) },
		{ name: 'f_nr_dnsmasq', type: 'checkbox', suffix: ' dnsmasq<br>', value: (nvram.debug_norestart.indexOf('dnsmasq') != -1) },
/* LINUX26-BEGIN */
		{ name: 'f_nr_hotplug2', type: 'checkbox', suffix: ' hotplug2<br>', value: (nvram.debug_norestart.indexOf('hotplug2') != -1) },
/* LINUX26-END */
/* IPV6-BEGIN */
		{ name: 'f_nr_radvd', type: 'checkbox', suffix: ' radvd<br>', value: (nvram.debug_norestart.indexOf('radvd') != -1) },
/* IPV6-END */
		{ name: 'f_nr_igmprt', type: 'checkbox', suffix: ' igmprt<br>', value: (nvram.debug_norestart.indexOf('igmprt') != -1) }
	] }
]);
</script>
<br><br>

&raquo; <a href='clearcookies.asp?_http_id=<% nv(http_id); %>'>清除Cookies</a><br>
&raquo; <a href='javascript:nvramCommit()'>写入NVRAM</a><br>
&raquo; <a href='javascript:reboot()'>重启路由器</a><br>
&raquo; <a href='javascript:shutdown()'>关闭路由器</a><br>
<br><br>

&raquo; <a href='/cfe/cfe.bin?_http_id=<% nv(http_id); %>'>下载CFE</a><br>
&raquo; <a href='/ipt/iptables.txt?_http_id=<% nv(http_id); %>'>下载IPv4路由表</a><br>
<!-- IPV6-BEGIN -->
&raquo; <a href='/ip6t/ip6tables.txt?_http_id=<% nv(http_id); %>'>下载IPv6路由表</a><br>
<!-- IPV6-END -->
&raquo; <a href='/logs/syslog.txt?_http_id=<% nv(http_id); %>'>下载日志记录</a><br>
&raquo; <a href='/nvram/nvram.txt?_http_id=<% nv(http_id); %>'>下载NVRAM</a><br>
<br>

<div style='width:80%'>
<b>请注意</b>: NVRAM Dump文件可能包含了如下路由信息:无线加密密钥,用户/密码,ISP和DDNS等. 请在共享给其他人前检查并编辑该文件.<br>
</div>

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
<div id="bottom">Copyright © 2012-2013 By <a href="http://www.ethinking.cn/wweb/" target="_blank">苏州亿想中电子科技有限公司</a> All Rights Reserved. <br/>软件版本<% version(); %></div>

</body>
</html>
