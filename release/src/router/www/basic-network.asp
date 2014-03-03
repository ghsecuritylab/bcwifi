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
<title>[<% ident(); %>] 基本设置：网络设置</title>

<link rel='stylesheet' type='text/css' href='bootstrap.css'>
<link rel='stylesheet' type='text/css' href='new.css'>





 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='bootstrap.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript' src='md5.js'></script>
<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='interfaces.js'></script>
<script type='text/javascript'>
//	<% nvram("dhcp_lease,dhcp_num,dhcp_start,dhcpd_startip,dhcpd_endip,l2tp_server_ip,lan_gateway,lan_ipaddr,lan_netmask,lan_proto,lan_state,lan_desc,lan_invert,mtu_enable,ppp_demand,ppp_idletime,pppoe_lei,pppoe_lef,ppp_passwd,ppp_redialperiod,ppp_service,ppp_username,ppp_custom,pptp_server_ip,pptp_dhcp,wl_security_mode,wan_dns,dnscrypt_proxy,dnscrypt_port,dnscrypt_cmd,wan_gateway,wan_ipaddr,wan_mtu,wan_netmask,wan_proto,wan_wins,wl_wds_enable,wl_channel,wl_closed,wl_crypto,wl_key,wl_key1,wl_key2,wl_key3,wl_key4,wl_lazywds,wl_mode,wl_net_mode,wl_passphrase,wl_radio,wl_radius_ipaddr,wl_radius_port,wl_ssid,wl_encoding,wl_wds,wl_wep_bit,wl_wpa_gtk_rekey,wl_wpa_psk,wl_radius_key,wl_auth,wl_hwaddr,wan_islan,t_features,wl_nbw_cap,wl_nctrlsb,wl_nband,wl_phytype,lan_ifname,lan_stp,lan1_ifname,lan1_ipaddr,lan1_netmask,lan1_proto,lan1_stp,dhcp1_start,dhcp1_num,dhcp1_lease,dhcpd1_startip,dhcpd1_endip,lan2_ifname,lan2_ipaddr,lan2_netmask,lan2_proto,lan2_stp,dhcp2_start,dhcp2_num,dhcp2_lease,dhcpd2_startip,dhcpd2_endip,lan3_ifname,lan3_ipaddr,lan3_netmask,lan3_proto,lan3_stp,dhcp3_start,dhcp3_num,dhcp3_lease,dhcpd3_startip,dhcpd3_endip,ppp_mlppp,modem_ipaddr,modem_pin,modem_dev,modem_init,modem_apn,cstats_enable"); %>

var lg = new TomatoGrid();
lg.setup = function() {
	this.init('lan-grid', '', 4, [
	{ type: 'select', options: [[0, '0'],[1, '1'],[2, '2'],[3, '3']], prefix: '<div class="centered">', suffix: '</div>' },
	{ type: 'checkbox', prefix: '<div class="centered">', suffix: '</div>' },
	{ type: 'text', maxlen: 15, size: 17 },
	{ type: 'text', maxlen: 15, size: 17 },
	{ type: 'checkbox', prefix: '<div class="centered">', suffix: '</div>' },
	{ multi: [ { type: 'text', maxlen: 15, size: 17}, { type: 'text', maxlen: 15, size: 17 } ] },
	{ type: 'text', maxlen: 6, size: 8 }] );
	this.headerSet(['网桥', 'STP', 'IP 地址', '子网掩码', 'DHCP', 'IP&nbsp;范围&nbsp;<i>（起始/终止）</i>', '租&nbsp;期&nbsp;<i>(分)</i>']);

	var numBridges = 0;
	for (var i = 0 ; i <= MAX_BRIDGE_ID ; i++) {
		var j = (i == 0) ? '' : i.toString();
		if (nvram['lan' + j + '_ifname'].length > 0) {
			if ((!fixIP(nvram['dhcpd' + j + '_startip'])) || (!fixIP(nvram['dhcpd' + j + '_endip']))) {
				if ((fixIP(nvram['lan' + j + '_ipaddr'])) && (fixIP(nvram['lan' + j + '_netmask'])) && (nvram['dhcp' + j + '_start'] != '')) {
					var n = getNetworkAddress(nvram['lan' + j + '_ipaddr'], nvram['lan' + j + '_netmask']);
					nvram['dhcpd' + j + '_startip'] = getAddress(('0.0.0.' + nvram['dhcp' + j + '_start'] * 1), n);
					nvram['dhcpd' + j + '_endip'] = getAddress(('0.0.0.' + ((nvram['dhcp' + j + '_start'] * 1) + (nvram['dhcp' + j + '_num'] *1) - 1)), n);
				}
			}
			lg.insertData(-1, [ 
				i.toString(),
				nvram['lan' + j + '_stp'],
				nvram['lan' + j + '_ipaddr'],
				nvram['lan' + j + '_netmask'],
				(nvram['lan' + j + '_proto'] == 'dhcp') ? '1' : '0',
				nvram['dhcpd' + j + '_startip'],
				nvram['dhcpd' + j + '_endip'],
				(nvram['lan' + j + '_proto'] == 'dhcp') ? (((nvram['dhcp' + j + '_lease'])*1 == 0) ? '1440' : (nvram['dhcp' + j + '_lease']).toString()) : ''
			] ) ;
			numBridges++;
		}
	}
	lg.canDelete = false;
	lg.sort(0);
	elem.removeClass(lg.header.cells[lg.sortColumn], 'sortasc', 'sortdes');
	lg.showNewEditor();
	lg.resetNewEditor();
}

lg.dataToView = function(data) {
	return ['br' + data[0],
	(data[1].toString() == '1') ? '<small><i>启用</i></small>' : '<small><i>禁用</i></small>',
	data[2],
	data[3],
	(data[4].toString() == '1') ? '<small><i>启用</i></small>' : '<small><i>禁用</i></small>',
	(data[5].toString() + ((numberOfBitsOnNetMask(data[3])>=24) ? (' - ' + data[6].split('.').splice(3, 1).toString()) : ('<br>' + data[6].toString()) )),
	(((data[7] != null) && (data[7] != '')) ? data[7] : '') ];
}

lg.dataToFieldValues = function (data) {
	return [data[0],
	(data[1] != 0) ? 'checked' : '',
	data[2].toString(),
	data[3].toString(),
	(data[4].toString() == '1') ? 'checked' : '',
	data[5].toString(),
	data[6].toString(),
	data[7].toString() ];
}

lg.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return [f[0].value,
	f[1].checked ? 1 : 0,
	f[2].value,
	f[3].value,
	f[4].checked ? 1 : 0,
	f[5].value,
	f[6].value,
	f[7].value ];
}

lg.resetNewEditor = function() {
	var f = fields.getAll(this.newEditor);
	f[0].selectedIndex=0;
	var t = MAX_BRIDGE_ID;
	while((this.countBridge(f[0].selectedIndex) > 0) && (t > 0)) {
		f[0].selectedIndex = (f[0].selectedIndex%(MAX_BRIDGE_ID))+1;
		t--;
	}
	for(var j=0; j<= MAX_BRIDGE_ID ; j++) {
		f[0].options[j].disabled = (this.countBridge(j) > 0);
	}
	f[1].checked = 0;
	f[2].value = '';
	f[3].value = '';
	f[5].value = '';
	f[6].value = '';
	f[7].value = '';
	f[4].checked = 0;
	f[4].disabled = 1;
	f[5].disabled = 1;
	f[6].disabled = 1;
	f[7].disabled = 1;
	ferror.clearAll(fields.getAll(this.newEditor));
}

lg.onCancel = function() {
	this.removeEditor();
	this.showSource();
	this.disableNewEditor(false);

	this.resetNewEditor();
}

lg.onAdd = function() {
	var data;

	this.moving = null;
	this.rpHide();

	if (!this.verifyFields(this.newEditor, false)) return;

	data = this.fieldValuesToData(this.newEditor);
	this.insertData(-1, data);

	this.disableNewEditor(false);
	this.resetNewEditor();

	this.resort();
}

lg.onOK = function() {
	var i, data, view;

	if (!this.verifyFields(this.editor, false)) return;

	data = this.fieldValuesToData(this.editor);
	view = this.dataToView(data);

	this.source.setRowData(data);
	for (i = 0; i < this.source.cells.length; ++i) {
	this.source.cells[i].innerHTML = view[i];
	}

	this.removeEditor();
	this.showSource();
	this.disableNewEditor(false);

	this.resort();
	this.resetNewEditor();
}

lg.onDelete = function() {
	this.removeEditor();
	elem.remove(this.source);
	this.source = null;
	this.disableNewEditor(false);

	this.resetNewEditor();
}

lg.countElem = function(f, v) {
	var data = this.getAllData();
	var total = 0;
	for (var i = 0; i < data.length; ++i) {
		total += (data[i][f] == v) ? 1 : 0;
	}
	return total;
}

lg.countBridge = function (v) {
	return this.countElem(0,v);
}

lg.countOverlappingNetworks = function (ip) {
	var data = this.getAllData();
	var total = 0;
	for (var i = 0; i < data.length; ++i) {
		var net = getNetworkAddress(data[i][2], data[i][3]);
		var brd = getBroadcastAddress(net, data[i][3]);
		total += ((aton(ip) <= aton(brd)) && (aton(ip) >= aton(net))) ? 1 : 0;
	}
	return total;
}

