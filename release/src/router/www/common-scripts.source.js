var menu = [
    ['系统状态',            'status', 0, [
        ['系统状态',            'overview.asp'],
        ['联机设备',            'devices.asp'],
        ['网站记录',            'webmon.asp'],
        ['日志信息',            'log.asp'] 
    ] ],
    ['带宽监控',            'bwm', 0, [
        ['实时流量',            'realtime.asp'],
        ['24小时流量',      '24.asp'],
        ['每日流量',            'daily.asp'],
        ['每周流量',            'weekly.asp'],
        ['每月流量',            'monthly.asp']
    ] ],
    ['IP流量监控',          'ipt', 0, [
        ['实时流量',            'realtime.asp'],
        ['24小时流量',      '24.asp'],
        ['图形分析',            'graphs.asp'],
        ['传输速率',        'details.asp'],
        ['每日流量',            'daily.asp'],
        ['每月流量',            'monthly.asp']
    ] ],
    ['诊断工具',            'tools', 0, [
        ['Ping',            'ping.asp'],
        ['追踪路由',            'trace.asp'],
        ['系统命令',            'shell.asp'],
        ['无线搜寻',        'survey.asp'],
        ['网络唤醒',                'wol.asp'] 
    ] ],
    ['基本设置',            'basic', 0, [
        ['网络设置',            'network.asp'],
/* IPV6-BEGIN */
        ['IPv6设置',          'ipv6.asp'],
/* IPV6-END */
        ['名称设置',        'ident.asp'],
        ['时间设置',            'time.asp'],
        ['动态域名',            'ddns.asp'],
        ['静态DHCP',      'static.asp'],
        ['无线过滤',        'wfilter.asp'] 
    ] ],
    ['高级设置',            'advanced', 0, [
        ['连接数/超时设置',        'ctnf.asp'],
        ['DHCP/DNS',            'dhcpdns.asp'],
        ['防火墙设置',           'firewall.asp'],
        ['MAC地址设置',         'mac.asp'],
        ['其它设置',        'misc.asp'],
        ['路由表设置',           'routing.asp'],
/* TOR-BEGIN */
//        ['TOR设置',           'tor.asp'],
/* TOR-END */
        ['VLAN设置',          'vlan.asp'],
        ['LAN控制',           'access.asp'],
        ['VIF 设置',      'wlanvifs.asp'],
        ['无线设置',            'wireless.asp'] 
    ] ],
    ['端口转发',        'forward', 0, [
        ['IPv4转发',          'basic.asp'],
/* IPV6-BEGIN */
        ['IPv6转发',          'basic-ipv6.asp'],
/* IPV6-END */
        ['DMZ设置',               'dmz.asp'],
        ['端口触发',            'triggered.asp'],
        ['UPnP/NAT-PMP',        'upnp.asp'] ] ],
    ['访问限制',        'lim',  0,  [
        ['访问限制', 'restrict.asp'],
        ['IP带宽限速',      'bwlimit.asp'],
        ['第三方认证',       'hotspot.asp'],
//        ['网络通告',        'splashd.asp'] 
    ] ],
    ['QoS设置',               'qos', 0, [
        ['基本设置',        'settings.asp'],
        ['分类设置',        'classify.asp'],
        ['图形分析',            'graphs.asp'],
        ['链接查看',        'detailed.asp'],
        ['传输速率',        'ctrate.asp']
    ] ],
/* REMOVE-BEGIN
    ['Scripts',             'sc', 0, [
        ['Startup',     'startup.asp'],
        ['Shutdown',        'shutdown.asp'],
        ['Firewall',        'firewall.asp'],
        ['WAN Up',      'wanup.asp']
        ] ],
REMOVE-END */
/* USB-BEGIN */
// ---- !!TB - USB, FTP, Samba, Media Server
//    ['USB and NAS',         'nas', 0, [
//        ['USB Support',         'usb.asp']
/* FTP-BEGIN */
//        ,['FTP Server',         'ftp.asp']
/* FTP-END */
/* SAMBA-BEGIN */
//        ,['File Sharing',       'samba.asp']
/* SAMBA-END */
/* MEDIA-SRV-BEGIN */
//        ,['Media Server',       'media.asp']
/* MEDIA-SRV-END */
/* UPS-BEGIN */
//        ,['UPS Monitor',        'ups.asp']
/* UPS-END */
/* BT-BEGIN */
//        ,['BitTorrent Client',      'bittorrent.asp']
/* BT-END */
//        ] ],
/* USB-END */
/* VPN-BEGIN */
//    ['VPN设置',           'vpn', 0, [
/* OPENVPN-BEGIN */
//        ['OpenVPN服务器',      'server.asp'],
//        ['OpenVPN客户端',      'client.asp'],
/* OPENVPN-END */
/* PPTPD-BEGIN */
//        ['PPTP服务器',         'pptp-server.asp'],
//        ['PPTP在线用户',            'pptp-online.asp'],
//        ['PPTP客户端',         'pptp.asp']
/* PPTPD-END */
//    ] ],
/* VPN-END */
    ['系统管理',        'admin', 0, [
        ['访问设置',        'access.asp'],
        ['带宽监控',    'bwm.asp'],
        ['IP流量监控',  'iptraffic.asp'],
        ['按钮/指示灯',          'buttons.asp'],
/* CIFS-BEGIN */
//        ['CIFS客户端',         'cifs.asp'],
/* CIFS-END */
/* SDHC-BEGIN */
//        ['SDHC/MMC',            'sdhc.asp'],
/* SDHC-END */
        ['备份恢复',        'config.asp'],
        ['调试',          'debug.asp'],
/* JFFS2-BEGIN */
//        ['JFFS',            'jffs2.asp'],
/* JFFS2-END */
/* NFS-BEGIN */
//        ['NFS Server',          'nfs.asp'],
/* NFS-END */
/* SNMP-BEGIN */
//        ['SNMP',            'snmp.asp'],
/* SNMP-END */
        ['日志管理',            'log.asp'],
        ['定时重启/连接',         'sched.asp'],
        ['脚本设置',            'scripts.asp'],
        ['固件升级',            'upgrade.asp'] 
    ] ] 
];

