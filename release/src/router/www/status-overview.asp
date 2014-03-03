<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	Tomato VLAN GUI
	Copyright (C) 2011 Augusto Bott
	http://code.google.com/p/tomato-sdhc-vlan/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 系统状态：系统状态</title>

<link rel='stylesheet' type='text/css' href='bootstrap.css'>
<link rel='stylesheet' type='text/css' href='new.css'>





 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='bootstrap.js'></script>
<script type='text/javascript' src='interfaces.js'></script>
<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvstat(); %>
//	<% etherstates(); %>
//	<% anonupdate(); %>

wmo = {'ap':'无线访问点 AP','sta':'无线客户端','wet':'无线网桥','wds':'WDS'};
auth = {'disabled':'-','wep':'WEP','wpa_personal':'WPA Personal (PSK)','wpa_enterprise':'WPA Enterprise','wpa2_personal':'WPA2 Personal (PSK)','wpa2_enterprise':'WPA2 Enterprise','wpaX_personal':'WPA / WPA2 Personal','wpaX_enterprise':'WPA / WPA2 Enterprise','radius':'Radius'};
enc = {'tkip':'TKIP','aes':'AES','tkip+aes':'TKIP / AES'};
bgmo = {'disabled':'-','mixed':'自动','b-only':'B Only','g-only':'G Only','bg-mixed':'B/G Mixed','lrs':'LRS','n-only':'N Only'};
</script>

<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='status-data.jsx?_http_id=<% nv(http_id); %>'></script>

<script type='text/javascript'>
show_dhcpc = ((nvram.wan_proto == 'dhcp') || (((nvram.wan_proto == 'l2tp') || (nvram.wan_proto == 'pptp')) && (nvram.pptp_dhcp == '1')));
show_codi = ((nvram.wan_proto == 'pppoe') || (nvram.wan_proto == 'l2tp') || (nvram.wan_proto == 'pptp') || (nvram.wan_proto == 'ppp3g') ||  (nvram.wan_proto == 'pppox'));

show_radio = [];
for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
/* REMOVE-BEGIN
//	show_radio.push((nvram['wl'+wl_unit(uidx)+'_radio'] == '1'));
REMOVE-END */
	if (wl_sunit(uidx)<0)
		show_radio.push((nvram['wl'+wl_fface(uidx)+'_radio'] == '1'));
}

nphy = features('11n');

function dhcpc(what)
{
	form.submitHidden('dhcpc.cgi', { exec: what, _redirect: 'status-overview.asp' });
}

function serv(service, sleep)
{
	form.submitHidden('service.cgi', { _service: service, _redirect: 'status-overview.asp', _sleep: sleep });
}

function wan_connect()
{
	serv('wan-restart', 5);
}

function wan_disconnect()
{
	serv('wan-stop', 2);
}

function wlenable(uidx, n)
{
	form.submitHidden('wlradio.cgi', { enable: '' + n, _nextpage: 'status-overview.asp', _nextwait: n ? 6 : 3, _wl_unit: wl_unit(uidx) });
}

var ref = new TomatoRefresh('status-data.jsx', '', 0, 'status_overview_refresh');

ref.refresh = function(text)
{
	stats = {};
	try {
		eval(text);
	}
	catch (ex) {
		stats = {};
	}
	show();
}


function c(id, htm)
{
	E(id).cells[1].innerHTML = htm;
}

