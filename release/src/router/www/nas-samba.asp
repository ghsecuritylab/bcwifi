<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Samba Server - !!TB

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] NAS: 文件共享</title>

<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/bootstrap.css'>
<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/new.css'>








 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='http://dev.plat.gionee.com/static/bootstrap.js'></script>

<!-- / / / -->
<style tyle='text/css'>
#ss-grid {
	width: 99%;
}
#ss-grid .co1, #ss-grid .co2, #ss-grid .co3 {
	width: 25%;
}
#ss-grid .co4 {
	width: 16%;
}
#ss-grid .co5 {
	width: 9%;
}
</style>
<style type='text/css'>
textarea {
	width: 98%;
	height: 6em;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("smbd_enable,smbd_user,smbd_passwd,smbd_wgroup,smbd_cpage,smbd_custom,smbd_master,smbd_wins,smbd_shares,smbd_autoshare,wan_wins"); %>

var ssg = new TomatoGrid();

ssg.exist = function(f, v)
{
	var data = this.getAllData();
	for (var i = 0; i < data.length; ++i) {
		if (data[i][f] == v) return true;
	}
	return false;
}

ssg.existName = function(name)
{
	return this.exist(0, name);
}

ssg.sortCompare = function(a, b) {
	var col = this.sortColumn;
	var da = a.getRowData();
	var db = b.getRowData();
	var r = cmpText(da[col], db[col]);
	return this.sortAscending ? r : -r;
}

ssg.dataToView = function(data) {
	return [data[0], data[1], data[2], ['Read Only', 'Read / Write'][data[3]], ['No', 'Yes'][data[4]]];
}

ssg.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return [f[0].value, f[1].value, f[2].value, f[3].value, f[4].value];
}

ssg.verifyFields = function(row, quiet)
{
	var f, s;

	f = fields.getAll(row);

	s = f[0].value.trim().replace(/\s+/g, ' ');
	if (s.length > 0) {
		if (s.search(/^[ a-zA-Z0-9_\-\$]+$/) == -1) {
			ferror.set(f[0], '无效的共享名。只有字符 "$ A-Z 0-9 - _" 和空格。', quiet);
			return 0;
		}
		if (this.existName(s)) {
			ferror.set(f[0], '重复的共享名称.', quiet);
			return 0;
		}
		f[0].value = s;
	}
	else {
		ferror.set(f[0], '空的共享名是不允许的。', quiet);
		return 0;
	}

	if (!v_nodelim(f[1], quiet, 'Directory', 1) || !v_path(f[1], quiet, 1)) return 0;
	if (!v_nodelim(f[2], quiet, 'Description', 1)) return 0;

	return 1;
}

ssg.resetNewEditor = function()
{
	var f;

	f = fields.getAll(this.newEditor);
	ferror.clearAll(f);

	f[0].value = '';
	f[1].value = '';
	f[2].value = '';
	f[3].selectedIndex = 0;
	f[4].selectedIndex = 0;
}

ssg.setup = function()
{
	this.init('ss-grid', 'sort', 50, [
		{ type: 'text', maxlen: 32 },
		{ type: 'text', maxlen: 256 },
		{ type: 'text', maxlen: 64 },
		{ type: 'select', options: [[0, 'Read Only'],[1, 'Read / Write']] },
		{ type: 'select', options: [[0, 'No'],[1, 'Yes']] }
	]);
	this.headerSet(['共享名', '目录', '描述', '访问级别', '隐藏']);

	var s = nvram.smbd_shares.split('>');
	for (var i = 0; i < s.length; ++i) {
		var t = s[i].split('<');
		if (t.length == 5) {
			this.insertData(-1, t);
		}
	}

	this.sort(0);
	this.showNewEditor();
	this.resetNewEditor();
}

