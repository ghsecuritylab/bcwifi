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
<title>[<% ident(); %>] 带宽监控：实时流量</title>

<link rel='stylesheet' type='text/css' href='bootstrap.css'>
<link rel='stylesheet' type='text/css' href='new.css'>



 <script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='bootstrap.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='bwm-common.js'></script>
<script type='text/javascript'>
//	<% nvram("wan_ifname,lan_ifname,wl_ifname,wan_proto,wan_iface,web_svg,rstats_colors"); %>

var cprefix = 'bw_r';
var updateInt = 2;
var updateDiv = updateInt;
var updateMaxL = 300;
var updateReTotal = 1;
var prev = [];
var debugTime = 0;
var avgMode = 0;
var wdog = null;
var wdogWarn = null;


var ref = new TomatoRefresh('update.cgi', 'exec=netdev', 2);

ref.stop = function() {
	this.timer.start(1000);
}

ref.refresh = function(text) {
	var c, i, h, n, j, k;

	watchdogReset();

	++updating;
	try {
		netdev = null;
		eval(text);

		n = (new Date()).getTime();
		if (this.timeExpect) {
			if (debugTime) E('dtime').innerHTML = (this.timeExpect - n) + ' ' + ((this.timeExpect + 2000) - n);
			this.timeExpect += 2000;
			this.refreshTime = MAX(this.timeExpect - n, 500);
		}
		else {
			this.timeExpect = n + 2000;
		}

		for (i in netdev) {
			c = netdev[i];
			if ((p = prev[i]) != null) {
				h = speed_history[i];

				h.rx.splice(0, 1);
				h.rx.push((c.rx < p.rx) ? (c.rx + (0xFFFFFFFF - p.rx)) : (c.rx - p.rx));

				h.tx.splice(0, 1);
				h.tx.push((c.tx < p.tx) ? (c.tx + (0xFFFFFFFF - p.tx)) : (c.tx - p.tx));
			}
			else if (!speed_history[i]) {
				speed_history[i] = {};
				h = speed_history[i];
				h.rx = [];
				h.tx = [];
				for (j = 300; j > 0; --j) {
					h.rx.push(0);
					h.tx.push(0);
				}
				h.count = 0;
			}
			prev[i] = c;
		}
		loadData();
	}
	catch (ex) {
	}
	--updating;
}

function watchdog()
{
	watchdogReset();
	ref.stop();
	wdogWarn.style.display = '';
}

function watchdogReset()
{
	if (wdog) clearTimeout(wdog)
	wdog = setTimeout(watchdog, 10000);
	wdogWarn.style.display = 'none';
}

function init()
{
	speed_history = [];

	initCommon(2, 1, 1);

	wdogWarn = E('warnwd');
	watchdogReset();

	ref.start();
}
</script>

</head>
<body onload='init()'>
<form>
<table id='container' cellspacing=0 class="table">

<tr id='body'>
<td id='content'>
<div id='rstats'>
	<div id='tab-area'></div>

	<script type='text/javascript'>
	if (nvram.web_svg != '0') {
		// without a div, Opera 9 moves svgdoc several pixels outside of <embed> (?)
		W("<div style='border-top:1px solid #f0f0f0;border-bottom:1px solid #f0f0f0;visibility:hidden;padding:0;margin:0' id='graph'><embed src='bwm-graph.svg?<% version(); %>' style='width:100%;height:300px;margin:0;padding:0' type='image/svg+xml' pluginspage='http://www.adobe.com/svg/viewer/install/'></embed></div>");
	}
	</script>
	    
	<div id='bwm-controls'>
		<div class="btn-group" title="平均">
		  <button type="button" onclick="javascript:switchAvg(1)" id="avg1" class="btn btn-default">关闭</button>
		  <button type="button" onclick="javascript:switchAvg(2)" id='avg2' class="btn btn-default">2x</button>
		  <button type="button" onclick="javascript:switchAvg(4)" id='avg3' class="btn btn-default">4x</button>
		  <button type="button" onclick="javascript:switchAvg(6)" id='avg4' class="btn btn-default">6x</button>
		  <button type="button" onclick="javascript:switchAvg(8)" id='avg5' class="btn btn-default">8x</button>
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
	    
	<br><br>
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
<br>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='warnwd' style='display:none'>警告: 超时 10 秒钟, 重新绘图中...&nbsp;</span>
	<span id='dtime'></span>
	<img src='spin.gif' id='refresh-spinner' onclick='javascript:debugTime=1'>
</td></tr>
</table>
</form>


</body>
</html>
