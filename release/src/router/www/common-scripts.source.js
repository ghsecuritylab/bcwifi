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
            var contentHeight=$(window).height()-$("header").outerHeight()-$('.footer').outerHeight();
            $("#main-content").css('height',contentHeight);

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