lg.verifyFields = function(row, quiet) {
	var ok=1;
	var f;

	f = fields.getAll(row);

	for(var j=0; j<= MAX_BRIDGE_ID ; j++) {
		f[0].options[j].disabled = (this.countBridge(j) > 0);
	}

	if(this.countBridge(f[0].selectedIndex) > 0) {
		ferror.set(f[0], '无法添加另一个网桥条目' + f[0].selectedIndex, quiet);
		ok = 0;
	} else {
		ferror.clear(f[0]);
	}
// valid IP address? 
	if(!v_ip(f[2], quiet || !ok)) 
		ok = 0;
// if we have a properly defined IP address - 0.0.0.0 is NOT a valid IP address for our intents/purposes!
	if ((f[2].value != '') && (f[2].value != '0.0.0.0')) {
// allow DHCP to be enabled
		f[4].disabled = 0;
// validate netmask
		if(!v_netmask(f[3], quiet || !ok)) {
			return 0;
		} else {
// should be 22 bits or smaller network
			if ((numberOfBitsOnNetMask(f[3].value) < 22) && (nvram.cstats_enable == '1' )) {
				if (!confirm("掩码必须有至少22位（255.255.252.0）。您可以继续操作，但请记住此警告")) return;
			} else {
				ferror.clear(f[3]);
			}
		}
		if(f[2].value == getNetworkAddress(f[2].value, f[3].value)) {
			var s = 'IP地址或子网掩码无效（无法使用的网络地址）';
			ferror.set(f[2], s, quiet);
			ferror.set(f[3], s, quiet);
			return 0;
		} else 
		if(f[2].value == getBroadcastAddress(getNetworkAddress(f[2].value, f[3].value), f[3].value)) {
			var s = 'IP地址或子网掩码无效（广播地址不能使用）';
			ferror.set(f[2], s, quiet);
			ferror.set(f[3], s, quiet);
			return 0;
		} else
		if (this.countOverlappingNetworks(f[2].value) > 0) {
			var s = 'IP地址或子网掩码无效（与另一个网桥冲突/重叠）';
			ferror.set(f[2], s, quiet);
			ferror.set(f[3], s, quiet);
			return 0;
		} else {
			ferror.clear(f[2]);
			ferror.clear(f[3]);
		}
	} else {
		f[4].checked = 0;
		f[4].disabled = 1;
	}
// dhcp enabled?
	if( (f[4].checked) && (v_ip(f[2], 1)) && (v_netmask(f[3],1)) ) {
		f[5].disabled = 0;
		f[6].disabled = 0;
		f[7].disabled = 0;
// first/last IP still unset?
		if (f[5].value == '') {
			var l;
			var m = aton(f[2].value) & aton(f[3].value);
			var o = (m) ^ (~ aton(f[3].value))
			var n = o - m;
			do {
				if (--n < 0) {
					f[5].value = '';
					return;
				}
				m++;
			} while (((l = fixIP(ntoa(m), 1)) == null) || (l == f[2].value) );
			f[5].value = l;
		}
		if (f[6].value == '') {
			var l;
			var m = aton(f[2].value) & aton(f[3].value);
			var o = (m) ^ (~ aton(f[3].value));
			var n = o - m;
			do {
				if (--n < 0) {
					f[6].value = '';
					return;
				}
				o--;
			} while (((l = fixIP(ntoa(o), 1)) == null) || (l == f[2].value) );
			f[6].value = l;
		}
// first IP valid?
		if ((getNetworkAddress(f[5].value, f[3].value) != getNetworkAddress(f[2].value, f[3].value)) ||
			(f[5].value == getBroadcastAddress(getNetworkAddress(f[2].value, f[3].value), f[3].value)) ||
			(f[5].value == getNetworkAddress(f[2].value, f[3].value)) ||
			(f[2].value == f[5].value)) {
			ferror.set(f[5], '第一个IP地址或子网掩码无效', quiet || !ok);
			return 0;
		} else {
			ferror.clear(f[5]);
		}
// last IP valid?
		if ((getNetworkAddress(f[6].value, f[3].value) != getNetworkAddress(f[2].value, f[3].value)) ||
			(f[6].value == getBroadcastAddress(getNetworkAddress(f[2].value, f[3].value), f[3].value)) ||
			(f[6].value == getNetworkAddress(f[2].value, f[3].value)) ||
			(f[2].value == f[6].value)) {
			ferror.set(f[6], '最后一个IP地址或子网掩码无效', quiet || !ok);
			return 0;
		} else {
			ferror.clear(f[6]);
		}
// validate range, swap first/last IP if needed
		if (aton(f[6].value) < aton(f[5].value)) {
			var t = f[5].value;
			f[5].value = f[6].value;
			f[6].value = t;
		}
// lease time
		if (parseInt(f[7].value*1) == 0)
			f[7].value = 1440; // from nvram/defaults.c
		if(!v_mins(f[7], quiet || !ok, 1, 10080)) 
			ok = 0;
	} else {
		f[5].disabled = 1;
		f[6].disabled = 1;
		f[7].disabled = 1;
		ferror.clear(f[5]);
		ferror.clear(f[6]);
		ferror.clear(f[7]);
	}
	return ok;
}

W('<style type=\'text/css\'>');
for (var u = 0; u < wl_ifaces.length; ++u) {
	W('#spin'+wl_unit(u)+', ');
}
W('#spin {');
W('	visibility: hidden;');
W('	vertical-align: middle;');
W('}');
W('</style>');

var xob = null;
var refresher = [];
var nphy = features('11n');

var ghz = [];
var bands = [];
var nm_loaded = [], ch_loaded = [], max_channel = [];

for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//	if(wl_ifaces[uidx][0].indexOf('.') < 0) {
	if (wl_sunit(uidx)<0) {
		var b;
		b = [];
		for (var i = 0; i < wl_bands[uidx].length; ++i) {
			b.push([wl_bands[uidx][i] + '', (wl_bands[uidx][i] == '1') ? '5 GHz' : '2.4 GHz']);
		}
		bands.push(b);

		b = [];
		ghz.push(b);

		nm_loaded.push(0);
		ch_loaded.push(0);
		max_channel.push(0);
		refresher.push(null);
	}
}

function selectedBand(uidx)
{
	if (bands[uidx].length > 1) {
		var e = E('_f_wl'+u+'_nband');
		return (e.value + '' == '' ? eval('nvram.wl'+u+'_nband') : e.value);
	} else if (bands[uidx].length > 0) {
		return bands[uidx][0][0] || '0';
	} else {
		return '0';
	}
}

function refreshNetModes(uidx)
{
	var e, i, buf, val;

	if (uidx >= wl_ifaces.length) return;
	var u = wl_unit(uidx);

	var m = [['mixed','自动']];
	if (selectedBand(uidx) == '1') {
		m.push(['a-only','仅 802.11a']);
		if (nphy) {
			m.push(['n-only','仅 802.11n']);
		}
	}
	else {
		m.push(['b-only','仅 802.11b']);
		m.push(['g-only','仅 802.11g']);
		if (nphy) {
			m.push(['bg-mixed','802.11 b/g']);
			m.push(['n-only','仅 802.11n']);
		}
	}

	e = E('_wl'+u+'_net_mode');
	buf = '';
	val = (!nm_loaded[uidx] || (e.value + '' == '')) ? eval('nvram.wl'+u+'_net_mode') : e.value;
	if (val == 'disabled') val = 'mixed';
	for (i = 0; i < m.length; ++i)
		buf += '<option value="' + m[i][0] + '"' + ((m[i][0] == val) ? ' selected' : '') + '>' + m[i][1] + '</option>';

	e = E('__wl'+u+'_net_mode');
	buf = '<select name="wl'+u+'_net_mode" onchange="verifyFields(this, 1)" id = "_wl'+u+'_net_mode">' + buf + '</select>';
	elem.setInnerHTML(e, buf);
	nm_loaded[uidx] = 1;
}

function refreshChannels(uidx)
{
	if (refresher[uidx] != null) return;
	if (u >= wl_ifaces.length) return;
	var u = wl_unit(uidx);

	refresher[uidx] = new XmlHttp();
	refresher[uidx].onCompleted = function(text, xml) {
		try {
			var e, i, buf, val;

			var wl_channels = [];
			eval(text);

			ghz[uidx] = [];
			max_channel[uidx] = 0;
			for (i = 0; i < wl_channels.length; ++i) {
				ghz[uidx].push([wl_channels[i][0] + '',
					(wl_channels[i][0]) ? ((wl_channels[i][1]) ? wl_channels[i][0] + ' - ' + (wl_channels[i][1] / 1000.0).toFixed(3) + ' GHz' : wl_channels[i][0] + '') : '自动']);
				max_channel[uidx] = wl_channels[i][0] * 1;
			}

			e = E('_wl'+u+'_channel');
			buf = '';
			val = (!ch_loaded[uidx] || (e.value + '' == '')) ? eval('nvram.wl'+u+'_channel') : e.value;
			for (i = 0; i < ghz[uidx].length; ++i)
				buf += '<option value="' + ghz[uidx][i][0] + '"' + ((ghz[uidx][i][0] == val) ? ' selected' : '') + '>' + ghz[uidx][i][1] + '</option>';

			e = E('__wl'+u+'_channel');
			buf = '<select name="wl'+u+'_channel" onchange="verifyFields(this, 1)" id = "_wl'+u+'_channel">' + buf + '</select>';
			elem.setInnerHTML(e, buf);
			ch_loaded[uidx] = 1;

			refresher[uidx] = null;
			verifyFields(null, 1);
		}
		catch (x) {
		}
		refresher[uidx] = null;
	}

	var bw, sb, e;

	e = E('_f_wl'+u+'_nctrlsb');
	sb = (e.value + '' == '' ? eval('nvram.wl'+u+'_nctrlsb') : e.value);
	e = E('_wl'+u+'_nbw_cap');
	bw = (e.value + '' == '' ? eval('nvram.wl'+u+'_nbw_cap') : e.value) == '0' ? '20' : '40';

	refresher[uidx].onError = function(ex) { alert(ex); refresher[uidx] = null; reloadPage(); }
	refresher[uidx].post('update.cgi', 'exec=wlchannels&arg0=' + u + '&arg1=' + (nphy ? '1' : '0') +
		'&arg2=' + bw + '&arg3=' + selectedBand(uidx) + '&arg4=' + sb);
}

