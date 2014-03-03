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
<title>[<% ident(); %>] Clear Cookies</title>

<link rel='stylesheet' type='text/css' href='bootstrap.css'>
<link rel='stylesheet' type='text/css' href='new.css'>
<script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='bootstrap.js'></script>
</head>
<body>
<table id='container' class="table" cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<b>Cookies Cleared</b>

<script type='text/javascript'>
b = [];
c = document.cookie.split(';');
for (i = 0; i < c.length; ++i) {
	if (c[i].match(/^\s*tomato_(.+?)=/)) {
		b.push('<li>' + c[i]);
		cookie.unset(RegExp.$1);
	}
}
if (b.length == 0) b.push('<li>no cookie found');
W('<ul>' + b.join('') + '</ul>');
</script>


<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</body>
</html>
