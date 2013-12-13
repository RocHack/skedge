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

function prof_email(i)
{
	console.log(i);
}

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