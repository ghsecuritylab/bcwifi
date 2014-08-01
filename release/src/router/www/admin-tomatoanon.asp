<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2012 Shibby
	http://openlinksys.info
	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 系统管理: TomatoAnon项目</title>

<link rel='stylesheet' type='text/css' href='bootstrap.min.css'>
<link rel='stylesheet' type='text/css' href='new.css'>
<script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript'>
//	<% nvram("tomatoanon_enable,tomatoanon_answer,tomatoanon_cru,tomatoanon_id,tomatoanon_notify"); %>

var anon_link = '&nbsp;&nbsp;<a href="http://tomato.groov.pl/tomatoanon.php?search=9&routerid=<% nv('tomatoanon_id'); %>" target="_blank"><i>[检出我的路由器]</i></a>';

function verifyFields(focused, quiet)
{
	var o = (E('_tomatoanon_answer').value == '1');
	E('_tomatoanon_enable').disabled = !o;

	var s = (E('_tomatoanon_enable').value == '1');
	E('_tomatoanon_cru').disabled = !o || !s;

	E('_f_tomatoanon_notify').disabled = !o || !s;

	return 1;
}

function save()
{
	if (verifyFields(null, 0)==0) return;
	var fom = E('_fom');

	fom.tomatoanon_notify.value = E('_f_tomatoanon_notify').checked ? 1 : 0;

	fom._service.value = 'tomatoanon-restart';
	form.submit('_fom', 1);
}

function init()
{
}
</script>
</head>

<body onLoad="init()">
<table id='container' cellspacing=0 class="table">

<tr id='body'>
<td id='content'>

<form id='_fom' method='post' action='tomato.cgi'>
<input type='hidden' name='_nextpage' value='admin-tomatoanon.asp'>
<input type='hidden' name='_service' value='tomatoanon-restart'>
<input type='hidden' name='tomatoanon_notify'>
<div class='section-title'>关于 TomatoAnon 项目</div>
<div class="fields"><div class="about">
<b>您好：</b><br>
<br>
我很高兴向您推荐一个刚研制出的新项目，它叫做TomatoAnon<br>
TomatoAnon会将您的路由型号和版本信息发送到数据中心。<br>
所有的信息全部经过匿名提交确认，仅仅作统计使用。<br>
<b>TomatoAnon绝不会发送任何私人信息（例如MAC、IP地址等）！</b><br>
TomatoAnon脚本是全开源，用bash编写，任何人都可以查看其中的相关信息。<br>
<br>
认证结果可以在此网站查看 <a href=http://tomato.groov.pl/tomatoanon.php target=_blanc><b>http://tomato.groov.pl/tomatoanon.php</b></a> <br>
这些信息可以帮您挑选您国家最流行实用的路由型号，<br>
您也可以查到使用最广的Tomato路由版本号。<br>
<br>
如果您不同意此协议，或者不想运行TomatoAnon，您可以直接禁用它。<br>
您也可以随时重新开启它。<br>
<br>
TomatoAnon会向数据中心发送如下数据：<br>
 - WAN+LAN MAC地址的MD5校验值 - 此项用于验证路由器身份。例如：1c1dbd4202d794251ec1acf1211bb2c8<br>
 - 路由的型号。例如：Asus RT-N66U<br>
 - Tomato安装的固件版本号。例如：102 K26 USB<br>
 - 编译类型描述。例如： Ex: Mega-VPN-64K<br>
 - 路由器开机时间。例如：3 天<BR>
 <br>
<br>
<br>
感谢你阅读此说明，并希望能够启用TomatoAnon以支持该项目！
<br>
<br>
<b>祝好！</b></font>
</div></div>
<br>
<br>
<div class='section-title'>TomatoAnon 配置 <script>W(anon_link);</script></div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '您了解TomatoAnon是干什么的吗?', name: 'tomatoanon_answer', type: 'select', options: [ ['0','我不清楚，我必须在读完所有信息后才能做出选择。'], ['1','是的，我了解并且希望选择它。'] ], value: nvram.tomatoanon_answer, suffix: ' '},
	{ title: '您想启用TomatoAnon吗?', name: 'tomatoanon_enable', type: 'select', options: [ ['-1','现在还不想'], ['1','是的，我确定要启用'], ['0','我丝毫不感兴趣也不想启用它'] ], value: nvram.tomatoanon_enable, suffix: ' '},
	{ title: '每隔...时间发送', indent: 2, name: 'tomatoanon_cru', type: 'text', maxlen: 5, size: 7, value: nvram.tomatoanon_cru, suffix: ' <small>小时 (范围: 1 - 12; 缺省: 6)</small>' }
]);
</script>
</div>

<div class='section-title'>Tomato 更新通知系统</div>
<div class='section'>
<script type='text/javascript'>
createFieldTable('', [
{ title: '启用', name: 'f_tomatoanon_notify', type: 'checkbox', value: nvram.tomatoanon_notify == '1' }
]);
</script>
<ul>
	<li>当有新的Tomato版本可以更新时，将在“系统状态”页面通知您。
</ul>
</div>
</form>
</div>
</td></tr>
<tr><td id='footer' colspan=2>
 <form>
 <span id='footer-msg'></span>
 <input type='button' value='保存设置' id='save-button' onclick='save()'>
 <input type='button' value='取消设置' id='cancel-button' onclick='javascript:reloadPage();'>
 </form>
</div>
</td></tr>
</table>
<script type='text/javascript'>verifyFields(null, 1);</script>



</body>
</html>
