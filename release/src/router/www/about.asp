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
<title>[<% ident(); %>] About</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<link rel='stylesheet' type='text/css' href='v8.css'>
<script type='text/javascript' src='tomato.js'></script>
<script type='text/javascript'>
//	<% nvram(''); %>	// http_id

var clicks = 0;
var tux = null;
var t = 0;
var r = 3;
var rd = 1;

function moo()
{
	if ((r <= 2) || (r >= 25)) rd = -rd;
	r += rd;
	t += (Math.PI / 10);
	if (t > (2 * Math.PI)) t = 0;

	var x = tux.origX + (r * Math.sin(t));
	var y = tux.origY + (r * Math.cos(t));

	tux.style.left = x + 'px';
	tux.style.top = y + 'px';

	if (clicks > 0) setTimeout(moo, 33);
}

function onClick()
{
	try {
		++clicks;
		if (clicks < 10) moo();
			else clicks = 0;
	}
	catch (ex) {
	}
}

function init()
{
	try {
		tux = E('tux');

		var o = elem.getOffset(tux);
		tux.origX = o.x;
		tux.origY = o.y;

		tux.style.position = 'absolute';
		tux.style.left = o.x + 'px';
		tux.style.top = o.y + 'px';

		tux.addEventListener('click', onClick, false);
	}
	catch (ex) {
	}
}
</script>
<!-- / / / -->

</head>
<body onload='init()'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
<div class='version'></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<div style='float:right;margin:20px 20px;text-align:center'>
<img src='tux.png' alt='Linux &amp; Tomato' id='tux'>
</div>
<div class='about'>
<b>Tomato Firmware <% version(1); %></b><br>
<br>

<!-- 佐须之男 -->
<b>“佐须之男”的特性：</b><br>
- 海蜘蛛专用拨号实现<br>
- 第三方认证路由端实现<br>
<br>
<a href='http://www.router.tw' target='_new'>http://www.router.tw</a><br>
<!-- www.router.tw -->

<!-- USB-BEGIN -->
<br>USB支持集成和图形用户界面<br>
<!-- USB-END -->
<!-- IPV6-BEGIN -->
IPv6 支持
<!-- IPV6-END -->
<br>
Linux内核<% version(2); %>和Broadcom无线驱动程序<% version(3); %> 更新<br>
支持额外的路由器型号，双频Wireless-N模式<br>
<br>
<a href='http://www.tomatousb.org/' target='_new'>http://www.tomatousb.org</a><br>
<!-- / / / -->

<!-- OPENVPN-BEGIN -->
<b>打开VPN的集成和图形用户界面</b><br>
<br>
<a href='mailto:tomatovpn@keithmoyer.com'></a><br>
<br>
<!-- OPENVPN-END -->
<b>“Shibby”的特性：</b><br>
<!-- BBT-BEGIN -->
- Transmission 2.77 集成<br>
<!-- BBT-END -->
<!-- BT-BEGIN -->
- GUI图形化界面<br>
<!-- BT-END -->
<!-- NFS-BEGIN -->
- 集成图形化NFS模块<br>
<!-- NFS-END -->
- 自定义日志路径<br>
<!-- LINUX26-BEGIN -->
- 基于Linux 2.6内核的SD-idle整合工具<br>
<!-- USB-BEGIN -->
- 支持3G模块<br>
<!-- USB-END -->
<!-- LINUX26-END -->
<!-- SNMP-BEGIN -->
- 支持图形化的SNMP管理<br>
<!-- SNMP-END -->
<!-- UPS-BEGIN -->
- 集成图形化APCUPSD模块<br>
<!-- UPS-END -->
<!-- DNSCRYPT-BEGIN -->
- 支持图形化的DNS代理1.0<br>
<!-- DNSCRYPT-END -->
<!-- TOR-BEGIN -->
- 整合图形化TOR项目<br>
<!-- TOR-END -->
- 整合图形化TomatoAnon项目<br>
- 整合图形化TomatoThemeBase项目<br>
- 网卡端口信息<br>
- 扩展MOTD模块 <br>
- Webmon备份脚本<br>
<br>
<a href='http://openlinksys.info' target='_new'></a><br>
<br>