function ethstates()
{
	port = etherstates.port0;
	if (port == "disabled") { return 0; }

	var state, state1, state2;
	var code = '<div class="section-title">网络端口状态</div>';
	code += '<table class="fields"><tr><td class="title indent2"><center><b>WAN</b></center></td><td class="title indent2"><!-- empty space --></td><td class="title indent2"><center><b>LAN 1</b></center></td><td class="title indent2"><center><b>LAN 2</b></center></td><td class="title indent2"><center><b>LAN 3</b></center></td><td class="title indent2"><center><b>LAN 4</b></center></td><tr>';

	if (port == "DOWN") {
		state = '<img id="eth_off" src="eth_off.png"><br>';
		state2 = port.replace("DOWN","断开");
	} else if ((port == "1000FD") || (port == "1000HD")) {
		state = '<img id="eth_1000" src="eth_1000.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	} else {
		state = '<img id="eth_100" src="eth_100.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	}
	if (stats.lan_desc == '1') {
		code += '<td class="title indent2"><center>' + state + state2 + '</center></td>';
	} else {
		code += '<td class="title indent2"><center>' + state + '</center></td>';
	}

	code += '<td class="title indent2"><!-- empty space --></td>';

	port = etherstates.port1;
	if (port == "DOWN") {
		state = '<img id="eth_off" src="eth_off.png"><br>';
		state2 = port.replace("DOWN","断开");
	} else if ((port == "1000FD") || (port == "1000HD")) {
		state = '<img id="eth_1000" src="eth_1000.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	} else {
		state = '<img id="eth_100" src="eth_100.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	}
	if (stats.lan_desc == '1') {
		code += '<td class="title indent2"><center>' + state + state2 + '</center></td>';
	} else {
		code += '<td class="title indent2"><center>' + state + '</center></td>';
	}

	port = etherstates.port2;
	if (port == "DOWN") {
		state = '<img id="eth_off" src="eth_off.png"><br>';
		state2 = port.replace("DOWN","断开");
	} else if ((port == "1000FD") || (port == "1000HD")) {
		state = '<img id="eth_1000" src="eth_1000.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	} else {
		state = '<img id="eth_100" src="eth_100.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	}
	if (stats.lan_desc == '1') {
		code += '<td class="title indent2"><center>' + state + state2 + '</center></td>';
	} else {
		code += '<td class="title indent2"><center>' + state + '</center></td>';
	}

	port = etherstates.port3;
	if (port == "DOWN") {
		state = '<img id="eth_off" src="eth_off.png"><br>';
		state2 = port.replace("DOWN","断开");
	} else if ((port == "1000FD") || (port == "1000HD")) {
		state = '<img id="eth_1000" src="eth_1000.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	} else {
		state = '<img id="eth_100" src="eth_100.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	}
	if (stats.lan_desc == '1') {
		code += '<td class="title indent2"><center>' + state + state2 + '</center></td>';
	} else {
		code += '<td class="title indent2"><center>' + state + '</center></td>';
	}

	port = etherstates.port4;
	if (port == "DOWN") {
		state = '<img id="eth_off" src="eth_off.png"><br>';
		state2 = port.replace("DOWN","断开");
	} else if ((port == "1000FD") || (port == "1000HD")) {
		state = '<img class="img-thumbnail" id="eth_1000" src="eth_1000.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	} else {
		state = '<img id="eth_100" src="eth_100.gif"><br>';
		state1 = port.replace("HD","M Half");
		state2 = state1.replace("FD","M Full");
	}
	if (stats.lan_desc == '1') {
		code += '<td class="title indent2"><center>' + state + state2 + '</center></td>';
	} else {
		code += '<td class="title indent2"><center>' + state + '</center></td>';
	}

	code += '<td class="content"> </td></tr>';
	code += '<tr><td class="title indent1" colspan="7" align="right"><a class="btn btn-default" href="basic-network.asp">设置&raquo; </a></td></tr></table></div>';
	E("ports").innerHTML = code;
}

function show()
{
	c('cpu', stats.cpuload);
	c('uptime', stats.uptime);
	c('time', stats.time);
	c('wanip', stats.wanip);
	c('wanprebuf',stats.wanprebuf); //Victek
	c('wannetmask', stats.wannetmask);
	c('wangateway', stats.wangateway);
	c('dns', stats.dns);
	c('memory', stats.memory);
	c('swap', stats.swap);
	elem.display('swap', stats.swap != '');

/* IPV6-BEGIN */
	c('ip6_wan', stats.ip6_wan);
	elem.display('ip6_wan', stats.ip6_wan != '');
	c('ip6_lan', stats.ip6_lan);
	elem.display('ip6_lan', stats.ip6_lan != '');
	c('ip6_lan_ll', stats.ip6_lan_ll);
	elem.display('ip6_lan_ll', stats.ip6_lan_ll != '');
/* IPV6-END */

	c('wanstatus', stats.wanstatus);
	c('wanuptime', stats.wanuptime);
	if (show_dhcpc) c('wanlease', stats.wanlease);
	if (show_codi) {
		E('b_connect').disabled = stats.wanup;
		E('b_disconnect').disabled = !stats.wanup;
	}

	for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		if (wl_sunit(uidx)<0) {
			c('radio'+uidx, wlstats[uidx].radio ? '启用' : '<b>禁用</b>');
			c('rate'+uidx, wlstats[uidx].rate);
			if (show_radio[uidx]) {
				E('b_wl'+uidx+'_enable').disabled = wlstats[uidx].radio;
				E('b_wl'+uidx+'_disable').disabled = !wlstats[uidx].radio;
			}
			c('channel'+uidx, stats.channel[uidx]);
			if (nphy) {
				c('nbw'+uidx, wlstats[uidx].nbw);
			}
			c('interference'+uidx, stats.interference[uidx]);
			elem.display('interference'+uidx, stats.interference[uidx] != '');

			if (wlstats[uidx].client) {
				c('rssi'+uidx, wlstats[uidx].rssi || '');
				c('noise'+uidx, wlstats[uidx].noise || '');
				c('qual'+uidx, stats.qual[uidx] || '');
			}
		}
		c('ifstatus'+uidx, wlstats[uidx].ifstatus || '');
	}
}

function earlyInit()
{
	elem.display('b_dhcpc', show_dhcpc);
	elem.display('b_connect', 'b_disconnect', show_codi);
	if (nvram.wan_proto == 'disabled')
		elem.display('wan-title', 'sesdiv_wan', 0);
	for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		if (wl_sunit(uidx)<0)
			elem.display('b_wl'+uidx+'_enable', 'b_wl'+uidx+'_disable', show_radio[uidx]);
	}

	ethstates();

	show();
}

function init()
{
	var c;
	if (((c = cookie.get('status_overview_system_vis')) != null) && (c != '1')) toggleVisibility("system");
	if (((c = cookie.get('status_overview_wan_vis')) != null) && (c != '1')) toggleVisibility("wan");
	if (((c = cookie.get('status_overview_lan_vis')) != null) && (c != '1')) toggleVisibility("lan");
	for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		u = wl_unit(uidx);
		if (((c = cookie.get('status_overview_wl_'+u+'_vis')) != null) && (c != '1')) toggleVisibility("wl_"+u);
	}
	ref.initPage(3000, 3);
}

function toggleVisibility(whichone) {
	if (E('sesdiv_' + whichone).style.display == '') {
		E('sesdiv_' + whichone).style.display = 'none';
		E('sesdiv_' + whichone + '_showhide').innerHTML = '(显示)';
		cookie.set('status_overview_' + whichone + '_vis', 0);
	} else {
		E('sesdiv_' + whichone).style.display='';
		E('sesdiv_' + whichone + '_showhide').innerHTML = '(隐藏)';
		cookie.set('status_overview_' + whichone + '_vis', 1);
	}
}

</script>

</head>
<body onload='init()'>
<form>
<table id='container' class="table" cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->
<div class='section' id='nversion'>
</div>

<div class='section-title'>系统状态 <small><i><a href='javascript:toggleVisibility("system");'><span id='sesdiv_system_showhide'>(隐藏)</span></a></i></small></div>
<div class='section' id='sesdiv_system'>
<script type='text/javascript'>
var a = nvstat.free / nvstat.size * 100.0;
createFieldTable('', [
	{ title: '名称', text: nvram.router_name },
	{ title: '机型', text: nvram.t_model_name },
	{ title: 'CPU型号', text: stats.systemtype },
	{ title: 'CPU频率', text: stats.cpumhz },
	{ title: 'Flash容量', text: stats.flashsize },
	null,
	{ title: '时间', rid: 'time', text: stats.time },
	{ title: '开机时间', rid: 'uptime', text: stats.uptime },
	{ title: 'CPU负载 <small>(1 / 5 / 15 分钟)</small>', rid: 'cpu', text: stats.cpuload },
	{ title: '总 / 剩余 内存占用率', rid: 'memory', text: stats.memory },
	{ title: '总 / 剩余 内存', rid: 'swap', text: stats.swap, hidden: (stats.swap == '') },
	{ title: '总 / 剩余 NVRAM', text: scaleSize(nvstat.size) + ' / ' + scaleSize(nvstat.free) + ' <small>(' + (a).toFixed(2) + '%)</small>' }
]);
</script>
</div>

<div class='section' id='ports'>
</div>

<div class='section-title' id='wan-title'>WAN 状态<small><i><a href='javascript:toggleVisibility("wan");'><span id='sesdiv_wan_showhide'>(隐藏)</span></a></i></small></div>
<div class='section' id='sesdiv_wan'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: 'MAC地址', text: nvram.wan_hwaddr },
	{ title: 'WAN连接类型', text: { 'dhcp':'DHCP', 'static':'Static IP', 'pppoe':'PPPoE', 'pptp':'PPTP', 'l2tp':'L2TP', 'ppp3g':'3G Modem', 'pppox':'海蜘蛛专拨' }[nvram.wan_proto] || '-' },
	{ title: 'IP 地址', rid: 'wanip', text: stats.wanip },
	{ title: 'Previous WAN IP', rid: 'wanprebuf', text: stats.wanprebuf, hidden: ((nvram.wan_proto != 'pppoe') && (nvram.wan_proto != 'pptp') && (nvram.wan_proto != 'l2tp') && (nvram.wan_proto != 'ppp3g') && (nvram.wan_proto != 'pppox') ) }, //Victek
	{ title: '子网掩码', rid: 'wannetmask', text: stats.wannetmask },
	{ title: '网关', rid: 'wangateway', text: stats.wangateway },
