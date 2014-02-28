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
<title>[<% ident(); %>] 端口转发：端口触发</title>

<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/bootstrap.css'>
<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/new.css'>





 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='http://dev.plat.gionee.com/static/bootstrap.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript'>
//	<% nvram("trigforward"); %>

var tg = new TomatoGrid();

tg.sortCompare = function(a, b) {
	var col = this.sortColumn;
	var da = a.getRowData();
	var db = b.getRowData();
	var r;

	switch (col) {
	case 2:	// t prt
	case 3:	// f prt
		r = cmpInt(da[col], db[col]);
		break;
	default:
		r = cmpText(da[col], db[col]);
		break;
	}

	return this.sortAscending ? r : -r;
}

tg.dataToView = function(data) {
	return [data[0] ? '是' : '', ['TCP', 'UDP', 'TCP+UDP'][data[1] - 1], data[2], data[3], data[4]];
}

tg.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return [f[0].checked ? 1 : 0, f[1].value, f[2].value, f[3].value, f[4].value];
}

tg.verifyFields = function(row, quiet) {
	var f = fields.getAll(row);
	ferror.clearAll(f);
	if (!v_portrange(f[2], quiet)) return 0;
	if (!v_portrange(f[3], quiet)) return 0;
	f[4].value = f[4].value.replace(/>/g, '_');
	if (!v_nodelim(f[4], quiet, 'Description')) return 0;
	return 1;
}

tg.resetNewEditor = function() {
	var f = fields.getAll(this.newEditor);
	f[0].checked = 1;
	f[1].selectedIndex = 0;
	f[2].value = '';
	f[3].value = '';
	f[4].value = '';
	ferror.clearAll(f);
}

tg.setup = function() {
	this.init('tg-grid', 'sort', 50, [
		{ type: 'checkbox' },
		{ type: 'select', options: [[1, 'TCP'],[2, 'UDP'],[3,'TCP+UDP']] },
		{ type: 'text', maxlen: 16 },
		{ type: 'text', maxlen: 16 },
		{ type: 'text', maxlen: 32 }]);
	this.headerSet(['启用', '协议', '触发端口', '映射端口', '描述']);
	var nv = nvram.trigforward.split('>');
	for (var i = 0; i < nv.length; ++i) {
		var r;
		if (r = nv[i].match(/^(\d)<(\d)<(.+?)<(.+?)<(.*)$/)) {
			r[1] *= 1;
			r[2] *= 1;
			r[3] = r[3].replace(/:/g, '-');
			r[4] = r[4].replace(/:/g, '-');
			tg.insertData(-1, r.slice(1, 6));
		}
	}
	tg.sort(4);
	tg.showNewEditor();
}


function save()
{
	if (tg.isEditing()) return;

	var data = tg.getAllData();
	var s = '';
	for (var i = 0; i < data.length; ++i) {
		data[i][2] = data[i][2].replace(/-/g, ':');
		data[i][3] = data[i][3].replace(/-/g, ':');
		s += data[i].join('<') + '>';
	}
	var fom = E('_fom');
	fom.trigforward.value = s;
	form.submit(fom, 1);
}

function init()
{
	tg.recolor();
	tg.resetNewEditor();
}
</script>
</head>
<body onload='init()'>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='forward.asp'>
<input type='hidden' name='_service' value='firewall-restart'>

<input type='hidden' name='trigforward'>

<div class='section-title'>触发式端口转发</div>
<div class='section'>
	<table 

class='table table-bordered table-striped' cellspacing=1 id='tg-grid'></table>
	<script type='text/javascript'>tg.setup();</script>
</div>

<div>
<ul>
<li>使用 "-" 指定端口范围 (200-300).
</li><li>一旦检测到触发程序通讯端口送往指定内部端口的上传数据包便会转向您的计算机.</li><li>例: 巴哈姆特的 BBS 会使用 Port 113 做验证.<br>在本例中, 连往 BBS 所用的 Port 为 23, 接收验证的 Port 为 113, 所使用的通讯协议皆为 TCP.<br>所以我们要加入一条规则, 在 [协议] 中选中 [TCP]<br>[触发端口] 填入 [23]<br>[映射端口] 填入 [113]<br>最后记得要按 [增加] 与 [保存] 按钮<br>
</li><li>开启的通讯端口若未使用,几分钟之后会自动关闭.
</li></ul>
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



</body>
</html>