function spin(x, unit)
{
	for (var u = 0; u < wl_ifaces.length; ++u) {
		E('_f_wl'+wl_unit(u)+'_scan').disabled = x;
	}
	var e = E('_f_wl'+unit+'_scan');
	if (x) e.value = '扫描' + (wscan.tries + 1);
		else e.value = '扫描';
	E('spin'+unit).style.visibility = x ? 'visible' : 'hidden';
}

function scan()
{
	if (xob) return;

	var unit = wscan.unit;
	var uidx = wl_uidx(unit);

	xob = new XmlHttp();
	xob.onCompleted = function(text, xml) {
		try {
			var i;

			wlscandata = [];
			eval(text);

			for (i = 0; i < wlscandata.length; ++i) {
				var data = wlscandata[i];
				var ch = data[2];
				var mac = data[0];

				if (!wscan.inuse[ch]) {
					wscan.inuse[ch] = {
						count: 0,
						rssi: -999,
						ssid: ''
					};
				}

				if (!wscan.seen[mac]) {
					wscan.seen[mac] = 1;
					++wscan.inuse[ch].count;
				}

				if (data[4] > wscan.inuse[ch].rssi) {
					wscan.inuse[ch].rssi = data[4];
					wscan.inuse[ch].ssid = data[1];
				}
			}
			var e = E('_wl'+unit+'_channel');
			for (i = 1; i < ghz[uidx].length; ++i) {
				var s = ghz[uidx][i][1];
				var u = wscan.inuse[ghz[uidx][i][0]];
				if (u) s += ' (' + u.count + ' AP' + (u.count == 1 ? '' : 's') + ' / 最强："' + escapeHTML(ellipsis(u.ssid, 15)) + '" ' + u.rssi + ' dBm)';
				e.options[i].innerHTML = s;
			}
			e.style.width = '400px';

			xob = null;

			if (wscan.tries < 4) {
				++wscan.tries;
				setTimeout(scan, 1000);
				return;
			}
		}
		catch (x) {
		}
		spin(0, unit);
	}
	xob.onError = function(x) {
		alert('错误：' + x);
		spin(0, unit);
		xob = null;
	}

	spin(1, unit);
	xob.post('update.cgi', 'exec=wlscan&arg0='+unit);
}

function scanButton(u)
{
	if (xob) return;

	wscan = {
		unit: u,
		seen: [],
		inuse: [],
		tries: 0
	};

	scan();
}

function joinAddr(a) {
	var r, i, s;

	r = [];
	for (i = 0; i < a.length; ++i) {
		s = a[i];
		if ((s != '00:00:00:00:00:00') && (s != '0.0.0.0')) r.push(s);
	}
	return r.join(' ');
}

function random_x(max)
{
	var c = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
	var s = '';
	while (max-- > 0) s += c.substr(Math.floor(c.length * Math.random()), 1);
	return s;
}

function random_psk(id)
{
	var e = E(id);
	e.value = random_x(63);
	verifyFields(null, 1);
}

function random_wep(u)
{
	E('_wl'+u+'_passphrase').value = random_x(16);
	generate_wep(u);
}

function v_wep(e, quiet)
{
	var s = e.value;
	
	if (((s.length == 5) || (s.length == 13)) && (s.length == (e.maxLength >> 1))) {
		// no checking
	}
	else {
		s = s.toUpperCase().replace(/[^0-9A-F]/g, '');
		if (s.length != e.maxLength) {
			ferror.set(e, '无效的WEP密钥. 应该是' + e.maxLength + '16进制或者' + (e.maxLength >> 1) + 'ASCII字符', quiet);
			return 0;
		}
	}

	e.value = s;
	ferror.clear(e);
	return 1;
}

// compatible w/ Linksys' and Netgear's (key 1) method for 128-bits
function generate_wep(u)
{
	function _wepgen(pass, i)
	{
		while (pass.length < 64) pass += pass;
		return hex_md5(pass.substr(0, 64)).substr(i, (E('_wl'+u+'_wep_bit').value == 128) ? 26 : 10);
	}

	var e = E('_wl'+u+'_passphrase');
	var pass = e.value;
	if (!v_length(e, false, 3)) return;
	E('_wl'+u+'_key1').value = _wepgen(pass, 0);
	pass += '#$%';
	E('_wl'+u+'_key2').value = _wepgen(pass, 2);
	pass += '!@#';
	E('_wl'+u+'_key3').value = _wepgen(pass, 4);
	pass += '%&^';
	E('_wl'+u+'_key4').value = _wepgen(pass, 6);
	verifyFields(null, 1);
}

