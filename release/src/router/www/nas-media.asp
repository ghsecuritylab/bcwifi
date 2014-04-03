<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Media Server Settings - !!TB

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] NAS: 媒体服务器</title>

<link rel='stylesheet' type='text/css' href='bootstrap.min.css'>
<link rel='stylesheet' type='text/css' href='new.css'>
<script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style tyle='text/css'>
#ms-grid {
	width: 81%;
}
#ms-grid .co1 {
	width: 56%;
}
#ms-grid .co2 {
	width: 44%;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("ms_enable,ms_port,ms_dirs,ms_dbdir,ms_tivo,ms_stdlna,ms_sas,cifs1,cifs2,jffs2_on"); %>

changed = 0;
mdup = parseInt('<% psup("minidlna"); %>');

var mediatypes = [['', '所有媒体文件'], ['A', '仅音频'], ['V', '仅视频'], ['P', '仅图片']];
var msg = new TomatoGrid();

msg.dataToView = function(data) {
	var b = [];
	var i;

	b.push(escapeHTML('' + data[0]));
	for (i = 0; i < mediatypes.length; ++i)
		if (mediatypes[i][0] == ('' + data[1])) {
			b.push(mediatypes[i][1]);
			break;
		}
	if (b.length < 2) b.push(mediatypes[0][1]);
	return b;
}

msg.verifyFields = function(row, quiet)
{
	var ok = 1;
	var f;
	f = fields.getAll(row);

	if (!v_nodelim(f[0], quiet, 'Directory', 1) || !v_path(f[0], quiet, 1))
		ok = 0;

	changed |= ok;
	return ok;
}

msg.resetNewEditor = function()
{
	var f;

	f = fields.getAll(this.newEditor);
	ferror.clearAll(f);
	f[0].value = '';
	f[1].selectedIndex = 0;
}

msg.setup = function()
{
	this.init('ms-grid', 'sort', 50, [
		{ type: 'text', maxlen: 256 },
		{ type: 'select', options: mediatypes }
	]);
	this.headerSet(['目录', '内容过滤']);

	var s = ('' + nvram.ms_dirs).split('>');
	for (var i = 0; i < s.length; ++i) {
		var t = s[i].split('<');
		if (t.length == 2) this.insertData(-1, t);
	}

	this.sort(0);
	this.showNewEditor();
	this.resetNewEditor();
}

function getDbPath()
{
	var s = E('_f_loc').value;
	return (s == '*user') ? E('_f_user').value : s;
}

function verifyFields(focused, quiet)
{
	var ok = 1;
	var a, b, v;
	var eLoc, eUser;

	elem.display('_restart_button', nvram.ms_enable == '1');

	a = E('_f_ms_enable').checked ? 1 : 0;

	eLoc = E('_f_loc');
	eUser = E('_f_user');

	eLoc.disabled = (a == 0);
	eUser.disabled = (a == 0);
	E('_ms_port').disabled = (a == 0);
	E('_f_ms_sas').disabled = (a == 0);
	E('_f_ms_rescan').disabled = (a == 0);
	E('_f_ms_tivo').disabled = (a == 0);
	E('_f_ms_stdlna').disabled = (a == 0);
	E('_restart_button').disabled = (a == 0);

	ferror.clear(eLoc);
	ferror.clear(eUser);

	v = eLoc.value;
	b = (v == '*user');
	elem.display(eUser, b);
	elem.display(PR('_f_ms_sas'), (v != ''));

	if (a == 0) {
		if (focused != E('_f_ms_rescan'))
			changed |= ok;
		return ok;
	}
	if (b) {
		if (!v_path(eUser, quiet || !ok, 1)) ok = 0;
	}
/* JFFS2-BEGIN */
	else if (v == '/jffs/dlna') {
		if (nvram.jffs2_on != '1') {
			ferror.set(eLoc, 'JFFS未启用。', quiet || !ok);
			ok = 0;
		}
		else ferror.clear(eLoc);
	}
/* JFFS2-END */
/* REMOVE-BEGIN */
/* CIFS-BEGIN */
	else if (v.match(/^\/cifs(1|2)\/dlna$/)) {
		if (nvram['cifs' + RegExp.$1].substr(0, 1) != '1') {
			ferror.set(eLoc, 'CIFS #' + RegExp.$1 + ' 未启用.', quiet || !ok);
			ok = 0;
		}
		else ferror.clear(eLoc);
	}
/* CIFS-END */
/* REMOVE-END */

	if (focused != E('_f_ms_rescan'))
		changed |= ok;
	return ok;
}

