<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv='content-type' content='text/html;charset=utf-8'>
    <meta name='robots' content='noindex,nofollow'>
    <title>系统状态：日志记录文件</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <link href="http://dev.plat.gionee.com/static/bootstrap.css" rel="stylesheet">
    <link href="http://dev.plat.gionee.com/static/new.css" rel="stylesheet">
  </head>
  <body>
  <div id="container" >
    <!-- 头部信息 -->
      <div class="header gray-bg">
        <a href="index.asp" class="logo"><img  alt="" src="wifi.png">Ami-WiFi</span></a>
        <div class="top-nav ">
          <ul class="nav pull-right top-menu">
            <li><a href="javascript:reboot();"><i class="icon-repeat"></i>重启</a></li>
            <li><a href="javascript:shutdown();"><i class="icon-off"></i>关机</a></li>
            <li><a href="javascript:logout();"><i class="icon-signout"></i>退出</a></li>
          </ul>
        </div>
      </div>
     <!-- 侧表栏 -->
      <div class="aside">
        <div class="sidebar-toggle-box J_slidebar">
        </div>
        <div id="sidebar"  class="nav-collapse ">
          <ul class="sidebar-menu" id="nav-accordion">
          </ul>
        </div>
      </div>
     <!-- main content -->
      <div id="main-content">
          <div class="wrapper">
            <!-- page start-->
              <div class="panel">
                  <div class="panel-heading">
                      <% ident(); %>
                      <span class="tools pull-right">
                        <a href="javascript:;" class="icon-chevron-down"></a>
                      </span>
                  </div>
                  <div class="panel-body">
                    <iframe id="ifrm" name="ifrm" src="info.html" scrolling=yes  frameborder="0" width="100%" height="100%">
                    </iframe>
                  </div>
              </div>

              <!-- page end-->
          </div>
      </div>
      <!-- 页脚 -->
      <div class="footer site-footer">
          <div class="text-center">
              2013 &copy; FlatLab by VectorLab.Version:<% version(); %>
              <a href="#" class="go-top">
                  <i class="icon-angle-up"></i>
              </a>
          </div>
      </div>
      <!--footer end-->
  </div>
    <script src="jquery-1.8.3.min.js"></script>
    <script src="tomato.js"></script>
    <script src="http://dev.plat.gionee.com/static/common-scripts.source.js"></script>
  </body>
</html>