function verifyFields(focused, quiet)
{
	var i;
	var ok = 1;
	var a, b, c, d, e;
	var u, uidx;
	var wmode, sm2;

	var n = E('_f_lan_state').checked;
	E('_f_lan_desc').disabled = !n;
	E('_f_lan_invert').disabled = !n;

/* DNSCRYPT-BEGIN */
	var p = E('_f_dnscrypt_proxy').checked;
	E('_dnscrypt_port').disabled = !p;
	E('_dnscrypt_cmd').disabled = !p;
/* DNSCRYPT-END */

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			u = wl_unit(uidx);
			if (focused == E('_f_wl'+u+'_nband')) {
				refreshNetModes(uidx);
				refreshChannels(uidx);
			}
			else if (focused == E('_f_wl'+u+'_nctrlsb') || focused == E('_wl'+u+'_nbw_cap')) {
				refreshChannels(uidx);
			}
		}
	}

	// --- visibility ---

	var vis = {
		_wan_proto: 1,
		_ppp_username: 1,
		_ppp_passwd: 1,
		_ppp_service: 1,
		_ppp_custom: 1,
		_l2tp_server_ip: 1,
		_wan_ipaddr: 1,
		_wan_netmask: 1,
		_wan_gateway: 1,
		_pptp_server_ip: 1,
		_f_pptp_dhcp: 1,
		_ppp_demand: 1,
		_ppp_idletime: 1,
		_ppp_redialperiod: 1,
		_pppoe_lei: 1,
		_pppoe_lef: 1,
		_mtu_enable: 1,
		_f_wan_mtu: 1,
		_f_wan_islan: 0,
		_f_ppp_mlppp: 1,
		_modem_ipaddr: 1,

		_f_dns_1: 1,
		_f_dns_2: 1,
		_f_dns_3: 1,
		_lan_gateway: 1,
		_wan_wins: 1,
		_modem_pin: 1,
		_modem_dev: 1,
		_modem_init: 1,
		_modem_apn: 1
	};

	var wl_vis = [];
	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			a = {
			_f_wl_radio: 1,
			_f_wl_mode: 1,
			_f_wl_nband: (bands[uidx].length > 1) ? 1 : 0,
			_wl_net_mode: 1,
			_wl_ssid: 1,
			_f_wl_bcast: 1,
			_wl_channel: 1,
			_wl_nbw_cap: nphy ? 1 : 0,
			_f_wl_nctrlsb: nphy ? 1 : 0,
			_f_wl_scan: 1,

			_wl_security_mode: 1,
			_wl_crypto: 1,
			_wl_wpa_psk: 1,
			_f_wl_psk_random1: 1,
			_f_wl_psk_random2: 1,
			_wl_wpa_gtk_rekey: 1,
			_wl_radius_key: 1,
			_wl_radius_ipaddr: 1,
			_wl_radius_port: 1,
			_wl_wep_bit: 1,
			_wl_passphrase: 1,
			_f_wl_wep_gen: 1,
			_f_wl_wep_random: 1,
			_wl_key1: 1,
			_wl_key2: 1,
			_wl_key3: 1,
			_wl_key4: 1,

			_f_wl_lazywds: 1,
			_f_wl_wds_0: 1
			};
			wl_vis.push(a);
		}
	}

	var wan = E('_wan_proto').value;

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			wmode = E('_f_wl'+wl_unit(uidx)+'_mode').value;

			if (wmode == 'wet') {
				wan = 'disabled';
				vis._wan_proto = 0;
			}

			if ((wan == 'disabled') || (wmode == 'sta') || (wmode == 'wet')) {
				vis._f_wan_islan = 1;
			}
		}
	}

	switch (wan) {
	case 'disabled':
		vis._ppp_username = 0;
		vis._ppp_service = 0;
		vis._ppp_custom = 0;
		vis._l2tp_server_ip = 0;
		vis._wan_ipaddr = 0;
		vis._wan_netmask = 0;
		vis._wan_gateway = 0;
		vis._pptp_server_ip = 0;
		vis._f_pptp_dhcp = 0;
		vis._ppp_demand = 0;
		vis._mtu_enable = 0;
		vis._f_wan_mtu = 0;
		vis._f_ppp_mlppp = 0;
		vis._modem_ipaddr = 0;
		vis._modem_pin = 0;
		vis._modem_dev = 0;
		vis._modem_init = 0;
		vis._modem_apn = 0;
		vis._pppoe_lei = 0;
		vis._pppoe_lef = 0;
		break;
	case 'dhcp':
		vis._l2tp_server_ip = 0;
		vis._pppoe_lei = 0;
		vis._pppoe_lef = 0;
		vis._ppp_demand = 0;
		vis._ppp_service = 0;
		vis._ppp_username = 0;
		vis._ppp_custom = 0;
		vis._pptp_server_ip = 0;
		vis._f_pptp_dhcp = 0;
		vis._wan_gateway = 0;
		vis._wan_ipaddr = 0;
		vis._wan_netmask = 0;
		vis._f_ppp_mlppp = 0;
		vis._modem_ipaddr = 1;

		vis._lan_gateway = 0;
		vis._modem_pin = 0;
		vis._modem_dev = 0;
		vis._modem_init = 0;
		vis._modem_apn = 0;
		break;
	case 'pppoe':
		vis._l2tp_server_ip = 0;
		vis._pptp_server_ip = 0;
		vis._f_pptp_dhcp = 0;
		vis._wan_gateway = 0;
		vis._wan_ipaddr = 0;
		vis._wan_netmask = 0;
		vis._modem_ipaddr = 1;

		vis._lan_gateway = 0;
		vis._modem_pin = 0;
		vis._modem_dev = 0;
		vis._modem_init = 0;
		vis._modem_apn = 0;
		break;
	case 'ppp3g':
		vis._pppoe_lei = 0;
		vis._pppoe_lef = 0;
		vis._ppp_service = 0;
		vis._l2tp_server_ip = 0;
		vis._pptp_server_ip = 0;
		vis._f_pptp_dhcp = 0;
		vis._wan_gateway = 0;
		vis._wan_ipaddr = 0;
		vis._wan_netmask = 0;
		vis._lan_gateway = 0;
		vis._modem_ipaddr = 0;
		vis._f_ppp_mlppp = 0;
		break;
	case 'static':
		vis._pppoe_lei = 0;
		vis._pppoe_lef = 0;
		vis._l2tp_server_ip = 0;
		vis._ppp_demand = 0;
		vis._ppp_service = 0;
		vis._ppp_username = 0;
		vis._ppp_custom = 0;
		vis._pptp_server_ip = 0;
		vis._f_pptp_dhcp = 0;
		vis._f_ppp_mlppp = 0;
		vis._modem_ipaddr = 1;

		vis._lan_gateway = 0;
		vis._modem_pin = 0;
		vis._modem_dev = 0;
		vis._modem_init = 0;
		vis._modem_apn = 0;
		break;
	case 'pptp':
		vis._pppoe_lei = 0;
		vis._pppoe_lef = 0;
		vis._l2tp_server_ip = 0;
		vis._ppp_service = 0;
		vis._wan_gateway = (!E('_f_pptp_dhcp').checked);
		vis._wan_ipaddr = (!E('_f_pptp_dhcp').checked);
		vis._modem_ipaddr = 0;

		vis._lan_gateway = 0;
		vis._modem_pin = 0;
		vis._modem_dev = 0;
		vis._modem_init = 0;
		vis._modem_apn = 0;
		break;
	case 'l2tp':
		vis._pppoe_lei = 0;
		vis._pppoe_lef = 0;
		vis._pptp_server_ip = 0;
		vis._ppp_service = 0;
		vis._wan_gateway = (!E('_f_pptp_dhcp').checked);
		vis._wan_ipaddr = (!E('_f_pptp_dhcp').checked);
		vis._modem_ipaddr = 0;

		vis._lan_gateway = 0;
		vis._modem_pin = 0;
		vis._modem_dev = 0;
		vis._modem_init = 0;
		vis._modem_apn = 0;
		break;
	}

	vis._ppp_idletime = (E('_ppp_demand').value == 1) && vis._ppp_demand
	vis._ppp_redialperiod = !vis._ppp_idletime && vis._ppp_demand;

	if (vis._mtu_enable) {
		if (E('_mtu_enable').value == 0) {
			vis._f_wan_mtu = 2;
			a = E('_f_wan_mtu');
			switch (E('_wan_proto').value) {
			case 'pppoe':
				a.value = 1492;
				break;
			case 'pptp':
			case 'l2tp':
				a.value = 1460;
				break;
			 default:
				a.value = 1500;
				break;
			}
		}
	}

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			u = wl_unit(uidx);
			wmode = E('_f_wl'+u+'_mode').value;

			if (!E('_f_wl'+u+'_radio').checked) {
				for (a in wl_vis[uidx]) {
					wl_vis[uidx][a] = 2;
				}
				wl_vis[uidx]._f_wl_radio = 1;
				wl_vis[uidx]._wl_nbw_cap = nphy ? 2 : 0;
				wl_vis[uidx]._f_wl_nband = (bands[uidx].length > 1) ? 2 : 0;
			}

			switch (wmode) {
			case 'apwds':
			case 'wds':
				break;
			case 'wet':
			case 'sta':
				wl_vis[uidx]._f_wl_bcast = 0;
				wl_vis[uidx]._wl_channel = 0;
				wl_vis[uidx]._wl_nbw_cap = 0;
				vis._modem_ipaddr = 0;
			default:
				wl_vis[uidx]._f_wl_lazywds = 0;
				wl_vis[uidx]._f_wl_wds_0 = 0;
				break;
			}

			sm2 = E('_wl'+u+'_security_mode').value;
			switch (sm2) {
			case 'disabled':
				wl_vis[uidx]._wl_crypto = 0;
				wl_vis[uidx]._wl_wep_bit = 0;
				wl_vis[uidx]._wl_wpa_psk = 0;
				wl_vis[uidx]._wl_radius_key = 0;
				wl_vis[uidx]._wl_radius_ipaddr = 0;
				wl_vis[uidx]._wl_wpa_gtk_rekey = 0;
				break;
			case 'wep':
				wl_vis[uidx]._wl_crypto = 0;
				wl_vis[uidx]._wl_wpa_psk = 0;
				wl_vis[uidx]._wl_radius_key = 0;
				wl_vis[uidx]._wl_radius_ipaddr = 0;
				wl_vis[uidx]._wl_wpa_gtk_rekey = 0;
				break;
			case 'radius':
				wl_vis[uidx]._wl_crypto = 0;
				wl_vis[uidx]._wl_wpa_psk = 0;
				break;
			default:	// wpa*
				wl_vis[uidx]._wl_wep_bit = 0;
				if (sm2.indexOf('personal') != -1) {
					wl_vis[uidx]._wl_radius_key = 0;
					wl_vis[uidx]._wl_radius_ipaddr = 0;
				}
				else {
					wl_vis[uidx]._wl_wpa_psk = 0;
				}
				break;
			}

			if ((E('_f_wl'+u+'_lazywds').value == 1) && (wl_vis[uidx]._f_wl_wds_0 == 1)) {
				wl_vis[uidx]._f_wl_wds_0 = 2;
			}

			if (wl_vis[uidx]._wl_nbw_cap != 0) {
				switch (E('_wl'+u+'_net_mode').value) {
				case 'b-only':
				case 'g-only':
				case 'a-only':
				case 'bg-mixed':
					wl_vis[uidx]._wl_nbw_cap = 2;
					if (E('_wl'+u+'_nbw_cap').value != '0') {
						E('_wl'+u+'_nbw_cap').value = 0;
						refreshChannels(uidx);
					}
					break;
				}
				// avoid Enterprise-TKIP with 40MHz
				if ((sm2 == 'wpa_enterprise') && (E('_wl'+u+'_crypto').value == 'tkip')) {
					wl_vis[uidx]._wl_nbw_cap = 2;
					if (E('_wl'+u+'_nbw_cap').value != '0') {
						E('_wl'+u+'_nbw_cap').value = 0;
						refreshChannels(uidx);
					}
				}
			}

			wl_vis[uidx]._f_wl_nctrlsb = (E('_wl'+u+'_nbw_cap').value == 0) ? 0 : wl_vis[uidx]._wl_nbw_cap;

