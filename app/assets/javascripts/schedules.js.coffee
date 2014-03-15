# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.render_img = (rid,goto) ->
	a = $('.screenshot').clone().appendTo('body')
	a.width(1000)
	a.find('.s-block-time, .s-block-title').show().css('display','block')
	a.find('.s-block-dept, .s-block-cnum, .s-block-type').css('display','inline')
	a.find('.s-block-p').css('line-height','1.1em').css('text-align','left').css('margin','8px 8px 2px 8px').css('display','block').css('color','white')
	a.find('.s-block-title').css('margin-top','3px').show()
	a.find('.wrapper').css('color','white')
	a.find('.s-big').css('display','block')
	a.find('.s-block').css('opacity','0.85')
	html2canvas(a, {
		onrendered: ( (canvas) ->
			strDataURI = canvas.toDataURL("image/jpeg")
			$.post("schedule/set_image.json", {"img":strDataURI, "rid":rid}, (data) ->
				console.log("got this data #{data.url}")
				if (goto)
					window.location=data.url
			)
			a.remove()
		)
	})