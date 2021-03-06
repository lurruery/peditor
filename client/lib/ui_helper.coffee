###

UI helper

###

Modernizr.addTest("boxsizing", ->
	return Modernizr.testAllProps("boxSizing") and
	(document.documentMode == undefined or document.documentMode > 7)
)

Modernizr.addTest('css_calc', ->
	prop = 'width:'
	value = 'calc(10px);'
	el = document.createElement('div')

	el.style.cssText = prop + Modernizr._prefixes.join(value + prop)

	return !!el.style.length
)

$.fn.dragging = (options) ->
	# options: object
	# 	$target: jQuery
	# 	data: any
	# 	mouse_down:  (e, data) ->
	# 	mouse_move:  (e, data) ->
	# 	mouse_up:  (e, data) ->

	mouse_down = (e) ->
		e.$target = options.$target
		e.data = options.data
		options.mouse_down(e)

		$(window).mousemove(mouse_move)
		$(window).one('mouseup', mouse_up)

	mouse_move = (e) ->
		e.$target = options.$target
		e.data = options.data
		options.mouse_move(e)

	mouse_up = (e)->
		e.$target = options.$target
		e.data = options.data
		options.mouse_up(e)

		# Release event resource.
		$(window).off('mousemove', mouse_move)

	options.$target.mousedown(mouse_down)

$.fn.msg_box = (options) ->
	# options: object
	#	title: html
	#	body: html
	#	closed: function

	html = _.template('
		<div class="modal fade">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header font-l font-26">
						<%= title %>
					</div>
					<div class="modal-body font-n font-16">
						<%= body %>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">OK</button>
					</div>
				</div>
			</div>
		</div>',
		options
	)

	$modal = $(html)

	$modal.on('hide.bs.modal', options.closed)

	$modal.on('hidden.bs.modal', ->
		$modal.remove()
	)

	$modal.modal('show')

$.fn.scroll_to = (options) ->
	# options: object
	# 	parent: jQuery
	# 	to: jQuery

	parent = options.parent
	to = options.to

	distance = to.offset().top - parent.offset().top + parent.scrollTop()

	parent.stop(true, true).animate({
		scrollTop: distance
	}, 'fast');

$.fn.push_state = (options) ->
	options.obj ?= null
	options.title ?= null

	history.pushState(
		options.obj,
		options.title,
		options.url,
	)

$.fn.load_js = (elem, selector, done) ->
	js = document.createElement("script")
	js.type = "text/javascript"
	if elem.src
		js.src = elem.src
		js.onload = ->
			done($(js))
		js.onerror = ->
			done($(js))
	else
		try
			js.appendChild(
				document.createTextNode(elem.text)
			)
		catch e
			js.text = elem.text
		done($(js))

	$(selector)[0].appendChild(js)

$.fn.load_css = (elem, selector) ->
	if elem.href
		css = document.createElement("link")
		css.setAttribute("rel", "stylesheet")
		css.setAttribute("type", "text/css")
		css.type = "text/css"
		css.href = elem.href
	else
		css = document.createElement("style")
		if css.styleSheet
			css.styleSheet.cssText = elem.styleSheet.cssText
		else
			css.appendChild(
				document.createTextNode(
					$(elem).text()
				)
			)

	$(selector)[0].appendChild(css)