/* REMOVE-BEGIN
	This is ugly...
	Special case - 2.4GHz band, currently running in B/G-only mode,
	with N/Auto and 40MHz selected in the GUI.
	Channel list is not filtered in this case by the wl driver,
	and includes all channels available with 20MHz channel width.
REMOVE-END */
			b = selectedBand(uidx);
			if (wl_vis[uidx]._wl_channel == 1 && wl_vis[uidx]._f_wl_nctrlsb != 0 &&
			   ((b == '2') || (wl_vis[uidx]._f_wl_nband == 0 && b == '0'))) {
				switch (eval('nvram.wl'+u+'_net_mode')) {
				case 'b-only':
				case 'g-only':
				case 'bg-mixed':
					i = E('_wl'+u+'_channel').value * 1;
					if (i > 0 && i < 5) {
						E('_f_wl'+u+'_nctrlsb').value = 'lower';
						wl_vis[uidx]._f_wl_nctrlsb = 2;
					}
					else if (i > max_channel[uidx] - 4) {
						E('_f_wl'+u+'_nctrlsb').value = 'upper';
						wl_vis[uidx]._f_wl_nctrlsb = 2;
					}
					break;
				}
			}

			wl_vis[uidx]._f_wl_scan = wl_vis[uidx]._wl_channel;
			wl_vis[uidx]._f_wl_psk_random1 = wl_vis[uidx]._wl_wpa_psk;
			wl_vis[uidx]._f_wl_psk_random2 = wl_vis[uidx]._wl_radius_key;
			wl_vis[uidx]._wl_radius_port = wl_vis[uidx]._wl_radius_ipaddr;
			wl_vis[uidx]._wl_key1 = wl_vis[uidx]._wl_key2 = wl_vis[uidx]._wl_key3 = wl_vis[uidx]._wl_key4 = wl_vis[uidx]._f_wl_wep_gen = wl_vis[uidx]._f_wl_wep_random = wl_vis[uidx]._wl_passphrase = wl_vis[uidx]._wl_wep_bit;

			for (i = 1; i < 10; ++i) {
				wl_vis[uidx]['_f_wl_wds_' + i] = wl_vis[uidx]._f_wl_wds_0;
			}
		}
	} // for each wl_iface

	vis._ppp_passwd = vis._ppp_username;

	for (a in vis) {
		b = E(a);
		c = vis[a];
/* REMOVE-BEGIN
//		if (b != null)
REMOVE-END */
			b.disabled = (c != 1);
		PR(b).style.display = c ? '' : 'none';
	}

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
			for (a in wl_vis[uidx]) {
				i = 3;
				if (a.substr(0, 6) == '_f_wl_') i = 5;
				b = E(a.substr(0, i) + wl_unit(uidx) + a.substr(i, a.length));
				c = wl_vis[uidx][a];
				b.disabled = (c != 1);
				PR(b).style.display = c ? '' : 'none';
			}
		}
	}

	// --- verify ---

	ferror.clear('_wan_proto');

	var wlclnt = 0;
	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			u = wl_unit(uidx);
			wmode = E('_f_wl'+u+'_mode').value;
			sm2 = E('_wl'+u+'_security_mode').value;

/* REMOVE-BEGIN
			if ((wl_vis[uidx]._f_wl_mode == 1) && (wmode != 'ap') && (sm2.substr(0, 4) == 'wpa2')) {
				ferror.set('_wl'+u+'_security_mode', 'WPA2 is supported only in AP mode.', quiet || !ok);
				ok = 0;
			}
			else ferror.clear('_wl'+u+'_security_mode');
REMOVE-END */

			// --- N standard does not support WPA+TKIP ---
			a = E('_wl'+u+'_crypto');
			switch (E('_wl'+u+'_net_mode').value) {
			case 'mixed':
			case 'n-only':
				if (nphy && (a.value == 'tkip') && (sm2.indexOf('wpa') != -1)) {
					ferror.set(a, 'WPA/WPA2 在N模式下不支持TKIP加密', quiet || !ok);
					ok = 0;
				}
				else ferror.clear(a);
				break;
			}

			a = E('_wl'+u+'_net_mode');
			ferror.clear(a);
			b = E('_f_wl'+u+'_mode');
			ferror.clear(b);
			if ((wmode == 'sta') || (wmode == 'wet')) {
				++wlclnt;
				if (wlclnt > 1) {
					ferror.set(b, '仅一个无线接口可配置成客户端模式', quiet || !ok);
					ok = 0;
				}
				else if (a.value == 'n-only') {
					ferror.set(a, '仅N方式 不支持无线客户端模式，请使用 自动 方式', quiet || !ok);
					ok = 0;
				}
			}

			a = E('_wl'+u+'_wpa_psk');
			ferror.clear(a);
			if (wl_vis[uidx]._wl_wpa_psk == 1) {
				if ((a.value.length < 8) || ((a.value.length == 64) && (a.value.search(/[^0-9A-Fa-f]/) != -1))) {
					ferror.set('_wl'+u+'_wpa_psk', '无效的预共享密钥. 请输入至少8个字符或64个16进制数..', quiet || !ok);
					ok = 0;
				}
			}

			// wl channel
			if (((wmode == 'wds') || (wmode == 'apwds')) && (wl_vis[uidx]._wl_channel == 1) && (E('_wl'+u+'_channel').value == '0')) {
				ferror.set('_wl'+u+'_channel', '固定的无线频道需要WDS模式', quiet || !ok);
				ok = 0;
			}
			else ferror.clear('_wl'+u+'_channel');

			if (E('_f_wl'+u+'_mode').value == 'sta') {
				if ((wan == 'disabled') && (E('_f_wl'+u+'_radio').checked)) {
					ferror.set('_wan_proto', '无线客户端模式需要一个有效的WAN设置（通常使用DHCP）', quiet || !ok);
					ok = 0;
				}
			}
		}
	}

	// domain name or IP address
	a = ['_l2tp_server_ip', '_pptp_server_ip'];
	for (i = a.length - 1; i >= 0; --i)
		if ((vis[a[i]]) && ((!v_length(a[i], 1, 1)) || ((!v_ip(a[i], 1)) && (!v_domain(a[i], 1))))) {
			if (!quiet && ok) ferror.show(a[i]);
			ok = 0;
		}

	// IP address
	a = ['_wan_gateway','_wan_ipaddr'];
	for (i = a.length - 1; i >= 0; --i)
		if ((vis[a[i]]) && (!v_ip(a[i], quiet || !ok))) ok = 0;

	// IP address, blank -> 0.0.0.0
	a = ['_f_dns_1', '_f_dns_2', '_f_dns_3','_wan_wins','_lan_gateway', '_modem_ipaddr'];
	for (i = a.length - 1; i >= 0; --i)
		if ((vis[a[i]]) && (!v_dns(a[i], quiet || !ok))) ok = 0;

	// netmask
	a = ['_wan_netmask'];
	for (i = a.length - 1; i >= 0; --i)
		if ((vis[a[i]]) && (!v_netmask(a[i], quiet || !ok))) ok = 0;

	// range
	a = [['_ppp_idletime', 3, 1440],['_ppp_redialperiod', 1, 86400],['_f_wan_mtu', 576, 1500],
		['_pppoe_lei', 1, 60],['_pppoe_lef', 1, 10]];
	for (i = a.length - 1; i >= 0; --i) {
		v = a[i];
		if ((vis[v[0]]) && (!v_range(v[0], quiet || !ok, v[1], v[2]))) ok = 0;
	}

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			u = wl_unit(uidx);

			// IP address
			a = ['_radius_ipaddr'];
			for (i = a.length - 1; i >= 0; --i) {
				if ((wl_vis[uidx]['_wl'+a[i]]) && (!v_ip('_wl'+u+a[i], quiet || !ok))) ok = 0;
			}

			// range
			a = [['_wpa_gtk_rekey', 60, 7200], ['_radius_port', 1, 65535]];
			for (i = a.length - 1; i >= 0; --i) {
				v = a[i];
				if ((wl_vis[uidx]['_wl'+v[0]]) && (!v_range('_wl'+u+v[0], quiet || !ok, v[1], v[2]))) ok = 0;
			}

			// length
			a = [['_ssid', 1], ['_radius_key', 1]];
			for (i = a.length - 1; i >= 0; --i) {
				v = a[i];
				if ((wl_vis[uidx]['_wl'+v[0]]) && (!v_length('_wl'+u+v[0], quiet || !ok, v[1], E('_wl'+u+v[0]).maxlength))) ok = 0;
			}

			if (wl_vis[uidx]._wl_key1) {
				a = (E('_wl'+u+'_wep_bit').value == 128) ? 26 : 10;
				for (i = 1; i <= 4; ++i) {
					b = E('_wl'+u+'_key' + i);
					b.maxLength = a;
					if ((b.value.length > 0) || (E('_f_wl'+u+'_wepidx_' + i).checked)) {
						if (!v_wep(b, quiet || !ok)) ok = 0;
					}
					else ferror.clear(b);
				}
			}

			ferror.clear('_f_wl'+u+'_wds_0');
			if (wl_vis[uidx]._f_wl_wds_0 == 1) {
				b = 0;
				for (i = 0; i < 10; ++i) {
					a = E('_f_wl'+u+'_wds_' + i);
					if (!v_macz(a, quiet || !ok)) ok = 0;
						else if (!isMAC0(a.value)) b = 1;
				}
				if (!b) {
					ferror.set('_f_wl'+u+'_wds_0', 'WDS MAC地址需要设置', quiet || !ok);
					ok = 0;
				}
			}
		}
	}

	return ok;
}

function earlyInit()
{
	verifyFields(null, 1);
}

