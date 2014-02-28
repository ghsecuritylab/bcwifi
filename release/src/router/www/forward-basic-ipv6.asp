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
<title>[<% ident(); %>] 端口转发: IPv6转发</title>
<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/bootstrap.css'>
<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/new.css'>





 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='http://dev.plat.gionee.com/static/bootstrap.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript'>

//	<% nvram("ipv6_portforward"); %>

var fog = new TomatoGrid();

fog.sortCompare = function(a, b) {
	var col = this.sortColumn;
	var da = a.getRowData();
	var db = b.getRowData();
	var r;

	switch (col) {
	case 0:	// on
	case 1:	// proto
	case 4:	// ports
		r = cmpInt(da[col], db[col]);
		break;
	default:
		r = cmpText(da[col], db[col]);
		break;
	}

	return this.sortAscending ? r : -r;
}

fog.dataToView = function(data) {
	return [(data[0] != '0') ? '是' : '', ['TCP', 'UDP', 'TCP+UDP'][data[1] - 1], (data[2].match(/(.+)-(.+)/)) ? (RegExp.$1 + ' -<br>' + RegExp.$2) : data[2], data[3], data[4], data[5]];
}

fog.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return [f[0].checked ? 1 : 0, f[1].value, f[2].value, f[3].value, f[4].value, f[5].value];
}

fog.verifyFields = function(row, quiet) {
	var f = fields.getAll(row);

	f[2].value = f[2].value.trim();
	if ((f[2].value.length) && (!_v_iptaddr(f[2], quiet, 0, 0, 1))) return 0;

	f[3].value = f[3].value.trim();	
	if ((f[3].value.length) && !v_hostname(f[3], 1)) {
		if (!v_ipv6_addr(f[3], quiet)) return 0;
	}

	if (!v_iptport(f[4], quiet)) return 0;

	f[5].value = f[5].value.replace(/>/g, '_');
	if (!v_nodelim(f[5], quiet, 'Description')) return 0;
	return 1;
}

fog.resetNewEditor = function() {
	var f = fields.getAll(this.newEditor);
	f[0].checked = 1;
	f[1].selectedIndex = 0;
	f[2].value = '';
	f[3].value = '';
	f[4].value = '';
	f[5].value = '';
	ferror.clearAll(fields.getAll(this.newEditor));
}

fog.setup = function() {
	this.init('fo-grid6', 'sort', 50, [
		{ type: 'checkbox' },
		{ type: 'select', options: [[1, 'TCP'],[2, 'UDP'],[3,'TCP+UDP']] },
		{ type: 'text', maxlen: 140 },
		{ type: 'text', maxlen: 140 },
		{ type: 'text', maxlen: 16 },
		{ type: 'text', maxlen: 32 }]);
	this.headerSet(['启用', '协议', '源地址', '目标地址', '目标端口', '描述']);
	var nv = nvram.ipv6_portforward.split('>');
	for (var i = 0; i < nv.length; ++i) {
		var r;

		if (r = nv[i].match(/^(\d)<(\d)<(.*)<(.*)<(.+?)<(.*)$/)) {
			r[1] *= 1;
			r[2] *= 1;
			r[5] = r[5].replace(/:/g, '-');
			fog.insertData(-1, r.slice(1, 7));
		}
	}
	fog.sort(5);
	fog.showNewEditor();
}

function srcSort(a, b)
{
	if (a[2].length) return -1;
	if (b[2].length) return 1;
	return 0;
}

function save()
{
	if (fog.isEditing()) return;

	var data = fog.getAllData().sort(srcSort);
	var s = '';
	for (var i = 0; i < data.length; ++i) {
		data[i][4] = data[i][4].replace(/-/g, ':');
		s += data[i].join('<') + '>';
	}
	var fom = E('_fom');
	fom.ipv6_portforward.value = s;
	form.submit(fom, 0, 'tomato.cgi');
}

function init()
{
	fog.recolor();
	fog.resetNewEditor();
}
</script>
</head>
<body onload='init()'>
<form id='_fom' method='post' action='javascript:{}'>
<table id='container' cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='forward-basic-ipv6.asp'>
<input type='hidden' name='_service' value='firewall-restart'>

<input type='hidden' name='ipv6_portforward'>

<div class='section-title'>IPv6的端口转发</div>
<div class='section'>
	<table 

class='table table-bordered table-striped' cellspacing=1 id='fo-grid6'></table>
	<script type='text/javascript'>fog.setup();</script>
</div>

<div>
打开访问局域网内的机器上的端口，但不重新映射端口。
<ul>
<li><b>源地址</b> <i>(可选)</i> - 仅映射该地址的连接. 例: "1.2.3.4", "1.2.3.4 - 2.3.4.5", "1.2.3.0/24".</li>
<li><b>目的地址</b> <i>(可选)</i> - 局域网内的目标地址。
<li><b>目的端口</b> - 从WAN对应进来的端口. 例: "2345", "200,300", "200-300,400".
</ul>
</div>

<br>
<script type='text/javascript'>show_notice1('<% notice("ip6tables"); %>');</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='reloadPage();'>
</td></tr>
</table>
</form>



</body>
</html>
