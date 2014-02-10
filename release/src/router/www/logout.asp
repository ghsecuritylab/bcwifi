<html>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
</head>
<body style='background-color:#fff;font:13px sans-serif;color:#000' onload='setTimeout("go.submit()", 1200)'>

<div style='width:300px;padding:50px;background:#eee'>
<b>注销</b><br>
<hr size=1><br>
要清除浏览器缓存的凭据：<br>
<br>
<b>火狐，IE浏览器，谷歌浏览器，Safari浏览器</b><br>
- 将密码字段留空。<br>
- 单击“确定”/登录<br>
<br>
<b>Chrome浏览器</b><br>
- 选择“取消”.<br>
</div>

<form name='go' method='post' action='logout'>
<input type='hidden' name='_http_id' value='<% nv(http_id); %>'>
</form>
</body></html>