function verifyFields(focused, quiet)
{
	var a, b;

	a = E('_smbd_enable').value;

	elem.display(PR('_smbd_user'), PR('_smbd_passwd'), (a == 2));

	E('_smbd_wgroup').disabled = (a == 0);
	E('_smbd_cpage').disabled = (a == 0);
	E('_smbd_custom').disabled = (a == 0);
	E('_smbd_autoshare').disabled = (a == 0);
	E('_f_smbd_master').disabled = (a == 0);
	E('_f_smbd_wins').disabled = (a == 0 || (nvram.wan_wins != '' && nvram.wan_wins != '0.0.0.0'));

	if (a != 0 && !v_length('_smbd_custom', quiet, 0, 2048)) return 0;

	if (a == 2) {
		if (!v_length('_smbd_user', quiet, 1)) return 0;
		if (!v_length('_smbd_passwd', quiet, 1)) return 0;

		b = E('_smbd_user');
		if (b.value == 'root') {
			ferror.set(b, '用户名\"root\"是不允许的。', quiet);
			return 0;
		}
		ferror.clear(b);
	}

	return 1;
}

function save()
{
	if (ssg.isEditing()) return;
	if (!verifyFields(null, 0)) return;

	var fom = E('_fom');

	var data = ssg.getAllData();
	var r = [];
	for (var i = 0; i < data.length; ++i) r.push(data[i].join('<'));
	fom.smbd_shares.value = r.join('>');
	fom.smbd_master.value = E('_f_smbd_master').checked ? 1 : 0;
	if (nvram.wan_wins == '' || nvram.wan_wins == '0.0.0.0')
		fom.smbd_wins.value = E('_f_smbd_wins').checked ? 1 : 0;
	else
		fom.smbd_wins.value = nvram.smbd_wins;

	form.submit(fom, 1);
}
</script>

</head>
<body>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='nas-samba.asp'>
<input type='hidden' name='_service' value='samba-restart'>

<input type='hidden' name='smbd_master'>
<input type='hidden' name='smbd_wins'>
<input type='hidden' name='smbd_shares'>

<div class='section-title'>Samba文件共享</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '启用文件共享', name: 'smbd_enable', type: 'select',
		options: [['0', '不'],['1', '是的，没有身份验证'],['2', '是的，需要验证']],
		value: nvram.smbd_enable },
	{ title: '用户名', indent: 2, name: 'smbd_user', type: 'text', maxlen: 50, size: 32,
		value: nvram.smbd_user },
	{ title: '密码', indent: 2, name: 'smbd_passwd', type: 'password', maxlen: 50, size: 32, peekaboo: 1,
		value: nvram.smbd_passwd },
	null,
	{ title: '工作组名称', name: 'smbd_wgroup', type: 'text', maxlen: 20, size: 32,
		value: nvram.smbd_wgroup },
	{ title: '客户端代码页', name: 'smbd_cpage', type: 'select',
		options: [['', 'Unspecified'],['437', '437 (United States, Canada)'],['850', '850 (Western Europe)'],['852', '852 (Central / Eastern Europe)'],['866', '866 (Cyrillic / Russian)']
/* LINUX26-BEGIN */
		,['932', '932 (Japanese)'],['936', '936 (Simplified Chinese)'],['949', '949 (Korean)'],['950', '950 (Traditional Chinese / Big5)']
/* LINUX26-END */
		],
		suffix: ' <small> (启动cmd.exe和CHCP类型看当前代码页)</small>',
		value: nvram.smbd_cpage },
	{ title: 'Samba<br>自定义配置', name: 'smbd_custom', type: 'textarea', value: nvram.smbd_custom },
	{ title: '所有USB自动共享分区', name: 'smbd_autoshare', type: 'select',
		options: [['0', 'Disabled'],['1', 'Read Only'],['2', 'Read / Write'],['3', 'Hidden Read / Write']],
		value: nvram.smbd_autoshare },
	{ title: '选项', multi: [
		{ suffix: '&nbsp; Master Browser &nbsp;&nbsp;&nbsp;', name: 'f_smbd_master', type: 'checkbox', value: nvram.smbd_master == 1 },
		{ suffix: '&nbsp; WINS Server &nbsp;',	name: 'f_smbd_wins', type: 'checkbox', value: (nvram.smbd_wins == 1) && (nvram.wan_wins == '' || nvram.wan_wins == '0.0.0.0') }
	] }
]);
</script>
</div>
<br>

<div class='section-title'>附加共享名单</div>
<div class='section'>
	<table 

class='table table-bordered table-striped' cellspacing=1 id='ss-grid'></table>
	<script type='text/javascript'>ssg.setup();</script>
<br>
<small>如果没有指定禁用自动共享， <i>/mnt</i> 共享目录只读模式。</small>
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
<script type='text/javascript'>verifyFields(null, 1);</script>
</body>
</html>
