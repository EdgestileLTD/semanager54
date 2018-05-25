products-list-select-modal
	bs-modal
		#{'yield'}(to="title")
			.h4.modal-title Товары
		#{'yield'}(to="body")
			catalog(object='Product', cols='{ parent.cols }', search='true', reload='true', sortable='true')
				#{'yield'}(to='body')
					datatable-cell(name='id') { row.id }
					datatable-cell(name='code') { row.code }
					datatable-cell(name='article') { row.article }
					datatable-cell(name='name') { row.name }
					datatable-cell(name='price') { row.price }
		#{'yield'}(to='footer')
			button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
			button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

	script(type='text/babel').
		var self = this

		self.cols = [
			{name: 'id', value: '#'},
			{name: 'code', value: 'Код'},
			{name: 'article', value: 'Артикул'},
			{name: 'name', value: 'Наименование'},
			{name: 'price', value: 'Цена'},
		]

