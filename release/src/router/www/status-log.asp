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
<title>[<% ident(); %>] 系统状态：日志记录文件</title>

<link rel='stylesheet' type='text/css' href='bootstrap.css'>
<link rel='stylesheet' type='text/css' href='new.css'>
<script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='bootstrap.js'></script>

<!-- / / / -->

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("log_file"); %>

function find()
{
	var s = E('find-text').value;
	if (s.length) document.location = 'logs/view.cgi?find=' + escapeCGI(s) + '&_http_id=' + nvram.http_id;
}

function init()
{
	var e = E('find-text');
	if (e) e.onkeypress = function(ev) {
		if (checkEvent(ev).keyCode == 13) find();
	}
}
</script>

</head>
<body onload='init()'>
<form id='_fom' action='javascript:{}'>
<table id='container' cellspacing=0 class="table">

<tr id='body'>
<td id='content'>


<!-- / / / -->

<div id='logging'>
	<div class='section-title'>日志记录文件</div>
	<div class='section'>
		<a class="btn btn-link" href="logs/view.cgi?which=25&_http_id=<% nv(http_id) %>">查看最后  25 行</a><br>
		<a class="btn btn-link" href="logs/view.cgi?which=50&_http_id=<% nv(http_id) %>">查看最后  50 行</a><br>
		<a class="btn btn-link" href="logs/view.cgi?which=100&_http_id=<% nv(http_id) %>">查看最后 100 行</a><br>
		<a class="btn btn-link" href="logs/view.cgi?which=all&_http_id=<% nv(http_id) %>">全部显示</a><br><br>
		<a class="btn btn-link" href="logs/syslog.txt?_http_id=<% nv(http_id) %>">下载日志记录文件</a><br><br>
		<input type="text" maxsize=32 size=33 id="find-text" class="form-control w200"> <input type="button" value="搜索" onClick="find()" class="btn btn-info"><br>
		<br><br>
		 <a class="btn btn-default" href="admin-log.asp">日志记录管理&raquo;</a><br><br>
	</div>
</div>

<script type='text/javascript'>
if (nvram.log_file != '1') {
	W('<div class="note-disabled">内部日志记录关闭.</b><br><br><a href="admin-log.asp">启用 &raquo;</a></div>');
	E('logging').style.display = 'none';
}
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</form>


</body>
</html>
