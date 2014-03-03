/*---LEFT BAR ACCORDION----*/
$(function() {
    $('#nav-accordion').dcAccordion({
        eventType: 'click',
        autoClose: true,
        saveState: true,
        disableLink: true,
        speed: 'slow',
        showCount: false,
        autoExpand: true,
//        cookie: 'dcjq-accordion-1',
        classExpand: 'dcjq-current-parent'
    });
});

var Script = function () {

//    sidebar dropdown menu auto scrolling

    jQuery('#sidebar .sub-menu > a').on('click', function () {
        var o = ($(this).offset());
        diff = 250 - o.top;
        if(diff>0)
            $("#sidebar").scrollTo("-="+Math.abs(diff),500);
        else
            $("#sidebar").scrollTo("+="+Math.abs(diff),500);
    });

//    sidebar toggle

    $(function() {
        function responsiveView() {
            $("#main-content .wrapper").css('min-height',$(window).height()-$("header").height());
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
// widget tools

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
        var ifm= document.getElementById("ifrm"); 
        var subWeb = document.frames ? document.frames["ifrm"].document : ifm.contentDocument; 
        if(ifm != null && subWeb != null) { 
        ifm.height = subWeb.body.scrollHeight; 
        } 
    } 
}();