/* IPV6-BEGIN */
	{ title: 'IPv6 Address', rid: 'ip6_wan', text: stats.ip6_wan, hidden: (stats.ip6_wan == '') },
/* IPV6-END */
	{ title: 'DNS', rid: 'dns', text: stats.dns },
	{ title: 'MTU设置', text: nvram.wan_run_mtu },
	null,
	{ title: '状态', rid: 'wanstatus', text: stats.wanstatus },
	{ title: '已连接时间', rid: 'wanuptime', text: stats.wanuptime },
	{ title: '剩余租用时间', rid: 'wanlease', text: stats.wanlease, ignore: !show_dhcpc }
]);
</script>
<span id='b_dhcpc' style='display:none'>
	<input type='button' class='btn btn-primary' onclick='dhcpc("renew")' value='重新获取'>
	<input type='button' class='btn btn-primary' onclick='dhcpc("release")' value='释放'> &nbsp;
</span>
<input type='button' class='controls' onclick='wan_connect()' value='连接' id='b_connect' style='display:none'>
<input type='button' class='controls' onclick='wan_disconnect()' value='断线' id='b_disconnect' style='display:none'>
</div>


<div class='section-title'>LAN 状态<small><i><a href='javascript:toggleVisibility("lan");'><span id='sesdiv_lan_showhide'>(隐藏)</span></a></i></small></div>
<div class='section' id='sesdiv_lan'>
<script type='text/javascript'>