function save()
{
	if (msg.isEditing()) return;
	if (!verifyFields(null, 0)) return;

	var fom = E('_fom');

	fom.ms_enable.value = E('_f_ms_enable').checked ? 1 : 0;
	fom.ms_tivo.value = E('_f_ms_tivo').checked ? 1 : 0;
	fom.ms_stdlna.value = E('_f_ms_stdlna').checked ? 1 : 0;
	fom.ms_rescan.value = E('_f_ms_rescan').checked ? 1 : 0;
	fom.ms_sas.value = E('_f_ms_sas').checked ? 1 : 0;

	fom.ms_dbdir.value = getDbPath();

	var data = msg.getAllData();
	var r = [];
	for (var i = 0; i < data.length; ++i) r.push(data[i].join('<'));
	fom.ms_dirs.value = r.join('>');

	form.submit(fom, 1);
}

function restart(isup)
{
	if (changed) {
		if (!confirm("未保存的更改将丢失。继续吗？")) return;
	}
	E('_restart_button').disabled = true;
	form.submitHidden('tomato.cgi', {
		ms_rescan: E('_f_ms_rescan').checked ? 1 : 0,
		_reboot: 0, _commit: 0, _nvset: 1,
		_redirect: 'nas-media.asp',
		_sleep: '3',
		_service: 'media-' + (isup ? 're' : '') + 'start'
	});
}

function submit_complete()
{
	reloadPage();
}

var xob = null;

function setNoticeText(s)
{
	if (s.length)
		s = '<div id="notice1">' + s.replace(/\n/g, '<br>') + '</div><br style="clear:both">';
	elem.setInnerHTML('notice-msg', s);
}

function updateNotice()
{
	if (xob) return;

	xob = new XmlHttp();
	xob.onCompleted = function(text, xml) {
		setNoticeText(text);
		xob = null;
		setTimeout(updateNotice, 5000);
	}
	xob.onError = function(ex) { xob = null; }
	xob.post('update.cgi', 'exec=notice&arg0=dlna');
}

function init()
{
	changed = 0;
	updateNotice();
}
</script>

</head>
<body onLoad="init()">
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' class="table" cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<input type='hidden' name='_nextpage' value='nas-media.asp'>
<input type='hidden' name='_service' value='media-restart'>

<input type='hidden' name='ms_enable'>
<input type='hidden' name='ms_dirs'>
<input type='hidden' name='ms_dbdir'>
<input type='hidden' name='ms_tivo'>
<input type='hidden' name='ms_stdlna'>
<input type='hidden' name='ms_rescan'>
<input type='hidden' name='ms_sas'>

<div class='section-title'>媒体/ DLNA服务器</div>
<div class='section'>
<script type='text/javascript'>

switch (nvram.ms_dbdir) {
	case '':
	case '/jffs/dlna':
	case '/cifs1/dlna':
	case '/cifs2/dlna':
		loc = nvram.ms_dbdir;
		break;
	default:
		loc = '*user';
		break;
}

createFieldTable('', [
	{ title: '启用', name: 'f_ms_enable', type: 'checkbox', value: nvram.ms_enable == '1' },
	{ title: '端口', name: 'ms_port', type: 'text', maxlen: 5, size: 6, value: nvram.ms_port, suffix: '<small>(范围：0 - 65535;默认值（随机）设定为0)</small>' },
	{ title: '数据库位置', multi: [
		{ name: 'f_loc', type: 'select', options: [['','RAM (Temporary)'],

/* JFFS2-BEGIN */
			['/jffs/dlna','JFFS'],
/* JFFS2-END */
/* REMOVE-BEGIN */
/* CIFS-BEGIN */
			['/cifs1/dlna','CIFS 1'],['/cifs2/dlna','CIFS 2'],
/* CIFS-END */
/* REMOVE-END */
			['*user','Custom Path']], value: loc },
		{ name: 'f_user', type: 'text', maxlen: 256, size: 60, value: nvram.ms_dbdir }
	] },
	{ title: '扫描介质启动*', indent: 2, name: 'f_ms_sas', type: 'checkbox', value: nvram.ms_sas == '1', hidden: 1 },
	{ title: '在下次运行时重新扫描*', indent: 2, name: 'f_ms_rescan', type: 'checkbox', value: 0,
		suffix: '<br><small>* 媒体扫描可能需要相当长的时间才能完成。</small>' },
	null,
	{ title: 'TiVo的支持', name: 'f_ms_tivo', type: 'checkbox', value: nvram.ms_tivo == '1' },
	{ title: '严格遵循DLNA标准', name: 'f_ms_stdlna', type: 'checkbox', value: nvram.ms_stdlna == '1' }
]);
W('<br><input type="button" value="' + (mdup ? 'Res' : 'S') + 'tart Now" onclick="restart(mdup)" id="_restart_button">');
</script>
</div>
<span id="notice-msg"></span>
<br>

<div class='section-title'>媒体目录</div>
<div class='section'>
	<table 

class='table table-bordered table-striped' cellspacing=1 id='ms-grid'></table>
	<script type='text/javascript'>msg.setup();</script>
<br>
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
