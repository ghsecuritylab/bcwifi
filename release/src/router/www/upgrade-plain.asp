<html><head><title>Firmware Upgrade</title></head>
<body>
<h1>固件升级</h1>
<b>警告：</b>
<ul>
<li>此页面没有上传状态信息，当点击升级按钮后无更新进度，必须更新完成后才会显示新的页面。
<li>固件升级完成大约需要3分钟. 在这期间请不要断开路由器或此浏览页面。
</ul>

<br>
<form name="firmware_upgrade" method="post" action="upgrade.cgi?<% nv(http_id) %>" encType="multipart/form-data">
<input type="hidden" name="submit_button" value="Upgrade">
固件文件: <input type="file" name="file"> <input type="submit" value="升级">
</form>
</body></html>
