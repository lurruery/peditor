###

The Peditor client application.

Aug 2013, ys

###


class PDT.Peditor

	# ********** Public **********

	constructor: ->
		@config = {}

		@init_ui_components()

		@init_key_control()

		@init_history()

	rec: (title = '') =>
		# The last two history are the same,
		# return directly.
		if @history.length == 1 and
		@history[0].pdoc == PDT.workbench.get_doc()
			return
		else if @history.length > 1 and
		_.last(@history).pdoc == _.first(_.last(@history, 2)).pdoc
			return

		if @history_index < @history.length - 1
			@history = _.first(@history, @history_index + 1)
			@history_index = @history.length - 1

		if @history.length == @config.max_history
			@history = _.rest(@history)
		else
			@history_index++

		@history.push({
			title: title
			pdoc: PDT.workbench.get_doc()
		})

		@update_history_btns()

	# ********** Private **********

	init_ui_components: ->
		# Init all bootstrap tooltips.
		$('[title]').tooltip({
			placement: "auto"
		})

		$('#navbar .view_mode input').change(@view_mode_changed)

	init_history: ->
		# The edit history stack.
		@history = []
		@history_index = -1
		@config.max_history = 30

		@rec('origin')

	btn_save_clicked: =>
		pdoc = {
			mime: 'text/pdoc+json'
			doc: PDT.workbench.get_doc()
			scripts: PDT.workbench.get_scripts()
		}

		$.ajax({
			type: "POST"
			url: '/save'
			data: pdoc
			dataType: "json"
		}).done((data) ->
			if data.ok
				$.fn.push_state({
					obj: 'pdoc'
					url: '/pdoc/' + data.id
				})
		)

	btn_undo_clicked: =>
		if $('#navbar .undo').attr('disabled')
			return

		@history_index--

		PDT.workpanel.edit_deactive()

		$('#workbench').empty().append(
			@history[@history_index].pdoc
		)
		PDT.workbench.init_containers()

		@update_history_btns()

	btn_redo_clicked: =>
		if $('#navbar .redo').attr('disabled')
			return

		@history_index++

		PDT.workpanel.edit_deactive()

		$('#workbench').empty().append(
			@history[@history_index].pdoc
		)
		PDT.workbench.init_containers()

		@update_history_btns()

	btn_help_clicked: =>
		$.fn.msg_box({
			title: 'Help'
			body: $('#help').html()
		})

	btn_about_clicked: =>
		$.fn.msg_box({
			title: 'About'
			body: $('#about').html()
		})

	view_mode_changed: ->
		mode = $(this).val()
		$workbench = $('#workbench')
		$workpanel = $('#workpanel')
		switch mode
			when 'outline'
				$workbench.removeClass('preview').addClass('outline')
				$workpanel.removeClass('preview').addClass('outline')

			when 'preview'
				$workbench.removeClass('outline').addClass('preview')
				$workpanel.removeClass('outline').addClass('preview')

	update_history_btns: ->
		undo = false
		redo = false

		if @history.length == 1
			undo = redo = false
			return

		if @history_index == @history.length - 1
			undo = true
		else if @history_index < @history.length - 1 and @history_index > 0
			undo = redo = true
		else
			redo = true

		if undo
			$('#navbar .undo').removeAttr('disabled')
		else
			$('#navbar .undo').attr('disabled', true)

		if redo
			$('#navbar .redo').removeAttr('disabled')
		else
			$('#navbar .redo').attr('disabled', true)

	init_key_control: ->
		# Save
		Mousetrap.bind(
			'S'
			@btn_save_clicked
		)
		# Undo
		Mousetrap.bind(
			'Z'
			@btn_undo_clicked
		)
		# Redo
		Mousetrap.bind(
			'Y'
			@btn_redo_clicked
		)
		# Remove current
		Mousetrap.bind('R', ->
			if PDT.workbench.$selected_con
				PDT.workbench.$selected_con.remove()
				PDT.peditor.rec('del_container')

		)
		# Edit Deactive
		Mousetrap.bind('D', ->
			if PDT.workbench.$selected_con
				PDT.workpanel.edit_deactive()
		)

		# Column size increase.
		Mousetrap.bind('+', ->
			PDT.workbench.column_increase()
		)
		# Column size decrease.
		Mousetrap.bind('_', ->
			PDT.workbench.column_increase(-1)
		)

PDT.peditor = new PDT.Peditor
