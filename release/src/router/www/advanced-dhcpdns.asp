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
<title>[<% ident(); %>] 高级设置: DHCP/DNS设置</title>

<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/bootstrap.css'>
<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/new.css'>





 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='http://dev.plat.gionee.com/static/bootstrap.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript'>

//	<% nvram("dnsmasq_q,ipv6_radvd,dhcpd_dmdns,dns_addget,dhcpd_gwmode,dns_intcpt,dhcpd_slt,dhcpc_minpkt,dnsmasq_custom,dnsmasq_norw,dhcpd_lmax,dhcpc_custom,dns_norebind,dhcpd_static_only"); %>

if ((isNaN(nvram.dhcpd_lmax)) || ((nvram.dhcpd_lmax *= 1) < 1)) nvram.dhcpd_lmax = 255;

function verifyFields(focused, quiet)
{
	var b = (E('_f_dhcpd_sltsel').value == 1);
	elem.display('_dhcpd_sltman', b);
	if ((b) && (!v_range('_f_dhcpd_slt', quiet, 1, 43200))) return 0;
	if (!v_length('_dnsmasq_custom', quiet, 0, 2048)) return 0;
	if (!v_range('_dhcpd_lmax', quiet, 1, 0xFFFF)) return 0;
	if (!v_length('_dhcpc_custom', quiet, 0, 80)) return 0;
	return 1;
}

function nval(a, b)
{
	return (a == null || (a + '').trim() == '') ? b : a;
}

function save()
{
	if (!verifyFields(null, false)) return;

	var a;
	var fom = E('_fom');

	fom.dhcpd_dmdns.value = E('_f_dhcpd_dmdns').checked ? 1 : 0;
	a = E('_f_dhcpd_sltsel').value;
	fom.dhcpd_slt.value = (a != 1) ? a : E('_f_dhcpd_slt').value;
	fom.dns_addget.value = E('_f_dns_addget').checked ? 1 : 0;
	fom.dns_norebind.value = E('_f_dns_norebind').checked ? 1 : 0;
	fom.dhcpd_gwmode.value = E('_f_dhcpd_gwmode').checked ? 1 : 0;
	fom.dns_intcpt.value = E('_f_dns_intcpt').checked ? 1 : 0;
	fom.dhcpc_minpkt.value = E('_f_dhcpc_minpkt').checked ? 1 : 0;
	fom.dhcpd_static_only.value = E('_f_dhcpd_static_only').checked ? '1' : '0';
	fom.ipv6_radvd.value = E('_f_ipv6_radvd').checked ? '1' : '0';

	fom.dnsmasq_q.value = 0;
	if (fom.f_dnsmasq_q4.checked) fom.dnsmasq_q.value |= 1;
	if (fom.f_dnsmasq_q6.checked) fom.dnsmasq_q.value |= 2;
	if (fom.f_dnsmasq_qr.checked) fom.dnsmasq_q.value |= 4;

	if (fom.dhcpc_minpkt.value != nvram.dhcpc_minpkt ||
	    fom.dhcpc_custom.value != nvram.dhcpc_custom) {
		nvram.dhcpc_minpkt = fom.dhcpc_minpkt.value;
		nvram.dhcpc_custom = fom.dhcpc_custom.value;
		fom._service.value = '*';
	}
	else {
		fom._service.value = 'dnsmasq-restart';
	}


	if (fom.dns_intcpt.value != nvram.dns_intcpt) {
		nvram.dns_intcpt = fom.dns_intcpt.value;
		if (fom._service.value != '*') fom._service.value += ',firewall-restart';
	}

/* IPV6-BEGIN */
	if (fom.dhcpd_dmdns.value != nvram.dhcpd_dmdns) {
		nvram.dhcpd_dmdns = fom.dhcpd_dmdns.value;
		if (fom._service.value != '*') fom._service.value += ',dnsmasq-restart';
	}
/* IPV6-END */

	form.submit(fom, 1);
}

function toggleVisibility(whichone) {
	if(E('sesdiv' + whichone).style.display=='') {
		E('sesdiv' + whichone).style.display='none';
		E('sesdiv' + whichone + 'showhide').innerHTML='(点击此处显示)';
		cookie.set('adv_dhcpdns_' + whichone + '_vis', 0);
	} else {
		E('sesdiv' + whichone).style.display='';
		E('sesdiv' + whichone + 'showhide').innerHTML='(点击此处隐藏)';
		cookie.set('adv_dhcpdns_' + whichone + '_vis', 1);
	}
}

function init() {
	var c;
	if (((c = cookie.get('adv_dhcpdns_notes_vis')) != null) && (c == '1')) {
		toggleVisibility("notes");
	}
}
</script>

</head>
<body onload='init()'>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='advanced-dhcpdns.asp'>
<input type='hidden' name='_service' value=''>

<input type='hidden' name='dhcpd_dmdns'>
<input type='hidden' name='dhcpd_slt'>
<input type='hidden' name='dns_addget'>
<input type='hidden' name='dns_norebind'>
<input type='hidden' name='dhcpd_gwmode'>
<input type='hidden' name='dns_intcpt'>
<input type='hidden' name='dhcpc_minpkt'>
<input type='hidden' name='dhcpd_static_only'>
<input type='hidden' name='ipv6_radvd'>
<input type='hidden' name='dnsmasq_q'>