function h_countbitsfromleft(num) {
	if (num == 255 ){
		return(8);
	}
	var i = 0;
	var bitpat=0xff00; 
	while (i < 8){
		if (num == (bitpat & 0xff)){
			return(i);
		}
		bitpat=bitpat >> 1;
		i++;
	}
	return(Number.NaN);
}

function numberOfBitsOnNetMask(netmask) {
	var total = 0;
	var t = netmask.split('.');
	for (var i = 0; i<= 3 ; i++) {
		total += h_countbitsfromleft(t[i]);
	}
	return total;
}

var s='';
var t='';
for (var i = 0 ; i <= MAX_BRIDGE_ID ; i++) {
	var j = (i == 0) ? '' : i.toString();
	if (nvram['lan' + j + '_ifname'].length > 0) {
		if (nvram['lan' + j + '_proto'] == 'dhcp') {
			if ((!fixIP(nvram.dhcpd_startip)) || (!fixIP(nvram.dhcpd_endip))) {
				var x = nvram['lan' + j + '_ipaddr'].split('.').splice(0, 3).join('.') + '.';
				nvram['dhcpd' + j + '_startip'] = x + nvram['dhcp' + j + '_start'];
				nvram['dhcpd' + j + '_endip'] = x + ((nvram['dhcp' + j + '_start'] * 1) + (nvram['dhcp' + j + '_num'] * 1) - 1);
			}
			s += ((s.length>0)&&(s.charAt(s.length-1) != ' ')) ? '<br>' : '';
			s += '<b>br' + i + '</b> (LAN' + j + ') - ' + nvram['dhcpd' + j + '_startip'] + ' - ' + nvram['dhcpd' + j + '_endip'];
		} else {
			s += ((s.length>0)&&(s.charAt(s.length-1) != ' ')) ? '<br>' : '';
			s += '<b>br' + i + '</b> (LAN' + j + ') - Disabled';
		}
		t += ((t.length>0)&&(t.charAt(t.length-1) != ' ')) ? '<br>' : '';
		t += '<b>br' + i + '</b> (LAN' + j + ') - ' + nvram['lan' + j + '_ipaddr'] + '/' + numberOfBitsOnNetMask(nvram['lan' + j + '_netmask']);
		
	}
}

createFieldTable('', [
	{ title: '路由器MAC地址', text: nvram.et0macaddr },
	{ title: '路由器IP 地址', text: t },
	{ title: '网关', text: nvram.lan_gateway, ignore: nvram.wan_proto != 'disabled' },
/* IPV6-BEGIN */
	{ title: 'Router IPv6 Address', rid: 'ip6_lan', text: stats.ip6_lan, hidden: (stats.ip6_lan == '') },
	{ title: 'IPv6 Link-local Address', rid: 'ip6_lan_ll', text: stats.ip6_lan_ll, hidden: (stats.ip6_lan_ll == '') },
/* IPV6-END */
	{ title: 'DNS', rid: 'dns', text: stats.dns, ignore: nvram.wan_proto != 'disabled' },
	{ title: 'DHCP', text: s }
]);