function save()
{
	if (lg.isEditing()) return;
	lg.resetNewEditor();

	var a, b, c;
	var i;
	var u, uidx, wmode, sm2, wradio;

	if (!verifyFields(null, false)) return;

	var fom = E('_fom');

	fom.wan_mtu.value = fom.f_wan_mtu.value;
	fom.wan_mtu.disabled = fom.f_wan_mtu.disabled;

	for (uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			u = wl_unit(uidx);
			wmode = E('_f_wl'+u+'_mode').value;
			sm2 = E('_wl'+u+'_security_mode').value;
			wradio = E('_f_wl'+u+'_radio').checked;

			E('_wl'+u+'_nband').value = selectedBand(uidx);

			if (wmode == 'apwds') E('_wl'+u+'_mode').value = 'ap';
			else E('_wl'+u+'_mode').value = wmode;

			if (wmode == 'wet') {
				fom.wan_proto.value = 'disabled';
				fom.wan_proto.disabled = 0;
/* REMOVE-BEGIN */
// TODO - what's required ? integrate with tomatogrid?
/* REMOVE-END */
		}

			a = [];
			for (i = 0; i < 10; ++i) a.push(E('_f_wl'+u+'_wds_' + i).value);
			E('_wl'+u+'_wds').value = joinAddr(a);

			if (wmode.indexOf('wds') != -1) {
				E('_wl'+u+'_wds_enable').value = 1;
				E('_wl'+u+'_lazywds').value = E('_f_wl'+u+'_lazywds').value;
				if (E('_wl'+u+'_lazywds').value == 1) E('_wl'+u+'_wds').value = '';
			}
			else {
				E('_wl'+u+'_wds_enable').value = 0;
				E('_wl'+u+'_wds').value = '';
				E('_wl'+u+'_lazywds').value = 0;
			}

			E('_wl'+u+'_radio').value = wradio ? 1 : 0;
			E('_wl'+u+'_auth').value = eval('nvram.wl'+u+'_auth');

			e = E('_wl'+u+'_akm');
			switch (sm2) {
			case 'disabled':
			case 'radius':
			case 'wep':
				e.value = '';
				break;
			default:
				c = [];

				if (sm2.indexOf('personal') != -1) {
					if (sm2.indexOf('wpa2_') == -1) c.push('psk');
					if (sm2.indexOf('wpa_') == -1) c.push('psk2');
				}
				else {
					if (sm2.indexOf('wpa2_') == -1) c.push('wpa');
					if (sm2.indexOf('wpa_') == -1) c.push('wpa2');
				}
				c = c.join(' ');
				e.value = c;
				break;
			}
			E('_wl'+u+'_auth_mode').value = (sm2 == 'radius') ? 'radius' : 'none';
			E('_wl'+u+'_wep').value = ((sm2 == 'radius') || (sm2 == 'wep')) ? 'enabled': 'disabled';

			if (sm2.indexOf('wpa') != -1) E('_wl'+u+'_auth').value = 0;

			E('_wl'+u+'_nreqd').value = 0;
			E('_wl'+u+'_gmode').value = 1;
			E('_wl'+u+'_nmode').value = 0;
			E('_wl'+u+'_nmcsidx').value = -2; // Legacy Rate
			E('_wl'+u+'_nbw').value = 0;
			switch (E('_wl'+u+'_net_mode').value) {
			case 'b-only':
				E('_wl'+u+'_gmode').value = 0;
				break;
			case 'g-only':
				E('_wl'+u+'_gmode').value = 4;
				break;
			case 'bg-mixed':
				break;
			case 'a-only':
				E('_wl'+u+'_nmcsidx').value = -1; // Auto
				break;
			case 'n-only':
				if (selectedBand(uidx) == '1') { // 5 GHz
					E('_wl'+u+'_nmode').value = -1;
					E('_wl'+u+'_nmcsidx').value = -1;
				} else {
					E('_wl'+u+'_nmode').value = 1;
					E('_wl'+u+'_nmcsidx').value = 32;
				}
				E('_wl'+u+'_nreqd').value = 1;
				break;
			default: // Auto
				E('_wl'+u+'_nmode').value = -1;
				E('_wl'+u+'_nmcsidx').value = -1;
				break;
			}

			E('_wl'+u+'_nctrlsb').value = eval('nvram.wl'+u+'_nctrlsb');
			if (E('_wl'+u+'_nmode').value != 0) {
				E('_wl'+u+'_nctrlsb').value = E('_f_wl'+u+'_nctrlsb').value;
				E('_wl'+u+'_nbw').value = (E('_wl'+u+'_nbw_cap').value == 0) ? 20 : 40;
			}

			E('_wl'+u+'_closed').value = E('_f_wl'+u+'_bcast').checked ? 0 : 1;

			a = fields.radio.selected(eval('fom.f_wl'+u+'_wepidx'));
			if (a) E('_wl'+u+'_key').value = a.value;
		}
	}

	fom.wan_islan.value = fom.f_wan_islan.checked ? 1 : 0;
	fom.pptp_dhcp.value = fom.f_pptp_dhcp.checked ? 1 : 0;

	fom.wan_dns.value = joinAddr([fom.f_dns_1.value, fom.f_dns_2.value, fom.f_dns_3.value]);

/* DNSCRYPT-BEGIN */
	fom.dnscrypt_proxy.value = fom.f_dnscrypt_proxy.checked ? 1 : 0;
/* DNSCRYPT-END */

	fom.lan_state.value = fom.f_lan_state.checked ? 1 : 0;
	fom.lan_desc.value = fom.f_lan_desc.checked ? 1 : 0;
	fom.lan_invert.value = fom.f_lan_invert.checked ? 1 : 0;

// initialize/wipe out relevant fields
	for (var i = 0 ; i <= MAX_BRIDGE_ID ; i++) {
		var j = (i == 0) ? '' : i.toString();
		fom['lan' + j + '_ifname'].value = '';
		fom['lan' + j + '_ipaddr'].value = '';
		fom['lan' + j + '_netmask'].value = '';
		fom['lan' + j + '_proto'].value = '';
		fom['lan' + j + '_stp'].value = '';
		fom['dhcp' + j + '_start'].value = '';
		fom['dhcp' + j + '_num'].value = '';
		fom['dhcp' + j + '_lease'].value = '';
		fom['dhcpd' + j + '_startip'].value = '';
		fom['dhcpd' + j + '_endip'].value = '';
	}

	var d = lg.getAllData();
	for (var i = 0; i < d.length; ++i) {

		if (lg.countOverlappingNetworks(d[i][2]) > 1) {
			var s = '无法继续：两个或更多的的LAN接口的网桥会导致IP地址或子网掩码冲突';
			alert(s);
			var e = E('footer-msg');
			e.innerHTML = s;
			e.style.visibility = 'visible';
			setTimeout(
				function() {
					e.innerHTML = '';
					e.style.visibility = 'hidden';
				}, 5000);
			return;
		}

		var j = (parseInt(d[i][0]) == 0) ? '' : d[i][0].toString();
		fom['lan' + j + '_ifname'].value = 'br' + d[i][0];
		fom['lan' + j + '_stp'].value = d[i][1];
		fom['lan' + j + '_ipaddr'].value = d[i][2];
		fom['lan' + j + '_netmask'].value = d[i][3];
		fom['lan' + j + '_proto'].value = (d[i][4] != '0') ? 'dhcp' : 'static';
		fom['dhcp' + j + '_start'].value = (d[i][4] != '0') ? (d[i][5]).split('.').splice(3, 1) : '';
		fom['dhcp' + j + '_num'].value = (d[i][4] != '0') ? d[i][6].split('.').splice(3, 1) - (d[i][5]).split('.').splice(3, 1) + 1 : ''; // presuming /24 subnet (legacy)
		fom['dhcp' + j + '_lease'].value = (d[i][4] != '0') ? d[i][7] : '';
		fom['dhcpd' + j + '_startip'].value = (d[i][4] != '0') ? d[i][5] : '';
		fom['dhcpd' + j + '_endip'].value = (d[i][4] != '0') ? d[i][6] : '';

/* REMOVE-BEGIN */
alert('lan' + j + '_ifname=' + fom['lan' + j + '_ifname'].value + '\n' +
	'lan' + j + '_stp=' + fom['lan' + j + '_stp'].value + '\n' +
	'lan' + j + '_ipaddr=' + fom['lan' + j + '_ipaddr'].value + '\n' +
	'lan' + j + '_netmask=' + fom['lan' + j + '_netmask'].value + '\n' +
	'lan' + j + '_proto=' + fom['lan' + j + '_proto'].value + '\n' +
	'dhcp' + j + '_start=' + fom['dhcp' + j + '_start'].value + '\n' +
	'dhcp' + j + '_num=' + fom['dhcp' + j + '_num'].value + '\n' +
	'dhcp' + j + '_lease=' + fom['dhcp' + j + '_lease'].value + '\n' +
	'dhcpd' + j + '_startip=' + fom['dhcpd' + j + '_startip'].value + '\n' +
	'dhcpd' + j + '_endip=' + fom['dhcpd' + j + '_endip'].value);
/* REMOVE-END */
	}

	var e = E('footer-msg');
	var t = fixIP(fom['lan_ipaddr'].value);
	if ((fom['lan_ifname'].value != 'br0') || (fom['lan_ipaddr'].value == '0.0.0.0') || (!t)) {
		e.innerHTML = '网桥br0必须设置为一个有效的IP地址';
		e.style.visibility = 'visible';
		setTimeout(
			function() {
				e.innerHTML = '';
				e.style.visibility = 'hidden';
				}, 5000);
		return;
	}

/* REMOVE-BEGIN
//	if ((nvram.lan_ipaddr != fom.lan_ipaddr.value) || (nvram.lan1_ipaddr != fom.lan1_ipaddr.value) ||
//		(nvram.lan2_ipaddr != fom.lan2_ipaddr.value) || (nvram.lan3_ipaddr != fom.lan3_ipaddr.value)){
REMOVE-END */

	fom.ppp_mlppp.value = fom.f_ppp_mlppp.checked ? 1 : 0;

	if (nvram.lan_ipaddr != fom.lan_ipaddr.value) {
		fom._moveip.value = 1;
		form.submit(fom);
	}
	else {
		form.submit(fom, 1);
	}
}

