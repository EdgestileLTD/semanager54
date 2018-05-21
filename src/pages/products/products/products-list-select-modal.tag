products-list-select-modal
	bs-modal
		#{'yield'}(to="title")
			.h4.modal-title Товары
		#{'yield'}(to="body")
			catalog(object='Product', cols='{ parent.cols }', search='true', reload='true', sortable='true',
				dblclick='{ parent.opts.submit.bind(this) }', systemfilters='{ parent.opts.systemFilters }',
				disable-limit='1', disable-col-select='1')
				#{'yield'}(to='body')
					datatable-cell(name='id') { row.id }
					datatable-cell(name='article') { row.article }
					datatable-cell(name='name') { row.name }
					datatable-cell.text-right(name='price')
						| {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
						span  { (row.price / 1).toFixed(2) }
						|  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }

		#{'yield'}(to='footer')
			button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
			button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

	script(type='text/babel').
		var self = this

		self.cols = [
			{name: 'id', value: '#'},
			{name: 'article', value: 'Артикул'},
			{name: 'name', value: 'Наименование'},
			{name: 'price', value: 'Цена'},
		]