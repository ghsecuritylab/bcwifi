<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.0//EN'>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	IP Traffic enhancements
	Copyright (C) 2011 Augusto Bott
	http://code.google.com/p/tomato-sdhc-vlan/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] IP 流量: 最近24小时</title>

<link rel='stylesheet' type='text/css' href='bootstrap.min.css'>
<link rel='stylesheet' type='text/css' href='new.css'>

<script src="jquery-1.8.3.min.js"></script>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript' src='debug.js'></script>
<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='bwm-common.js'></script>
<script type='text/javascript' src='bwm-hist.js'></script>
<script type='text/javascript' src='interfaces.js'></script>
<script type='text/javascript'>

//	<% nvram("wan_ifname,lan_ifname,wl_ifname,wan_proto,wan_iface,web_svg,cstats_enable,cstats_colors,dhcpd_static,lan_ipaddr,lan_netmask,lan1_ipaddr,lan1_netmask,lan2_ipaddr,lan2_netmask,lan3_ipaddr,lan3_netmask,cstats_labels"); %>

//	<% devlist(); %>

var cprefix = 'ipt_';
var updateInt = 120;
var updateDiv = updateInt;
var updateMaxL = 720;
var updateReTotal = 1;
var hours = 24;
var lastHours = 0;
var debugTime = 0;

var ipt_addr_shown = [];
var ipt_addr_hidden = [];

hostnamecache = [];

function showHours() {
	if (hours == lastHours) return;
	showSelectedOption('hr', lastHours, hours);
	lastHours = hours;
}

function switchHours(h) {
	if ((!svgReady) || (updating)) return;

	hours = h;
	updateMaxL = (720 / 24) * hours;
	showHours();
	loadData();
	cookie.set(cprefix + 'hrs', hours);
}

var ref = new TomatoRefresh('update.cgi', 'exec=ipt_bandwidth&arg0=speed');

ref.refresh = function(text) {
	++updating;
	try {
		this.refreshTime = 1500;
		speed_history = {};
		try {
			eval(text);

			var i;
			for (i in speed_history) {
				if ((ipt_addr_hidden.find(i) == -1) && (ipt_addr_shown.find(i) == -1) && (i != '_next')) {
					ipt_addr_shown.push(i);
					var option=document.createElement("option");
					option.value=i;
					if (hostnamecache[i] != null) {
						option.text = hostnamecache[i] + ' (' + i + ')';
					} else {
						option.text=i;
					}
					E('_f_ipt_addr_shown').add(option,null);
					speed_history[i].hide = 0;
				}

				if (ipt_addr_hidden.find(i) != -1) {
					speed_history[i].hide = 1;
				} else {
					speed_history[i].hide = 0;
				}
			}

			if (cstats_busy) {
				E('rbusy').style.display = 'none';
				cstats_busy = 0;
			}
			this.refreshTime = (fixInt(speed_history._next, 1, 120, 60) + 2) * 1000;
		} catch (ex) {
			speed_history = {};
			cstats_busy = 1;
			E('rbusy').style.display = '';
		}
		if (debugTime) E('dtime').innerHTML = (ymdText(new Date())) + ' ' + (this.refreshTime / 1000);

		loadData();
	}
	catch (ex) {
/* REMOVE-BEGIN
//		alert('ex=' + ex);
REMOVE-END */
	}
	--updating;
}

ref.showState = function() {
	E('refresh-button').value = this.running ? '停止' : '开始';
}

ref.toggleX = function() {
	this.toggle();
	this.showState();
	cookie.set(cprefix + 'refresh', this.running ? 1 : 0);
}

ref.initX = function() {
	var a;

	a = fixInt(cookie.get(cprefix + 'refresh'), 0, 1, 1);
	if (a) {
		ref.refreshTime = 100;
		ref.toggleX();
	}
}

