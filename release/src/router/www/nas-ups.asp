<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] NAS: UPS 监控</title>

<link rel='stylesheet' type='text/css' href='bootstrap.css'>
<link rel='stylesheet' type='text/css' href='new.css'>
<script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='bootstrap.js'></script>
<style type='text/css'>
textarea {
width: 98%;
height: 5em;
}
</style>
<style type='text/css'>
#dev-grid .co1 {
width: 10%;
}
#dev-grid .co2 {
width: 9%;
}
#dev-grid .co3 {
width: 65%;
}
#dev-grid .co4 {
width: 16%;
text-align: center;
}
#dev-grid .header {
text-align: left;
}
</style>
<script type='text/javascript'>

//      <% nvram(""); %>

function init()
{
	clientSideInclude('ups-status', '/ext/cgi-bin/tomatoups.cgi');
	clientSideInclude('ups-data', '/ext/cgi-bin/tomatodata.cgi');
}
function clientSideInclude(id, url) {
  var req = false;
  // For Safari, Firefox, and other non-MS browsers
  if (window.XMLHttpRequest) {
    try {
      req = new XMLHttpRequest();
    } catch (e) {
      req = false;
    }
  } else if (window.ActiveXObject) {
    // For Internet Explorer on Windows
    try {
      req = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
      try {
        req = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (e) {
        req = false;
      }
    }
  }
 var element = document.getElementById(id);
 if (!element) {
  alert("Bad id " + id + 
   "传递给clientSideInclude。" +
   "你需要一个DIV或SPAN元素 " +
   "与此ID在你的页面。");
  return;
 }
  if (req) {
    // Synchronous request, wait till we have it all
    req.open('GET', url, false);
    req.send(null);
    element.innerHTML = req.responseText;
  } else {
    element.innerHTML =
   "对不起，您的浏览器不支持" +
      "XMLHTTPRequest的对象。此页面需要 " +
      "Internet Explorer 5或更好的适用于Windows， " +
      "任何系统或Firefox或Safari浏览器。其他" +
      "兼容的浏览器可能也存在。";
  }
}
</script>
</head>
<body onload='init()'>
<form id='_fom' method='post' action='tomato.cgi'>
<table id='container' class="table" cellspacing=0>

<tr id='body'>
<td id='content' style="height: 188px">
	
	<input type='hidden' name='_nextpage' value='nas-ups.asp'>
	<div class='section-title'>APC UPS状态</div>
	<div class='section'>
		<span id="ups-status"></span>
	</div>
	<div class='section-title'>APC UPS响应</div>
	<div class='section'>
		<span id="ups-data"></span>
	</div>
</td></tr>
<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
</form>
</body>
</html>
