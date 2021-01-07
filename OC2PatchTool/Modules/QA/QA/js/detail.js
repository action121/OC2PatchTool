hljs.initHighlightingOnLoad();

;(function(){
    // 添加侧边导航
    var $header = $('.article :header'),
        $nav = $('<div class="sidenav" id="nav"><div class="catelog"><ul></ul></div><a href="javascript:;" class="nav_switch nav_switch_active" id="nav_switch"></a></div>'),
        $ul = $nav.find("ul"),
        ceng = 0,
        offset = [];

    var getOffset = function(){
        for(var i=0; i<$header.length; i++){
            offset[i] = parseInt($header.eq(i).offset().top);
        }
    }

    for(var i=0; i<$header.length; i++){
        var $this = $header.eq(i),
            $prev = i>0 ? $($header[i-1]) : $($header[i]),
            html = '';

        if($this.prop("tagName") > $prev.prop("tagName")){
            ceng++;
        }else if($this.prop("tagName") < $prev.prop("tagName")){
            ceng--;
        }
        if(ceng!==0){
            html = '<li class="ceng_'+ceng+'"><a href="javascript:;">'+ $this.text() +'</a></li>';
        }else{
            html = '<li class="ceng_'+ceng+'"><a href="javascript:;">'+ $this.text() +'<span class="dot"></span></a></li>';
        }

        $ul.append(html);
    }

    $('#post_side').append($nav);

    getOffset();
    setTimeout(function(){
        getOffset();
    }, 2000);
    $('#nav .catelog').on('click', 'a', function(event){
        // if(document.readyState!=="complete"){
            getOffset();
        // }
        var index = $(this).parent().index();
        $(window).scrollTop( offset[index] );

        event.preventDefault();
    })

    // 显示或隐藏导航
    $('#nav_switch').click(function(){
        // var display = $('.catelog').css('display');
        // if(display == 'block'){
        //     $('.catelog').stop().fadeOut();
        //     $(this).removeClass('nav_switch_active');
        // }else{
        //     $('.catelog').stop().fadeIn();
        //     $(this).addClass('nav_switch_active');
        // }
    });

    $(window).scroll(function(){
        var winTop = $(this).scrollTop();
        var width = $(this).width();

//        if(width>=1100){
//            // winTop > 100 ? $('#nav').fadeIn() : $('#nav').fadeOut();
//
//            for(var i=0; i<offset.length-1; i++){
//                if(winTop>=offset[i] && winTop<offset[i+1]){
//                    $ul.find('a').removeClass('active').eq(i).addClass('active');
//                    break;
//                }
//            }
//        }else{
//            // $('#nav').fadeOut();
//        }
    })
})();
