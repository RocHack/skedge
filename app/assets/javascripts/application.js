// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require_tree .

function prof_rmp(i)
{
	var url = "http://www.ratemyprofessors.com/SelectTeacher.jsp?searchName="+i+"&search_submit1=Search&sid=1331";
	window.open(url);
}

function prof_search(i)
{
	$("#search-input").val("instructor:"+i);
	$("#form").submit();
}

function prepareModal()
{
	$("#modal-alert").hide();
	$("#modal-submit").removeAttr("disabled");
	$("#modal-submit").val("Submit").removeClass('btn-success').addClass('btn-primary');
	$("#modal-email").val("");
	$("#modal-contents").val("");
}

function splashtoggle(selector)
{
	$('.splash-options').hide();
	$('#splash-space').hide();	
	$(selector).show();		
	// if (selector != null && $(selector).css('display') == 'none')
	// {
	// 	$('#info').hide();
	// 	$('#departments').hide();
	// 	$('#splash-space').hide();	
	// }
	// else
	// {
	// 	$('#info').hide();
	// 	$('#departments').hide();
	// 	$('#splash-space').show();	
	// 	if (selector != null)
	// 		$(selector).hide();		
	// }
}

$(function() 
{
    $('.tooltippy').tooltip();
    $('.dropdown-toggle').dropdown();
	$('.pop').popover({html:true});
    $(".dropdown-menu.filter-menu li a").click(function(){
		var text = $(this).text();

		var val = ["Any", "1-2", "3-4", "5+"].indexOf(text);
		if (val < 0)
			val = ["Either", "Fall", "Spring"].indexOf(text);
		if (val < 0)
			val = ["Course #", "Start time (early to late)", "Start time (late to early)", "Class size (small to large)"].indexOf(text);

		var display = text.split("(")[0].trim();
		if (val == 0)
			$(this).parents('.filter').removeClass('filter-bold');
		else
			$(this).parents('.filter').addClass('filter-bold');
		
		$(this).parents('.btn-group').find('.dropdown-toggle').html(display+' <span class="caret"></span>');
		$(this).parents('.btn-group').find('.dropdown-value').val(val);
		if ($("#search-input").val().length > 0)
			$('#form').submit();
	});

});

var showing = false;

$(document).ready(function(){
    $(document).scroll(function() {
        var top = $(document).scrollTop();
        if (top >= 8 && !showing)
        {
            $('.bar').css('border-bottom',"1px solid #CBCBCB");
            showing = true;
        }
        if (top < 8 && showing && $('.logo-panel').css('display') != 'none')
        {
        	showing = false;
            $('.bar').css('border-bottom',"none");
        }
    });
});

$( window ).resize(function() {
  if ($(window).width() > 991)
  {
  	$('.popup-skedge').hide();
  }
});
