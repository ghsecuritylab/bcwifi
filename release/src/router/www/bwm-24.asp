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
<title>[<% ident(); %>] 带宽监控：最近24小时</title>

<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/bootstrap.css'>
<link rel='stylesheet' type='text/css' href='http://dev.plat.gionee.com/static/new.css'>


<script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='http://dev.plat.gionee.com/static/bootstrap.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='bwm-common.js'></script>
<script type='text/javascript'>

//	<% nvram("wan_ifname,lan_ifname,wl_ifname,wan_proto,wan_iface,web_svg,rstats_enable,rstats_colors"); %>

var cprefix = 'bw_24';
var updateInt = 120;
var updateDiv = updateInt;
var updateMaxL = 720;
var updateReTotal = 1;
var hours = 24;
var lastHours = 0;
var debugTime = 0;

function showHours()
{
	if (hours == lastHours) return;
	showSelectedOption('hr', lastHours, hours);
	lastHours = hours;
}

function switchHours(h)
{
	if ((!svgReady) || (updating)) return;

	hours = h;
	updateMaxL = (720 / 24) * hours;
	showHours();
	loadData();
	cookie.set(cprefix + 'hrs', hours);
}

var ref = new TomatoRefresh('update.cgi', 'exec=bandwidth&arg0=speed');

ref.refresh = function(text)
{
	++updating;
	try {
		this.refreshTime = 1500;
		speed_history = {};
		try {
			eval(text);
			if (rstats_busy) {
				E('rbusy').style.display = 'none';
				rstats_busy = 0;
			}
			this.refreshTime = (fixInt(speed_history._next, 1, 120, 60) + 2) * 1000;
		}
		catch (ex) {
			speed_history = {};
		}
		if (debugTime) E('dtime').innerHTML = (new Date()) + ' ' + (this.refreshTime / 1000);
		loadData();
	}
	catch (ex) {
//		alert('ex=' + ex);
	}
	--updating;
}

ref.showState = function()
{
	E('refresh-button').value = this.running ? '停止' : '开始';
}

ref.toggleX = function()
{
	this.toggle();
	this.showState();
	cookie.set(cprefix + 'refresh', this.running ? 1 : 0);
}

ref.initX = function()
{
	var a;

	a = fixInt(cookie.get(cprefix + 'refresh'), 0, 1, 1);
	if (a) {
		ref.refreshTime = 100;
		ref.toggleX();
	}
}

function init()
{
	if (nvram.rstats_enable != '1') return;

	try {
	//	<% bandwidth("speed"); %>
	}
	catch (ex) {
		speed_history = {};
	}
	rstats_busy = 0;
	if (typeof(speed_history) == 'undefined') {
		speed_history = {};
		rstats_busy = 1;
		E('rbusy').style.display = '';
	}

	hours = fixInt(cookie.get(cprefix + 'hrs'), 1, 24, 24);
	updateMaxL = (720 / 24) * hours;
	showHours();

	initCommon(1, 0, 0);
	ref.initX();
}
</script>

