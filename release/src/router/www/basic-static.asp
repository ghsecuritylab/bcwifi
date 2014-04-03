<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	Enhancements by Teaman
	Copyright (C) 2011 Augusto Bott
	http://code.google.com/p/tomato-sdhc-vlan/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>]基本设置: 静态DHCP/ARP/IPT</title>

<link rel='stylesheet' type='text/css' href='bootstrap.min.css'>
<link rel='stylesheet' type='text/css' href='new.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript'>

//	<% nvram("lan_ipaddr,lan_netmask,dhcpd_static,dhcpd_startip,dhcpd_static_only,cstats_include"); %>

if (nvram.lan_ipaddr.match(/^(\d+\.\d+\.\d+)\.(\d+)$/)) ipp = RegExp.$1 + '.';
	else ipp = '?.?.?.';

autonum = aton(nvram.lan_ipaddr) & aton(nvram.lan_netmask);

var sg = new TomatoGrid();

sg.exist = function(f, v) {
	var data = this.getAllData();
	for (var i = 0; i < data.length; ++i) {
		if (data[i][f] == v) return true;
	}
	return false;
}

sg.existMAC = function(mac) {
	if (isMAC0(mac)) return false;
	return this.exist(0, mac) || this.exist(1, mac);
}

sg.existName = function(name) {
	return this.exist(5, name);
}

sg.inStatic = function(n) {
	return this.exist(3, n);
}

sg.dataToView = function(data) {
	var v = [];
	var s = (data[0] == '00:00:00:00:00:00') ? '' : data[0];
	if (!isMAC0(data[1])) s += '<br>' + data[1];
	v.push((s == '') ? '<center><small><i>(未设置)</i></small></center>' : s);

	v.push((data[2].toString() != '0') ? '<small><i>启用</i></small>' : '');
	v.push(escapeHTML('' + data[3]));
	v.push((data[4].toString() != '0') ? '<small><i>启用</i></small>' : '');
	v.push(escapeHTML('' + data[5]));
	return v;
}

sg.dataToFieldValues = function (data) {
	return ([data[0],
			data[1],
			(data[2].toString() != '0') ? 'checked' : '',
			data[3],
			(data[4].toString() != '0') ? 'checked' : '',
			data[5]]);
}

sg.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return ([f[0].value,
			f[1].value,
			f[2].checked ? '1' : '0',
			f[3].value,
			f[4].checked ? '1' : '0',
			f[5].value]);
}

sg.sortCompare = function(a, b) {
	var da = a.getRowData();
	var db = b.getRowData();
	var r = 0;
	switch (this.sortColumn) {
	case 0:
		r = cmpText(da[0], db[0]);
		break;
	case 1:
		r = cmpInt(da[2], db[2]);
		break;
	case 2:
		r = cmpIP(da[3], db[3]);
		break;
	case 3:
		r = cmpInt(da[4], db[4]);
		break;
	}
	if (r == 0) r = cmpText(da[5], db[5]);
	return this.sortAscending ? r : -r;
}