function init() {
	if (nvram.cstats_enable != '1') {
		E('refresh-button').disabled = 1;
		return;
	}

	populateCache();

	var c,i;
	if ((c = cookie.get('ipt_addr_hidden')) != null) {
		c = c.split(',');
		for (var i = 0; i < c.length; ++i) {
			if (c[i].trim() != '') {
				ipt_addr_hidden.push(c[i]);
				var option=document.createElement("option");
				option.value=c[i];
				if (hostnamecache[c[i]] != null) {
					option.text = hostnamecache[c[i]] + ' (' + c[i] + ')';
				} else {
					option.text = c[i];
				}
				E('_f_ipt_addr_hidden').add(option,null);
			}
		}
	}

	try {
	//	<% ipt_bandwidth("speed"); %>

		for (i in speed_history) {
			if ((ipt_addr_hidden.find(i) == -1) && (ipt_addr_shown.find(i) == -1) && ( i != '_next') && (i.trim() != '')) {
				ipt_addr_shown.push(i);
				var option=document.createElement("option");
				var ii = i;
				if (hostnamecache[i] != null) {
					ii = hostnamecache[i] + ' (' + i + ')';
				}
				option.text=ii;
				option.value=i;
				E('_f_ipt_addr_shown').add(option,null);
				speed_history[i].hide = 0;
			}
			if (ipt_addr_hidden.find(i) != -1) {
				speed_history[i].hide = 1;
			} else {
				speed_history[i].hide = 0;
			}
		}
	}
	catch (ex) {
/* REMOVE-BEGIN
//		speed_history = {};
REMOVE-END */
	}
	cstats_busy = 0;
	if (typeof(speed_history) == 'undefined') {
		speed_history = {};
		cstats_busy = 1;
		E('rbusy').style.display = '';
	}

	hours = fixInt(cookie.get(cprefix + 'hrs'), 1, 24, 24);
	updateMaxL = (720 / 24) * hours;
	showHours();

	initCommon(1, 0, 0);

	verifyFields(null,1);

	var theRules = document.styleSheets[document.styleSheets.length-1].cssRules;
	switch (nvram['cstats_labels']) {
		case '1':		// show hostnames only
			theRules[theRules.length-1].style.cssText = 'width: 140px; font-weight:bold;';
/* REMOVE-BEGIN */
//			document.styleSheets[2].deleteRule(theRules.length - 1);
/* REMOVE-END */
			break;
		case '2':		// show IPs only
			theRules[theRules.length-1].style.cssText = 'width: 140px; font-weight:bold;';
			break;
		case '0':		// show hostnames + IPs
		default:
/* REMOVE-BEGIN */
//			theRules[theRules.length-1].style.cssText = 'width: 140px; height: 12px; font-size: 9px;';
/* REMOVE-END */
			break;
	}

	ref.initX();
}

function verifyFields(focused, quiet) {
	var changed_addr_hidden = 0;
	if (focused != null) {
		if (focused.id == '_f_ipt_addr_shown') {
			ipt_addr_shown.remove(focused.options[focused.selectedIndex].value);
			ipt_addr_hidden.push(focused.options[focused.selectedIndex].value);
			var option=document.createElement("option");
			option.text=focused.options[focused.selectedIndex].text;
			option.value=focused.options[focused.selectedIndex].value;
			E('_f_ipt_addr_shown').remove(focused.selectedIndex);
			E('_f_ipt_addr_shown').selectedIndex=0;
			E('_f_ipt_addr_hidden').add(option,null);
			changed_addr_hidden = 1;
		}

		if (focused.id == '_f_ipt_addr_hidden') {
			ipt_addr_hidden.remove(focused.options[focused.selectedIndex].value);
			ipt_addr_shown.push(focused.options[focused.selectedIndex].value);
			var option=document.createElement("option");
			option.text=focused.options[focused.selectedIndex].text;
			option.value=focused.options[focused.selectedIndex].value;
			E('_f_ipt_addr_hidden').remove(focused.selectedIndex);
			E('_f_ipt_addr_hidden').selectedIndex=0;
			E('_f_ipt_addr_shown').add(option,null);
			changed_addr_hidden = 1;
		}
		if (changed_addr_hidden == 1) {
			cookie.set('ipt_addr_hidden', ipt_addr_hidden.join(','), 1);
			if (!ref.running) {
				ref.once = 1;
				ref.start();
			} else {
				ref.stop();
				ref.start();
			}
		}
	}

	if (E('_f_ipt_addr_hidden').length < 2) {
		E('_f_ipt_addr_hidden').disabled = 1;
	} else {
		E('_f_ipt_addr_hidden').disabled = 0;
	}

	if (E('_f_ipt_addr_shown').length < 2) {
		E('_f_ipt_addr_shown').disabled = 1;
	} else {
		E('_f_ipt_addr_shown').disabled = 0;
	}

	return 1;
}
</script>

</head>
<body onload='init()'>
<form>
<table id='container' class="table" cellspacing=0>

<tr id='body'>
<td id='content'>


<!-- / / / -->

<div id='cstats'>
	<div id='tab-area'></div>

	<script type='text/javascript'>
	if ((nvram.web_svg != '0') && (nvram.cstats_enable == '1')) {
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
		<a class="btn btn-link" href="admin-iptraffic.asp">设置</a>
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

<!-- / / / -->

<br>

<div>
<script type='text/javascript'>
createFieldTable('', [
	{ title: '当前显示的 IP', name: 'f_ipt_addr_shown', type: 'select', options: [[0,'选择']], suffix: ' <small>(选取要隐藏的IP)</small>' },
	{ title: '当前被隐藏 IP', name: 'f_ipt_addr_hidden', type: 'select', options: [[0,'选择']], suffix: ' <small>(选取要重新显示的IP)</small>' }
	]);
</script>
</div>

</div>

</div>
<br>

<!-- / / / -->

<script type='text/javascript'>
if (nvram.cstats_enable != '1') {
	W('<div class="note-disabled">IP 流量监控已关闭.</b><br><br><a href="admin-iptraffic.asp">启用 &raquo;</a><div>');
	E('cstats').style.display = 'none';
}else {
	W('<div class="note-warning" style="display:none" id="rbusy">cstat程序忙或没有响应. 几秒钟后充实加载.</div>');
}
</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='dtime'></span>
	<img src='spin.gif' id='refresh-spinner' onclick='debugTime=1'>
	<input type='button' class="btn btn-primary" value='刷新' id='refresh-button' onclick='ref.toggleX()'>
</td></tr>
</table>
</form>


</body>
</html>
