brands-list-select-modal
	bs-modal
		#{'yield'}(to="title")
			.h4.modal-title Бренды
		#{'yield'}(to="body")
			catalog(object='Brand', cols='{ parent.cols }', search='true',
			dblclick='{ parent.opts.submit.bind(this) }', reload='true')
				#{'yield'}(to='body')
					datatable-cell(name='id') { row.id }
					datatable-cell(name='name') { row.name }
					//datatable-cell(name='code') { row.code }
		#{'yield'}(to='footer')
			button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
			button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

	script(type='text/babel').
		var self = this

		self.cols = [
			{name: 'id', value: '#'},
			{name: 'name', value: 'Наименование' }
		]