</head>
<body onload='init()'>
<form>
<table id='container' cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<div id='rstats'>
	<div id='tab-area'></div>

	<script type='text/javascript'>
	if ((nvram.web_svg != '0') && (nvram.rstats_enable == '1')) {
		// without a div, Opera 9 moves svgdoc several pixels outside of <embed> (?)
		W("<div style='border-top:1px solid #f0f0f0;border-bottom:1px solid #f0f0f0;visibility:hidden;padding:0;margin:0' id='graph'><embed src='bwm-graph.svg?<% version(); %>' style='width:100%;height:300px;margin:0;padding:0' type='image/svg+xml' pluginspage='http://www.adobe.com/svg/viewer/install/'></embed></div>");
	}
	</script>

		<div id='bwm-controls'>
		<div class="btn-group" title="单位（小时）">
		  <button type="button" onclick="javascript:switchHours(1)" id="hr1" class="btn btn-default">1</button>
		  <button type="button" onclick="javascript:switchHours(2)" id='hr2' class="btn btn-default">2</button>
		  <button type="button" onclick="javascript:switchHours(4)" id='hr4' class="btn btn-default">4</button>
		  <button type="button" onclick="javascript:switchHours(6)" id='hr6' class="btn btn-default">6</button>
		  <button type="button" onclick="javascript:switchHours(12)" id='hr12' class="btn btn-default">12</button>
		   <button type="button" onclick="javascript:switchHours(18)" id='hr18' class="btn btn-default">18</button>
		    <button type="button" onclick="javascript:switchHours(24)" id='hr24' class="btn btn-default">24</button>
		</div>
		<div class="btn-group" title="平均">
		  <button type="button" onclick="javascript:switchAvg(1)" id="avg1" class="btn btn-default">关闭</button>
		  <button type="button" onclick="javascript:switchAvg(2)" id='avg2' class="btn btn-default">2x</button>
		  <button type="button" onclick="javascript:switchAvg(4)" id='avg4' class="btn btn-default">4x</button>
		  <button type="button" onclick="javascript:switchAvg(6)" id='avg6' class="btn btn-default">6x</button>
		  <button type="button" onclick="javascript:switchAvg(8)" id='avg8' class="btn btn-default">8x</button>
		</div>
		<div class="btn-group" title="最大">
		  <button type="button" onclick="javascript:switchScale(0)" id="scale0" class="btn btn-default">一致</button>
		  <button type="button" onclick="javascript:switchScale(1)" id='scale1' class="btn btn-default">每个</button>
		</div>
		<div class="btn-group" title="显示">
		  <button type="button" onclick="javascript:switchDraw(0)" id="draw0" class="btn btn-default">填充</button>
		  <button type="button" onclick="javascript:switchDraw(1)" id='draw1' class="btn btn-default">实线</button>
		</div>
		<div class="btn-group" title="颜色">
		  <button type="button" onclick="javascript:switchColor()" id="drawcolor" class="btn btn-default">-</button>
		  <button type="button" onclick="javascript:switchColor(1)" id='drawrev' class="btn btn-default">[颜色反转]</button>
		</div>
		<a class="btn btn-link" href="admin-bwm.asp">设置</a>
	</div>

	<table border=0 cellspacing=2 id='txt' class="table table-bordered table-striped">
	<tr>
		<td width='8%' align='right' valign='top'><b style='border-bottom:blue 1px solid' id='rx-name'>接收</b></td>
			<td width='15%' align='right' valign='top'><span id='rx-current'></span></td>
		<td width='8%' align='right' valign='top'><b>平均</b></td>
			<td width='15%' align='right' valign='top' id='rx-avg'></td>
		<td width='8%' align='right' valign='top'><b>最大</b></td>
			<td width='15%' align='right' valign='top' id='rx-max'></td>
		<td width='8%' align='right' valign='top'><b>合计</b></td>
			<td width='14%' align='right' valign='top' id='rx-total'></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td width='8%' align='right' valign='top'><b style='border-bottom:blue 1px solid' id='tx-name'>传送</b></td>
			<td width='15%' align='right' valign='top'><span id='tx-current'></span></td>
		<td width='8%' align='right' valign='top'><b>平均</b></td>
			<td width='15%' align='right' valign='top' id='tx-avg'></td>
		<td width='8%' align='right' valign='top'><b>最大</b></td>
			<td width='15%' align='right' valign='top' id='tx-max'></td>
		<td width='8%' align='right' valign='top'><b>合计</b></td>
			<td width='14%' align='right' valign='top' id='tx-total'></td>
		<td>&nbsp;</td>
	</tr>
	</table>
</div>
<br>

<script type='text/javascript'>
if (nvram.rstats_enable != '1') {
	W('<div class="note-disabled">带宽监控已关闭。</b><br><br><a href="admin-bwm.asp">启用 &raquo;</a><div>');
	E('rstats').style.display = 'none';
}
else {
	W('<div class="note-warning" style="display:none" id="rbusy">程序繁忙或没有响应，请稍后再试</div>');
}
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='dtime'></span>
	<img src='spin.gif' id='refresh-spinner' onclick='debugTime=1'>
	<input type='button' value='刷新' id='refresh-button' onclick='ref.toggleX()'>
</td></tr>
</table>
</form>


</body>
</html>