var Script = function () {
    var tname = "";
    jQuery('#sidebar').on('click','.sub-menu>a',function(){
        $(this).parent().siblings('li').children('a').removeClass('active');
        $(this).parent().siblings('li').children('ul.sub').slideUp('slow');
        $(this).siblings('ul').children('li').removeClass('active');
        tname = $(this).text();
        $('.panel-heading').text(tname);
        if($(this).siblings('ul').css('display')=='none'){
            $(this).addClass('active');
            $(this).siblings('ul').slideDown('slow');
            var pervCloseLi=$(this).parent('li.sub-menu').prevAll('li.sub-menu');
            $('#nav-accordion').scrollTop(pervCloseLi.length*$(pervCloseLi[0]).height());
        } else{
            $(this).removeClass('active');
            $(this).siblings('ul').slideUp('slow');
        }
    })
    jQuery('#sidebar').on('click','.sub>li>a',function(){
        $('.panel-heading').text(tname+'>'+$(this).text());
        $(this).parent('li').siblings('li').removeClass('active');
        $(this).parent('li').addClass('active');
    });
   
    $(function() {
        loadSidebar();
        function responsiveView() {
            var contentHeight=$(window).height()-$(".header").outerHeight()-$('.footer').outerHeight();
            $("#main-content").css('height',contentHeight);
            $("#sidebar ul.sidebar-menu").height(contentHeight-50);
            var wSize = $(window).width();
            if (wSize <= 768) {
                $('#container').addClass('sidebar-close');
                $('#sidebar > ul').hide();
            }

            if (wSize > 768) {
                $('#container').removeClass('sidebar-close');
                $('#sidebar > ul').show();
            }
        }
        $(window).on('load', responsiveView);
        $(window).on('resize', responsiveView);
        $("#ifrm").load(function(){
            iFrameHeight();
        })
    });

    $('.J_slidebar').click(function () {
        if ($('#sidebar > ul').is(":visible") === true) {
            $('#main-content').css({
                'margin-left': '20px'
            });
            $(".J_slidebar").css({
                'margin-left':'-190px'
            })
            $('.J_slidebar').addClass('hidden-sidebar')

            $('#sidebar').css({
                'margin-left': '-190px'
            });
            $('#sidebar > ul').hide();
            $("#container").addClass("sidebar-closed");
        } else {
            $('#main-content').css({
                'margin-left': '210px'
            });
            $('#sidebar > ul').show();
            $('#sidebar').css({
                'margin-left': '0'
            });
             $(".J_slidebar").css({
                'margin-left':'0px'
            })
            $('.J_slidebar').removeClass('hidden-sidebar')
            $("#container").removeClass("sidebar-closed");
        }
    });

    $('.panel .tools .icon-chevron-down').click(function () {
        var el = $(this).parents(".panel").children(".panel-body");
        if ($(this).hasClass("icon-chevron-down")) {
            $(this).removeClass("icon-chevron-down").addClass("icon-chevron-up");
            el.slideUp(200);
        } else {
            $(this).removeClass("icon-chevron-up").addClass("icon-chevron-down");
            el.slideDown(200);
        }
    });

    function iFrameHeight() { 
        var contentHeight=$(window).height()-$("header").outerHeight()-$('.footer').outerHeight();
        var header=parseInt($("#main-content .wrapper").css('margin-top'),10)+$("#main-content .wrapper .row").outerHeight();
        $("#ifrm").height(contentHeight-header-$("#container .panel-heading").outerHeight()-30);
    } 
    function loadSidebar(){
        var len = menu.length;
        var html = "";
        for (var i = 0; i <len; i++) {
            if (menu[i].length == 4) {
                var subs = menu[i][3];
                html += '<li class="sub-menu">\
                      <a href="javascript:;">\
                          <i class="icon-laptop"></i>\
                          <span>'+menu[i][0]+'</span>\
                          <span class="dcjq-icon"></span>\
                      </a>\
                      <ul class="sub">';
                for (var j = 0; j < subs.length; j++) {
                    html+='<li><a target="ifrm" href="'+menu[i][1]+'-'+subs[j][1]+'">'+subs[j][0]+'</a></li>';
                };
                html+='</ul></li>';
            }
        };
        $("#nav-accordion").html(html);
    }
}();