<!-- VPN-BEGIN -->
<b>"JYAvenard" 特性：</b><br>
<!-- OPENVPN-BEGIN -->
- 增强型OpenVPN &amp; 仅 用户名/密码 验证方式<br>
<!-- OPENVPN-END -->
<!-- PPTPD-BEGIN -->
- 支持图形化PPTP VPN客户端<br>
<!-- PPTPD-END -->
<br>
<a href='mailto:jean-yves@avenard.org'></a><br>
<br>
<!-- VPN-END -->

<b>"Victek" 特性：</b><br>
- 扩展系统信息<br>
<!-- NOCAT-BEGIN -->
- 锁定接口 <br>
<!-- NOCAT-END -->
<!-- HFS-BEGIN -->
- 支持HFS / HFS+文件系统 <br>
<!-- HFS-END -->
<br>
<a href='http://victek.is-a-geek.com' target='_new'></a><br>
<br>

<b>"Teaman" 特性：</b><br>
- QOS明细 & ctrate过滤器<br>
- LAN客户端的实时带宽监控<br>
- 静态ARP绑定<br>
- 图形化VLAN管理 <br>
- 支持多LAN接口<br>
- 支持多条/虚拟SSID (测试版)<br>
- 支持图形化UDPxy<br>
<!-- PPTPD-BEGIN -->
- 支持图形化PPTP服务<br>
<!-- PPTPD-END -->
<br>
<a href='http://code.google.com/p/tomato-sdhc-vlan/' target='_new'></a><br>
<br>

<b>"Toastman" 特性：</b><br>
- 可配置QOS类别名称<br>
- 附带多种网络案例下的QOS默认配置<br>
- 支持TC-ATM管理计算 - 需安装tvlz补丁<br>
- 硬盘驱动器支持GPTGPT模式<br>
- 工具-系统时间同步<br>
<br>
<a href='http://www.linksysinfo.org/index.php?threads/using-qos-tutorial-and-discussion.28349/' target='_new'>使用QoS - 指南与论坛</a><br>
<br>

<b>"Tiomo" 特性：</b><br>
- 基于QOS Ingress的IMQ扩展 <br>
- 各类别网络带宽的下行图表<br>
<br>
<br>

<!-- SDHC-BEGIN -->
<b>"Slodki" 特性：</b><br>
- 支持图形化SDHC<br>
<br>
<a href='http://gemini.net.pl/~slodki/tomato-sdhc.html' target='_new'>tomato-sdhc</a><br>
<br>
<!-- SDHC-END -->

<b>"Victek/PrinceAMD/Phykris/Shibby" 特性：</b><br>
- 修正IP/MAC绑定限制<br>
<br>

<br>
基于 Tomato Firmware v<% version(); %><br>
<br>
<a href='http://www.polarcloud.com/tomato/' target='_new'>http://www.polarcloud.com/tomato/</a><br>
<br>
创建于 <% build_time(); %> by ForgotFun@gmail.com, <a href='http://www.router.tw' target='_new'>http://www.router.tw</a><br><br>
<br><br>

<!--

	Please do not remove or change the homepage link or donate button.

	Thanks.
	- Jon

-->

<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="image" src="pp.gif" border="0" name="submit" alt="Donate">
<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----">
</form>

<div style='border-top:1px solid #e7e7e7;margin:4em 0;padding:2em 0;font-size:12px'>
<b>感谢每个参与此路由测试、报告bugs、提出建议和贡献的人。 ^ _ ^</b><br>
</div>

</div>
<!-- / / / -->

</td></tr>
	<tr><td id='footer' colspan=2>&nbsp;</td></tr>
</table>
<div id="bottom">Copyright © 2012-2013 By <a href="http://www.ethinking.cn/wweb/" target="_blank">苏州亿想中电子科技有限公司</a> All Rights Reserved. <br/>软件版本<% version(); %></div>


</body>
</html>
