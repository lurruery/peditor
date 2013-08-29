class widgets.Title extends Peditor.Widget
	constructor: ->
		# Required interface.
		# Triggered when this widget class is loaded.

		@$prop_text = @$properties.find('.text')
		@$prop_size = @$properties.find('.size')
		@$prop_align = @$properties.find('.align')

		# Add event listeners.
		@$prop_text.change(@text_changed)
		@$prop_size.change(@size_changed)
		@$prop_align.change(@align_clicked)

	added: ($widget) ->
		# Required interface.
		# Triggered when a new widget is add to a container.
		# A widget specified initialization should be implemented here.
		# Such as js based animation for a widget.

		$icon = $widget.find('i')
		op = 0.8
		v = 0.01
		animate = ->
			$icon.css('opacity', op)

			if op >= 1 or op <= 0.5
				v *= -1
			op += v

			requestAnimationFrame(animate)

		requestAnimationFrame(animate)

	selected: ($widget) ->
		# Required interface.
		# Triggered when a widget is selected.

		$text = $widget.find('.text')
		$span = $widget.find('.text span')

		@$prop_text.val($span.text())
		@$prop_size.val($text.attr('class').match(/(h\d)/)[1])

		align = $text.css('text-align')
		if align == 'start'
			@$prop_align.find('.btn:first').click()
		else
			@$prop_align.find("[value='#{align}']").parent().click()

	text_changed: =>
		$span = @$get_selected().find('.text span')

		$span.text(@$prop_text.val())

		# Record the history for the 'undo & redo' operation.
		# It's the widget's responsibility to notify the Peditor
		# that the pdoc has changed.
		@rec('Title text changed')

	size_changed: =>
		$text = @$get_selected().find('.text')

		$text.removeClass().addClass('text ' + @$prop_size.val())

		@rec('Title size changed')

	align_clicked: =>
		$text = @$get_selected().find('.text')

		$text.css({
			'text-align': @$prop_align.find(':checked').val()
		})

		@rec('Title align changed')