function init()
{
	for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//		if(wl_ifaces[uidx][0].indexOf('.') < 0) {
		if (wl_sunit(uidx)<0) {
			refreshNetModes(uidx);
			refreshChannels(uidx);
		}
	}
}
</script>

</head>
<body onload='init()'>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' class="table" cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='basic-network.asp'>
<input type='hidden' name='_nextwait' value='10'>
<input type='hidden' name='_service' value='*'>
<input type='hidden' name='_moveip' value='0'>

<input type='hidden' name='wan_mtu'>
<input type='hidden' name='wan_islan'>
<input type='hidden' name='pptp_dhcp'>
<input type='hidden' name='wan_dns'>
<input type='hidden' name='ppp_mlppp'>
/* DNSCRYPT-BEGIN */
<input type='hidden' name='dnscrypt_proxy'>
/* DNSCRYPT-END */
<input type='hidden' name='lan_state'>
<input type='hidden' name='lan_desc'>
<input type='hidden' name='lan_invert'>

<script type='text/javascript'>

for (var i = 0 ; i <= MAX_BRIDGE_ID ; i++) {
var j = (i == 0) ? '' : i.toString();
W('<input type=\'hidden\' id=\'lan' + j + '_ifname\' name=\'lan' + j + '_ifname\'>');
W('<input type=\'hidden\' id=\'lan' + j + '_ipaddr\' name=\'lan' + j + '_ipaddr\'>');
W('<input type=\'hidden\' id=\'lan' + j + '_netmask\' name=\'lan' + j + '_netmask\'>');
W('<input type=\'hidden\' id=\'lan' + j + '_proto\' name=\'lan' + j + '_proto\'>');
W('<input type=\'hidden\' id=\'lan' + j + '_stp\' name=\'lan' + j + '_stp\'>');
W('<input type=\'hidden\' id=\'dhcp' + j + '_start\' name=\'dhcp' + j + '_start\'>');
W('<input type=\'hidden\' id=\'dhcp' + j + '_num\' name=\'dhcp' + j + '_num\'>');
W('<input type=\'hidden\' id=\'dhcp' + j + '_lease\' name=\'dhcp' + j + '_lease\'>');
W('<input type=\'hidden\' id=\'dhcpd' + j + '_startip\' name=\'dhcpd' + j + '_startip\'>');
W('<input type=\'hidden\' id=\'dhcpd' + j + '_endip\' name=\'dhcpd' + j + '_endip\'>');
}
</script>

<div class='section-title'>WAN / Internet设置</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '类型', name: 'wan_proto', type: 'select', options: [['dhcp','DHCP'],['pppoe','PPPoE'],['static','Static'],['pptp','PPTP'],['l2tp','L2TP'],
/* LINUX26-BEGIN */
/* USB-BEGIN */
		['ppp3g','3G Modem'],
/* USB-END */
/* LINUX26-END */
		['disabled','禁用']],
		value: nvram.wan_proto },
	{ title: '上网卡设备', name: 'modem_dev', type: 'select', options: [['ttyUSB0', '/dev/ttyUSB0'],['ttyUSB1', '/dev/ttyUSB1'],['ttyUSB2', '/dev/ttyUSB2'],['ttyUSB3', '/dev/ttyUSB3'],['ttyUSB4', '/dev/ttyUSB4'],['ttyUSB5', '/dev/ttyUSB5'],['ttyUSB6', '/dev/ttyUSB6'],['ttyACM0', '/dev/ttyACM0']], value: nvram.modem_dev },
	{ title: 'PIN 码', name: 'modem_pin', type: 'text', maxlen: 6, size: 8, value: nvram.modem_pin },
	{ title: '拨号号码', name: 'modem_init', type: 'text', maxlen: 25, size: 32, value: nvram.modem_init },
	{ title: '接入点APN', name: 'modem_apn', type: 'text', maxlen: 25, size: 32, value: nvram.modem_apn },
	{ title: '用户名', name: 'ppp_username', type: 'text', maxlen: 60, size: 64, value: nvram.ppp_username },
	{ title: '密码', name: 'ppp_passwd', type: 'password', maxlen: 60, size: 64, peekaboo: 1, value: nvram.ppp_passwd },
	{ title: '服务名称', name: 'ppp_service', type: 'text', maxlen: 50, size: 64, value: nvram.ppp_service },
	{ title: 'L2TP服务器', name: 'l2tp_server_ip', type: 'text', maxlen: 128, size: 64, value: nvram.l2tp_server_ip },
	{ title: '使用DHCP', name: 'f_pptp_dhcp', type: 'checkbox', value: (nvram.pptp_dhcp == 1) },
	{ title: 'IP 地址', name: 'wan_ipaddr', type: 'text', maxlen: 15, size: 17, value: nvram.wan_ipaddr },
	{ title: '子网掩码', name: 'wan_netmask', type: 'text', maxlen: 15, size: 17, value: nvram.wan_netmask },
	{ title: '网关', name: 'wan_gateway', type: 'text', maxlen: 15, size: 17, value: nvram.wan_gateway },
	{ title: 'PPTP网关', name: 'pptp_server_ip', type: 'text', maxlen: 128, size: 64, value: nvram.pptp_server_ip },
	{ title: '选项', name: 'ppp_custom', type: 'text', maxlen: 256, size: 64, value: nvram.ppp_custom },
	{ title: '连接模式', name: 'ppp_demand', type: 'select', options: [['1', '按需要连接'],['0', '一直连接']],
		value: nvram.ppp_demand },
	{ title: '最大空闲时间', indent: 2, name: 'ppp_idletime', type: 'text', maxlen: 5, size: 7, suffix: ' <i>(分)</i>',
		value: nvram.ppp_idletime },
	{ title: '重拨间隔', indent: 2, name: 'ppp_redialperiod', type: 'text', maxlen: 5, size: 7, suffix: ' <i>(秒)</i>',
		value: nvram.ppp_redialperiod },
	{ title: 'LCP回应间隔', indent: 2, name: 'pppoe_lei', type: 'text', maxlen: 5, size: 7, suffix: ' <i>秒 (范围: 1 - 60; 默认: 10)</i>',
		value: nvram.pppoe_lei },
	{ title: 'LCP无响应次数限制', indent: 2, name: 'pppoe_lef', type: 'text', maxlen: 5, size: 7, suffix: ' <i>(范围: 1 - 10; 默认: 5)</i>',
		value: nvram.pppoe_lef },
	{ title: 'MTU设置', multi: [
		{ name: 'mtu_enable', type: 'select', options: [['0', '默认'],['1','手动']], value: nvram.mtu_enable },
		{ name: 'f_wan_mtu', type: 'text', maxlen: 4, size: 6, value: nvram.wan_mtu } ] },
	{ title: '单线MLPPP', name: 'f_ppp_mlppp', type: 'checkbox', value: (nvram.ppp_mlppp == 1) },

	{ title: '路由Modem的IP地址', name: 'modem_ipaddr', type: 'text', maxlen: 15, size: 17, suffix: ' <i>（必须设定与路由器不同的子网, 0.0.0.0表示禁用）</i>', value: nvram.modem_ipaddr },

	{ title: '桥接WAN口到主LAN口 (br0)', name: 'f_wan_islan', type: 'checkbox', value: (nvram.wan_islan == 1) }
]);

</script>
</div>

<div class='section-title'>LAN设置</div>
<div class='section'>
	<table 

class='table table-bordered table-striped' cellspacing=1 id='lan-grid'></table>

	<script type='text/javascript'>lg.setup();</script>

<script type='text/javascript'>
dns = nvram.wan_dns.split(/\s+/);
/* REMOVE-BEGIN
//ipp = nvram.lan_ipaddr.split('.').splice(0, 3).join('.');
REMOVE-END */
createFieldTable('', [
	{ title: '默认网关', name: 'lan_gateway', type: 'text', maxlen: 15, size: 17, value: nvram.lan_gateway },
	{ title: '静态DNS服务器', suffix: '&nbsp; <i>(IP：端口)</i>', name: 'f_dns_1', type: 'text', maxlen: 21, size: 25, value: dns[0] || '0.0.0.0' },
	{ title: '', name: 'f_dns_2', type: 'text', maxlen: 21, size: 25, value: dns[1] || '0.0.0.0' },
	{ title: '', name: 'f_dns_3', type: 'text', maxlen: 21, size: 25, value: dns[2] || '0.0.0.0' },
/* DNSCRYPT-BEGIN */
	{ title: '加密DNS代理', name: 'f_dnscrypt_proxy', type: 'checkbox', value: (nvram.dnscrypt_proxy == 1) },
	{ title: '本地端口', indent: 2, name: 'dnscrypt_port', type: 'text', maxlen: 5, size: 7, value: nvram.dnscrypt_port },
	{ title: '启动参数', indent: 2, name: 'dnscrypt_cmd', type: 'text', maxlen: 256, size: 64, value: nvram.dnscrypt_cmd, suffix: ' <i>（可选）</i>' },
/* DNSCRYPT-END */
	{ title: 'WINS <i>（使用DHCP）</i>', name: 'wan_wins', type: 'text', maxlen: 15, size: 17, value: nvram.wan_wins }
]);
</script>
</div>

<div class='section-title'>网卡接口状态 - 配置</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用端口状态', name: 'f_lan_state', type: 'checkbox', value: (nvram.lan_state == 1) },
	{ title: '显示速度信息', indent: 2, name: 'f_lan_desc', type: 'checkbox', value: (nvram.lan_desc == 1) },
	{ title: '反转端口顺序', indent: 2, name: 'f_lan_invert', type: 'checkbox', value: (nvram.lan_invert == 1) }
]);
</script>
</div>