sg.verifyFields = function(row, quiet) {
	var f, s, i;

	f = fields.getAll(row);

	if (!v_macz(f[0], quiet)) return 0;
	if (!v_macz(f[1], quiet)) return 0;
	if (isMAC0(f[0].value)) {
		f[0].value = f[1].value;
		f[1].value = '00:00:00:00:00:00';
	}
	else if (f[0].value == f[1].value) {
		f[1].value = '00:00:00:00:00:00';
	}
	else if ((!isMAC0(f[1].value)) && (f[0].value > f[1].value)) {
		s = f[1].value;
		f[1].value = f[0].value;
		f[0].value = s;
	}

	f[1].disabled = f[2].checked;

	for (i = 0; i < 2; ++i) {
		if (this.existMAC(f[i].value)) {
			ferror.set(f[i], '重复的MAC地址', quiet);
			return 0;
		}
	}

	if (f[3].value.indexOf('.') == -1) {
		s = parseInt(f[3].value, 10)
		if (isNaN(s) || (s <= 0) || (s >= 255)) {
			ferror.set(f[3], '无效的 IP 地址', quiet);
			return 0;
		}
		f[3].value = ipp + s;
	}

	if ((!isMAC0(f[0].value)) && (this.inStatic(f[3].value))) {
		ferror.set(f[3], '重复的IP地址', quiet);
		return 0;
	}

/* REMOVE-BEGIN
//	if (!v_hostname(f[5], quiet, 5)) return 0;
//	if (!v_nodelim(f[5], quiet, 'Hostname', 1)) return 0;
REMOVE-END */
	s = f[5].value.trim().replace(/\s+/g, ' ');

	if (s.length > 0) {
		if (s.search(/^[.a-zA-Z0-9_\- ]+$/) == -1) {
			ferror.set(f[5], '无效的主机名，仅允许字符 "A-Z 0-9 . - _"', quiet);
			return 0;
		}
		if (this.existName(s)) {
			ferror.set(f[5], '主机名重复', quiet);
			return 0;
		}
		f[5].value = s;
	}

	if (isMAC0(f[0].value)) {
		if (s == '') {
			s = 'MAC 地址和名称字段均不能为空';
			ferror.set(f[0], s, 1);
			ferror.set(f[5], s, quiet);
			return 0;
		} else {
			ferror.clear(f[0]);
			ferror.clear(f[5]);
		}
	}

	if (((f[0].value == '00:00:00:00:00:00') || (f[1].value == '00:00:00:00:00:00')) && (f[0].value == f[1].value)) {
		f[2].disabled=1;
		f[2].checked=0;
	} else {
		f[2].disabled=0;
	}

	return 1;
}

sg.resetNewEditor = function() {
	var f, c, n;

	f = fields.getAll(this.newEditor);
	ferror.clearAll(f);

	if ((c = cookie.get('addstatic')) != null) {
		cookie.set('addstatic', '', 0);
		c = c.split(',');
		if (c.length == 3) {
			f[0].value = c[0];
			f[1].value = '00:00:00:00:00:00';
			f[3].value = c[1];
			f[5].value = c[2];
			return;
		}
	}

	f[0].value = '00:00:00:00:00:00';
	f[1].value = '00:00:00:00:00:00';
	f[2].disabled = 1;
	f[2].checked = 0;
	f[4].checked = 0;
	f[5].value = '';

	n = 10;
	do {
		if (--n < 0) {
			f[3].value = '';
			return;
		}
		autonum++;
	} while (((c = fixIP(ntoa(autonum), 1)) == null) || (c == nvram.lan_ipaddr) || (this.inStatic(c)));

	f[3].value = c;
}

sg.setup = function() {
	this.init('bs-grid', 'sort', 250, [
		{ multi: [ { type: 'text', maxlen: 17 }, { type: 'text', maxlen: 17 } ] },
		{ type: 'checkbox', prefix: '<div class="centered">', suffix: '</div>' },
		{ type: 'text', maxlen: 15 },
		{ type: 'checkbox', prefix: '<div class="centered">', suffix: '</div>' },
		{ type: 'text', maxlen: 50 } ] );

	this.headerSet(['MAC 地址', '绑定到', 'IP 地址', 'IP流量', '主机名']);

	var ipt = nvram.cstats_include.split(',');
	var s = nvram.dhcpd_static.split('>');
	for (var i = 0; i < s.length; ++i) {
		var h = '0';
		var t = s[i].split('<');
		if ((t.length == 3) || (t.length == 4)) {
			var d = t[0].split(',');
			var ip = (t[1].indexOf('.') == -1) ? (ipp + t[1]) : t[1];
			for (var j = 0; j < ipt.length; ++j) {
				if (ip == ipt[j]) {
					h = '1';
					break;
				}
			}
			if (t.length == 3) {
				t[3] = '0';
			}
			this.insertData(-1, [d[0], (d.length >= 2) ? d[1] : '00:00:00:00:00:00', t[3],
				(t[1].indexOf('.') == -1) ? (ipp + t[1]) : t[1], h, t[2]]);
		}
	}
	this.sort(4);
	this.showNewEditor();
	this.resetNewEditor();
}