<div class='section-title'>DHCP / DNS 服务器 (局域网)</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用内置DNS服务器', name: 'f_dhcpd_dmdns', type: 'checkbox', value: nvram.dhcpd_dmdns == '1' },
	{ title: '添加WAN DNS到静态D列表', name: 'f_dns_addget', type: 'checkbox', value: nvram.dns_addget == '1' },
	{ title: '防止DNS欺骗攻击', name: 'f_dns_norebind', type: 'checkbox', value: nvram.dns_norebind == '1' },
	{ title: '截获DNS端口(UDP 53)', name: 'f_dns_intcpt', type: 'checkbox', value: nvram.dns_intcpt == '1' },
	{ title: 'WAN 被禁使用自定义网关', name: 'f_dhcpd_gwmode', type: 'checkbox', value: nvram.dhcpd_gwmode == '1' },
	{ title: '忽略未知设备的DHCP请求', name: 'f_dhcpd_static_only', type: 'checkbox', value: nvram.dhcpd_static_only == '1' },
	{ title: 'DHCP租用的最大激活数', name: 'dhcpd_lmax', type: 'text', maxlen: 5, size: 8, value: nvram.dhcpd_lmax },
	{ title: '静态租约时间', multi: [
		{ name: 'f_dhcpd_sltsel', type: 'select', options: [[0,'正常'],[-1,'"不限制"'],[1,'自定义']],
			value: (nvram.dhcpd_slt < 1) ? nvram.dhcpd_slt : 1 },
		{ name: 'f_dhcpd_slt', type: 'text', maxlen: 5, size: 8, prefix: '<span id="_dhcpd_sltman"> ', suffix: ' <i>(minutes)</i></span>',
			value: (nvram.dhcpd_slt >= 1) ? nvram.dhcpd_slt : 3600 } ] },
	{ title: '局域网 Announce IPv6', name: 'f_ipv6_radvd', type: 'checkbox', value: nvram.ipv6_radvd == '1' },
	{ title: '禁止dhcpv4日志', name: 'f_dnsmasq_q4', type: 'checkbox', value: (nvram.dnsmasq_q & 1) },
	{ title: '禁止dhcpv6日志', name: 'f_dnsmasq_q6', type: 'checkbox', value: (nvram.dnsmasq_q & 2) },
	{ title: '禁止RA 日志', name: 'f_dnsmasq_qr', type: 'checkbox', value: (nvram.dnsmasq_q & 4) },
	{ title: '<a href="http://www.thekelleys.org.uk/" target="_new">Dnsmasq</a><br>自定义设置', name: 'dnsmasq_custom', type: 'textarea', value: nvram.dnsmasq_custom }
]);
</script>

<!-- / / / -->

<div class='section-title'>DHCP客户端 (WAN)</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'DHCP客户端选项', name: 'dhcpc_custom', type: 'text', maxlen: 80, size: 34, value: nvram.dhcpc_custom },
	{ title: '压缩数据包', name: 'f_dhcpc_minpkt', type: 'checkbox', value: nvram.dhcpc_minpkt == '1' }
]);
</script>
</div>

<!-- / / / -->

<div class='section-title'>说明 <small><i><a href='javascript:toggleVisibility("notes");'><span id='sesdivnotesshowhide'>（点击这里显示）</span></a></i></small></div>
<div class='section' id='sesdivnotes' style='display:none'>

<i>DHCP / DNS 服务器 (局域网):</i><br>
<ul> 
<li><b>启用用内置DNS服务器</b> - 允许dnsmasq为你的LAN提供DNS服务.</li> 
<li><b>使用WAN口获取的DNS</b> - 从WAN口获取DNS添加到静态DNS服务器列表. (详见 <a href='basic-network.asp'>网络设置</a> 配置).</li> 
<li><b>防止DNS欺骗攻击</b> - 将DNS绑定到dnsmasq.</li> 
<li><b>截获DNS端口(UDP 53)</b> - 将所有从53号端口发出的DNS请求包转发到此服务器.</li> 
<li><b>WAN 被禁使用自定义网关</b> - dnsmasq使用路由器的IP做为默认网关.</li> 
<li><b>忽略未知设备的DHCP请求</b> - dnsmasq服务器将仅为 <a href='basic-static.asp'>静态 DHCP/ARP</a> 中的MAC地址提供DHCP服务,不在列表中的机器将无法获取IP.</li> 
<li><b>DHCP租用的最大激活数</b> - 最多允许的DHCP客户端数量.</li> 
<li><b>静态租约时间</b> - DHCP租约的最长时间.</li> 
<li><b>自定义设置</b> - 添加自定义设置到dnsmasq的配置文件.</li> 
</ul> 
<i>DHCP 客户端 (WAN):</i><br> 
<ul> 
<li><b>DHCP客户端选项</b> - 扩展DHCP客户端选项.</li> 
<li><b>压缩数据包</b> - 根据需要设置.</li> 
</ul> 
<i>其它说明:</i><br> 
<ul> 
<li>如果存在/etc/dnsmasq将自动添加到Dnsmasq的配置文件中去.</li> 
</ul> 

</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>verifyFields(null, true);</script>



</body>
</html>