<script type='text/javascript'>

for (var uidx = 0; uidx < wl_ifaces.length; ++uidx) {
//if(wl_ifaces[uidx][0].indexOf('.') < 0) {
if (wl_sunit(uidx)<0) {
	var u = wl_unit(uidx);

	W('<input type=\'hidden\' id=\'_wl'+u+'_mode\' name=\'wl'+u+'_mode\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_nband\' name=\'wl'+u+'_nband\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_wds_enable\' name=\'wl'+u+'_wds_enable\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_wds\' name=\'wl'+u+'_wds\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_radio\' name=\'wl'+u+'_radio\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_closed\' name=\'wl'+u+'_closed\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_key\' name=\'wl'+u+'_key\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_gmode\' name=\'wl'+u+'_gmode\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_akm\' name=\'wl'+u+'_akm\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_auth\' name=\'wl'+u+'_auth\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_auth_mode\' name=\'wl'+u+'_auth_mode\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_wep\' name=\'wl'+u+'_wep\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_lazywds\' name=\'wl'+u+'_lazywds\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_nmode\' name=\'wl'+u+'_nmode\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_nmcsidx\' name=\'wl'+u+'_nmcsidx\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_nreqd\' name=\'wl'+u+'_nreqd\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_nctrlsb\' name=\'wl'+u+'_nctrlsb\'>');
	W('<input type=\'hidden\' id=\'_wl'+u+'_nbw\' name=\'wl'+u+'_nbw\'>');

	W('<div class=\'section-title\'>无线设置');
//	if (wl_ifaces.length > 1)
		W(' (' + wl_display_ifname(uidx) + ')');
	W('</div>');

	W('<div class=\'section\'>');

	f = [
		{ title: '启用无线', name: 'f_wl'+u+'_radio', type: 'checkbox',
			value: (eval('nvram.wl'+u+'_radio') == '1') && (eval('nvram.wl'+u+'_net_mode') != 'disabled') },
		{ title: 'MAC地址', text: '<a href="advanced-mac.asp">' + eval('nvram.wl'+u+'_hwaddr') + '</a>' },
		{ title: '无线模式', name: 'f_wl'+u+'_mode', type: 'select',
			options: [['ap', '无线接入点AP'],['apwds', '无线接入点AP + WDS'],['sta', 'W无线客户端'],['wet', '无线桥接'],['wds', '无线分布式系统WDS']],
			value: ((eval('nvram.wl'+u+'_mode') == 'ap') && (eval('nvram.wl'+u+'_wds_enable') == '1')) ? 'apwds' : eval('nvram.wl'+u+'_mode') },
		{ title: '无线频段', name: 'f_wl'+u+'_nband', type: 'select', options: bands[uidx],
			value: eval('nvram.wl'+u+'_nband') || '0' == '0' ? bands[uidx][0][0] : eval('nvram.wl'+u+'_nband') },
		{ title: '无线工作模式', name: 'wl'+u+'_net_mode', type: 'select',
			value: (eval('nvram.wl'+u+'_net_mode') == 'disabled') ? 'mixed' : eval('nvram.wl'+u+'_net_mode'),
			options: [], prefix: '<span id="__wl'+u+'_net_mode">', suffix: '</span>' },
		{ title: 'SSID', name: 'wl'+u+'_ssid', type: 'text', maxlen: 32, size: 34, value: eval('nvram.wl'+u+'_ssid') },
 		{ title: 'SSID 编码', name: 'wl'+u+'_encoding', type: 'select', options: [['utf8','UTF-8 编码(手机,平板)'],['gbk','GBK 编码(Windows电脑)']], value: eval('nvram.wl'+u+'_encoding') },
		{ title: 'SSID 广播', indent: 2, name: 'f_wl'+u+'_bcast', type: 'checkbox', value: (eval('nvram.wl'+u+'_closed') == '0') },
		{ title: '频段', name: 'wl'+u+'_channel', type: 'select', options: ghz[uidx], prefix: '<span id="__wl'+u+'_channel">', suffix: '</span> <input type="button" id="_f_wl'+u+'_scan" value="扫描" onclick="scanButton('+u+')"> <img src="spin.gif" id="spin'+u+'">',
			value: eval('nvram.wl'+u+'_channel') },
		{ title: '频宽', name: 'wl'+u+'_nbw_cap', type: 'select', options: [['0','20 MHz'],['1','40 MHz']],
			value: eval('nvram.wl'+u+'_nbw_cap') },
		{ title: '控制边带', name: 'f_wl'+u+'_nctrlsb', type: 'select', options: [['lower','下部'],['upper','上部']],
			value: eval('nvram.wl'+u+'_nctrlsb') == 'none' ? 'lower' : eval('nvram.wl'+u+'_nctrlsb') },
		null,
		{ title: '安全设置', name: 'wl'+u+'_security_mode', type: 'select',
			options: [['disabled','禁用'],['wep','WEP'],['wpa_personal','WPA Personal'],['wpa_enterprise','WPA Enterprise'],['wpa2_personal','WPA2 Personal'],['wpa2_enterprise','WPA2 Enterprise'],['wpaX_personal','WPA / WPA2 Personal'],['wpaX_enterprise','WPA / WPA2 Enterprise'],['radius','Radius']],
			value: eval('nvram.wl'+u+'_security_mode') },
		{ title: '加密方式', indent: 2, name: 'wl'+u+'_crypto', type: 'select',
			options: [['tkip','TKIP'],['aes','AES'],['tkip+aes','TKIP / AES']], value: eval('nvram.wl'+u+'_crypto') },
		{ title: '共享密钥', indent: 2, name: 'wl'+u+'_wpa_psk', type: 'password', maxlen: 64, size: 66, peekaboo: 1,
			suffix: ' <input type="button" id="_f_wl'+u+'_psk_random1" value="随机" onclick="random_psk(\'_wl'+u+'_wpa_psk\')">',
			value: eval('nvram.wl'+u+'_wpa_psk') },
		{ title: '共享密钥', indent: 2, name: 'wl'+u+'_radius_key', type: 'password', maxlen: 80, size: 32, peekaboo: 1,
			suffix: ' <input type="button" id="_f_wl'+u+'_psk_random2" value="随机" onclick="random_psk(\'_wl'+u+'_radius_key\')">',
			value: eval('nvram.wl'+u+'_radius_key') },
		{ title: '组密钥更新间隔', indent: 2, name: 'wl'+u+'_wpa_gtk_rekey', type: 'text', maxlen: 4, size: 6, suffix: ' <i>(seconds)</i>',
			value: eval('nvram.wl'+u+'_wpa_gtk_rekey') },
		{ title: 'Radius服务器', indent: 2, multi: [
			{ name: 'wl'+u+'_radius_ipaddr', type: 'text', maxlen: 15, size: 17, value: eval('nvram.wl'+u+'_radius_ipaddr') },
			{ name: 'wl'+u+'_radius_port', type: 'text', maxlen: 5, size: 7, prefix: ' : ', value: eval('nvram.wl'+u+'_radius_port') } ] },
		{ title: '加密方式', indent: 2, name: 'wl'+u+'_wep_bit', type: 'select', options: [['128','128-bits'],['64','64-bits']],
			value: eval('nvram.wl'+u+'_wep_bit') },
		{ title: '密码', indent: 2, name: 'wl'+u+'_passphrase', type: 'text', maxlen: 16, size: 20,
			suffix: ' <input type="button" id="_f_wl'+u+'_wep_gen" value="生成" onclick="generate_wep('+u+')"> <input type="button" id="_f_wl'+u+'_wep_random" value="随机" onclick="random_wep('+u+')">',
			value: eval('nvram.wl'+u+'_passphrase') }
	];

	for (i = 1; i <= 4; ++i)	{
		f.push(
			{ title: ('密钥' + i), indent: 2, name: ('wl'+u+'_key' + i), type: 'text', maxlen: 26, size: 34,
				suffix: '<input type="radio" onchange="verifyFields(this,1)" onclick="verifyFields(this,1)" name="f_wl'+u+'_wepidx" id="_f_wl'+u+'_wepidx_' + i + '" value="' + i + '"' + ((eval('nvram.wl'+u+'_key') == i) ? ' checked>' : '>'),
				value: nvram['wl'+u+'_key' + i] });
	}

	f.push(null,
		{ title: 'WDS', name: 'f_wl'+u+'_lazywds', type: 'select',
			 options: [['0','连接至...'],['1','自动']], value: nvram['wl'+u+'_lazywds'] } );
	wds = eval('nvram.wl'+u+'_wds').split(/\s+/);
	for (i = 0; i < 10; i += 2)	{
		f.push({ title: (i ? '' : '远程MAC清单'), indent: 2, multi: [
			{ name: 'f_wl'+u+'_wds_' + i, type: 'text', maxlen: 17, size: 20, value: wds[i] || '00:00:00:00:00:00' },
			{ name: 'f_wl'+u+'_wds_' + (i + 1), type: 'text', maxlen: 17, size: 20, value: wds[i + 1] || '00:00:00:00:00:00' } ] } );
	}

	createFieldTable('', f);
	W('</div>');
	}
}
// for each wlif
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' class="btn btn-danger" id='save-button' onclick='save()'>
	<input type='button' value='取消设置' class="btn btn-gray" id='cancel-button' onclick='reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit()</script>
<div style='height:100px'></div>



</body>
</html>
