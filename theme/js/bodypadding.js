$(document).ready(function(){
    if( (window.location.pathname.indexOf("/index") >= 0)
     || (window.location.pathname == '/') ) {
       $('body').css('padding-top', $('.navbar').height()+'px');
    }
});