</script>
</div>

<script type='text/javascript'>
for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
/* REMOVE-BEGIN
//	u = wl_unit(uidx);
REMOVE-END */
	u = wl_fface(uidx);
	W('<div class=\'section-title\' id=\'wl'+u+'-title\'>Wireless');
	if (wl_ifaces.length > 0)
		W(' (' + wl_display_ifname(uidx) + ')');
	W(' <small><i><a href=\'javascript:toggleVisibility("wl_' + u + '");\'><span id=\'sesdiv_wl_' +u + '_showhide\'>(hide)</span></a></i></small>');
	W('</div>');
	W('<div class=\'section\' id=\'sesdiv_wl_'+u+'\'>');
	sec = auth[nvram['wl'+u+'_security_mode']] + '';
	if (sec.indexOf('WPA') != -1) sec += ' + ' + enc[nvram['wl'+u+'_crypto']];

	wmode = wmo[nvram['wl'+u+'_mode']] + '';
	if ((nvram['wl'+u+'_mode'] == 'ap') && (nvram['wl'+u+'_wds_enable'] * 1)) wmode += ' + WDS';

	createFieldTable('', [
		{ title: 'MAC地址', text: nvram['wl'+u+'_hwaddr'] },
		{ title: '无线模式', text: wmode },
		{ title: '工作模式', text: bgmo[nvram['wl'+u+'_net_mode']], ignore: (wl_sunit(uidx)>=0) },
		{ title: '链接状态', rid: 'ifstatus'+uidx, text: wlstats[uidx].ifstatus },
		{ title: '无线状态', rid: 'radio'+uidx, text: (wlstats[uidx].radio == 0) ? '<b>禁用</b>' : '启用', ignore: (wl_sunit(uidx)>=0) },
/* REMOVE-BEGIN */
//	{ title: 'SSID', text: (nvram['wl'+u+'_ssid'] + ' <small><i>' + ((nvram['wl'+u+'_mode'] != 'ap') ? '' : ((nvram['wl'+u+'_closed'] == 0) ? '(Broadcast Enabled)' : '(Broadcast Disabled)')) + '</i></small>') },
/* REMOVE-END */
		{ title: 'SSID', text: nvram['wl'+u+'_ssid'] },
		{ title: 'SSID 广播', text: (nvram['wl'+u+'_closed'] == 0) ? '启用' : '<b>禁用</b>', ignore: (nvram['wl'+u+'_mode'] != 'ap') },
		{ title: '安全设置', text: sec },
		{ title: '频道', rid: 'channel'+uidx, text: stats.channel[uidx], ignore: (wl_sunit(uidx)>=0) },
		{ title: '频宽', rid: 'nbw'+uidx, text: wlstats[uidx].nbw, ignore: ((!nphy) || (wl_sunit(uidx)>=0)) },
		{ title: '干扰水平', rid: 'interference'+uidx, text: stats.interference[uidx], hidden: ((stats.interference[uidx] == '') || (wl_sunit(uidx)>=0)) },
		{ title: '无线速率', rid: 'rate'+uidx, text: wlstats[uidx].rate, ignore: (wl_sunit(uidx)>=0) },
		{ title: 'RSSI', rid: 'rssi'+uidx, text: wlstats[uidx].rssi || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) },
		{ title: 'Noise', rid: 'noise'+uidx, text: wlstats[uidx].noise || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) },
		{ title: 'Signal Quality', rid: 'qual'+uidx, text: stats.qual[uidx] || '', ignore: ((!wlstats[uidx].client) || (wl_sunit(uidx)>=0)) }
	]);

	W('<input type=\'button\' class=\'btn btn-danger margin-r4\' onclick=\'wlenable('+uidx+', 1)\' id=\'b_wl'+uidx+'_enable\' value=\'启用\' style=\'display:none\'>');
	W('<input type=\'button\' class=\'btn btn-danger\' onclick=\'wlenable('+uidx+', 0)\' id=\'b_wl'+uidx+'_disable\' value=\'禁用\' style=\'display:none\'>');
	W('</div>');
}
</script>


<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<script type='text/javascript'>genStdRefresh(1,0,'ref.toggle()');</script>
</td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit()</script>


</body>
</html>