function save() {
	if (sg.isEditing()) return;

	var data = sg.getAllData();
	var sdhcp = '';
	var ipt = '';
	var i;

	for (i = 0; i < data.length; ++i) {
		var d = data[i];
		sdhcp += d[0];
		if (!isMAC0(d[1])) sdhcp += ',' + d[1];
		sdhcp += '<' + d[3] + '<' + d[5] + '<' + d[2] + '>';
		if (d[4] == '1') ipt += ((ipt.length > 0) ? ',' : '') + d[3];
	}

	var fom = E('_fom');
	fom.dhcpd_static.value = sdhcp;
	fom.dhcpd_static_only.value = E('_f_dhcpd_static_only').checked ? '1' : '0';
	fom.cstats_include.value = ipt;
	form.submit(fom, 1);
}

function init()
{
	var c;
	if (((c = cookie.get('basic_static_notes_vis')) != null) && (c == '1')) {
		toggleVisibility("notes");
	}

	sg.recolor();
}

function toggleVisibility(whichone) {
	if(E('sesdiv' + whichone).style.display=='') {
		E('sesdiv' + whichone).style.display='none';
		E('sesdiv' + whichone + 'showhide').innerHTML='（点击此处显示）';
		cookie.set('basic_static_' + whichone + '_vis', 0);
	} else {
		E('sesdiv' + whichone).style.display='';
		E('sesdiv' + whichone + 'showhide').innerHTML='（点击此处隐藏）';
		cookie.set('basic_static_' + whichone + '_vis', 1);
	}
}

function verifyFields(focused, quiet) {
	return 1;
}

</script>
</head>
<body onload='init()'>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0 class="table">

<tr id='body'>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='basic-static.asp'>
<input type='hidden' name='_service' value='dhcpd-restart,arpbind-restart,cstats-restart'>

<input type='hidden' name='dhcpd_static'>
<input type='hidden' name='dhcpd_static_only'>
<input type='hidden' name='cstats_include'>

<div class='section-title'>静态DHCP/ARP/IPT</div>
<div class='section'>
	<table 

class='table table-bordered table-striped' id='bs-grid'></table>
</div>

<!-- / / / -->

<div class='section-title'>选项</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
{ title: '忽略未知设备的DHCP请求', name: 'f_dhcpd_static_only', type: 'checkbox', value: nvram.dhcpd_static_only == '1' }
]);
</script>
</div>
<div class='section-title'>说明 <small><i><a href='javascript:toggleVisibility("notes");'><span id='sesdivnotesshowhide'>（点击这里显示）</span></a></i></small></div>
<div class='section' id='sesdivnotes' style='display:none'>
<ul>
<li><b>MAC地址</b> - 与此设备的一个网络接口相关联的唯一标示符</li>
<li><b>绑定到</b> - 在此IP/MAC组合上强制静态 ARP 绑定</li>
<li><b>IP地址</b> - 在本地网络上分配给这个设备的网络地址</li>
<li><b>IP流量</b> - 监控此 IP 地址的流量</li>
<li><b>主机名</b> - 在网络上分配给这个设备的昵称/标签</li>
</ul>
<small>
<ul>
<li><b>其它说明：</b>
<ul>
<li>如要指定多个主机设备，请用空格隔开。</li>
<li>如要对一个特定设备启用/执行静态ARP绑定，它只能一个MAC地址对应一个IP地址（即在上面的表中，你不能有两个MAC地址链接到同一主机/设备）</li>
<li>当对一个特定的MAC/IP地址对启用了静态ARP绑定的后，那个设备将永远在 <a href="tools-wol.asp">网络唤醒</a> 列表中显示为 ‘活动’</li>
<li>也可以查看 <a href='advanced-dhcpdns.asp'>DHCP/DNS 高级配置</a> 设置更多DHCP相关的配置选项</li>
</ul>
</ul>
</small>
</div>


<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' class="btn btn-danger" value='保存设置' id='save-button' onclick='save()'>
	<input type='button' class="btn btn-gray" value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
</td></tr>
</table>
</form>
<script type='text/javascript'>sg.setup();</script>



</body>
</html>
