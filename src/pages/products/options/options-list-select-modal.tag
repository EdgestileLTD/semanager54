options-list-select-modal
	bs-modal
		#{'yield'}(to="title")
			.h4.modal-title Опции
		#{'yield'}(to="body")
			.row
				.col-md-4.left-block
					catalog-tree(object='OptionGroup', label-field='{ "name" }', children-field='{ "childs" }',
					descendants='true')
				.col-md-8.cont-block
					catalog(object='Option', cols='{ parent.cols }', search='true', add='{ parent.add }', remove='true',
					handlers='{ parent.handlers }', reload='true', filters='{ categoryFilters }', disable-limit='true',
					disable-col-select='true', dblclick='{ parent.opts.submit.bind(this) }')
						#{'yield'}(to='body')
							datatable-cell(name='id') { row.id }
							datatable-cell(name='name') { row.name }

		#{'yield'}(to='footer')
			button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
			button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

	style.
		.left-block {
			margin-top: 45px;
			overflow: auto;
			max-height: 500px;
		}
		.cont-block {
			margin-top: 5px;
		}

	script(type='text/babel').
		var self = this

		var getFeaturesTypes = () => {
			API.request({
				object: 'Option',
				method: 'Fetch',
				data: {},
				success(response) {
					self.featuresTypes = response.items
					self.update()
				}
			})
		}

		var featureName = type => {
			for (var i = 0; i < self.featuresTypes.length; i++) {
				if (self.featuresTypes[i].code === type)
					return self.featuresTypes[i].name
			}
		}

		self.add = () => {
			modals.create('option-new-modal', {
				type: 'modal-primary',
				submit() {
					var _this = this
					var params = {name: _this.name.value}

					API.request({
						object: 'Option',
						method: 'Save',
						data: params,
						success(response) {
							_this.modalHide()
							if (response.id)
								riot.route(`products/parameters/${response.id}`)
						}
					})
				}
			})
		}

		self.cols = [
			{name: 'id', value: '#'},
			{name: 'name', value: 'Наименование'},
		]

		self.handlers = {
			featureName: featureName
		}
		getFeaturesTypes()
		self.on('mount', () => {
			let modal = self.tags['bs-modal']
			modal.categoryFilters = false
			modal.one('updated', () => {
				modal.tags['catalog-tree'].tags.treeview.on('nodeselect', node => {
					modal.selectedCategory = node.__selected__ ? node.id : undefined
					let items = modal.tags['catalog-tree'].tags.treeview.getSelectedNodes()
					if (items.length > 0) {
						let value = items.map(i => i.id).join(',')
						modal.categoryFilters = [{field: 'idFeatureGroup', sign: 'IN', value}]
					} else {
						modal.categoryFilters = false
					}
					modal.update()
					modal.tags.catalog.reload()
				})
			})
		})
