| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import './pay-system-params-edit-modal.tag'

pay-system-edit
	loader(if='{ loader }')
	virtual(hide='{ loader }')
		.btn-group
			a.btn.btn-default(href='#settings/pay-systems') #[i.fa.fa-chevron-left]
			button.btn(if='{ checkPermission("paysystems", "0010") }', onclick='{ submit }',
			class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
				i.fa.fa-floppy-o
				|  Сохранить
			button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
				i.fa.fa-refresh
		.h4 { isNew ? item.namePayment || 'Добавление платежной системы' : item.namePayment || 'Редактирование платежной системы' }

		form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
			.form-group(class='{ has-error: error.namePayment }')
				label.control-label Наименование
				input.form-control(name='namePayment', type='text', value='{ item.namePayment }')
				.help-block { error.namePayment }
			ul.nav.nav-tabs.m-b-2
				li.active #[a(data-toggle='tab', href='#pay-system-edit-settings') Настройки]
				li #[a(data-toggle='tab', href='#pay-system-edit-main-info') Страница пояснений]
				li(if='{ item.identifier == null }') #[a(data-toggle='tab', href='#pay-system-edit-blank') Бланк счета]
				li(if='{ item.identifier == null }') #[a(data-toggle='tab', href='#pay-system-edit-result') Результат]
				li(if='{ item.identifier == null }') #[a(data-toggle='tab', href='#pay-system-edit-success') Успех]
				li(if='{ item.identifier == null }') #[a(data-toggle='tab', href='#pay-system-edit-fail') Неудача]
				li #[a(data-toggle='tab', href='#pay-system-edit-hosts') Хосты]
				//li #[a(data-toggle='tab', href='#pay-system-edit-filters') Фильтры]

			.tab-content
				#pay-system-edit-settings.tab-pane.fade.in.active
					.row
						.col-md-2
							.form-group
								.well.well-sm
									image-select(name='imageFile', section='shoppayment', alt='0', size='64', value='{ item.imageFile }')

						.col-md-10
							.row(if='{ isNew }')
								.col-md-12
									.form-group
										label.control-label Плагин
										.input-group
											select.form-control(name='identifier', value='{ item.identifier }')
												option(each='{ plugin in item.plugins }', value='{ plugin.id }')
													| { plugin.name }
											.input-group-btn
												.btn.btn-default(onclick='{ submit }')
													| Получить параметры
							.row
								.col-md-12
									.form-group
										label.control-label Тип контакта
										.input-group
											select.form-control(name='customerType', value='{ item.customerType }')
												option(value='') Для всех
												option(value='1') Для физических лиц
												option(value='2') Для юридических лиц (компаний)
							.row
								.col-md-12
									.form-group
										label.control-label Справка URL
										input.form-control(name='urlHelp', type='text', value='{ item.urlHelp }')

							.row
								.col-md-12
									.form-group
										.checkbox-inline
											label
												input(type='checkbox', name='isExtBlank', checked='{ item.isExtBlank }')
												| Внешний бланк
										.checkbox-inline
											label
												input(type='checkbox', name='isAuthorize', checked='{ item.isAuthorize }')
												| Авторизация
										.checkbox-inline
											label
												input(type='checkbox', name='isActive', checked='{ item.isActive }')
												| Показывать
										.checkbox-inline
											label
												input(type='checkbox', name='isAdvance', checked='{ item.isAdvance }')
												| Предоплата
										.checkbox-inline
											label
												input(type='checkbox', name='isTestMode', checked='{ item.isTestMode }')
												| Тестовый режим
										.checkbox-inline
											label
												input(type='checkbox', name='isTicket', checked='{ item.isTicket }')
												| Выписывать чек

					.row(if='{ !isNew }')
						.col-md-12
							h4 Параметры

					catalog-static(if='{ !isNew }', name='params', cols='{ paramsCols }', rows='{ item.params }',
					dblclick='{ editParam }', add='{ !item.ident ? addParams : false }')
						#{'yield'}(to='body')
							datatable-cell(name='code') { row.code }
							datatable-cell(name='name') { row.name }
							datatable-cell(name='value') { row.tvalue }


				#pay-system-edit-main-info.tab-pane.fade
					.row
						.col-md-12
							.form-group
								ckeditor(name='pageMainInfo', value='{ item.pageMainInfo }')

				#pay-system-edit-blank.tab-pane.fade(if='{ item.identifier == null }')
					.row
						.col-md-12
							.form-group
								ckeditor(name='pageBlank', value='{ item.pageBlank }')

				#pay-system-edit-result.tab-pane.fade(if='{ item.identifier == null }')
					.row
						.col-md-12
							.form-group
								ckeditor(name='pageResult', value='{ item.pageResult }')

				#pay-system-edit-success.tab-pane.fade(if='{ item.identifier == null }')
					.row
						.col-md-12
							.form-group
								ckeditor(name='pageSuccess', value='{ item.pageSuccess }')

				#pay-system-edit-fail.tab-pane.fade(if='{ item.identifier == null }')
					.row
						.col-md-12
							.form-group
								ckeditor(name='pageFail', value='{ item.pageFail }')

				#pay-system-edit-hosts.tab-pane.fade
					catalog-static(name='hosts', rows='{ item.hosts }', add='{ addHosts }',
					cols='{ [{name: "name", value: "Наименование"}] }')
						#{'yield'}(to='body')
							datatable-cell(name='name') { row.name }

				#pay-system-edit-filters.tab-pane.fade
					catalog-static(name='filters', rows='{ item.filters }', add='{ addFilters }', cols='{ filtersCols }')
						#{'yield'}(to='body')
							datatable-cell(name='id') { row.id }
							datatable-cell(name='code') { row.code }
							datatable-cell(name='article') { row.article }
							datatable-cell(name='name') { row.name }
							datatable-cell(name='price') { row.price }

	script(type='text/babel').
		var self = this

		self.isNew = false
		self.paramsSelectedCount = 0

		self.mixin('permissions')
		self.mixin('validation')
		self.mixin('change')
		self.item = {}

		self.rules = {
			namePayment: 'empty'
		}

		self.value = []

		self.afterChange = e => {
			if (e.target && e.target.name) {
				let name = e.target.name
				let value = e.target.value
				if (name === 'identifier') {
					let item = self.item.plugins.filter(item => item.name === value)
					if (item.length) {
						self.item.namePayment = item[0].name
					}
				}
			}

			let name = e.target.name
			delete self.error[name]
			self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
		}

		self.paramsCols = [
			{name: 'code', value: 'Код'},
			{name: 'name', value: 'Заголовок'},
			{name: 'value', value: 'Значение'},
		]

		self.filtersCols = [
			{name: 'id', value: '#'},
			{name: 'code', value: 'Код'},
			{name: 'article', value: 'Артикул'},
			{name: 'name', value: 'Наименование'},
			{name: 'price', value: 'Цена'},
		]

		self.reload = () => {
			observable.trigger('pay-systems-edit', self.item.id)
		}

		self.submit = e => {
			var params = self.item
			self.error = self.validation.validate(params, self.rules)

			if (!self.error) {
				API.request({
					object: 'PaySystem',
					method: 'Save',
					data: params,
					success(response) {
						self.item = response
						popups.create({title: 'Успех!', text: 'Платежная система сохранена!', style: 'popup-success'})
						if (self.isNew)
							riot.route(`settings/pay-systems/${response.id}`)
						observable.trigger('pay-systems-reload')
					}
				})
			}
		}

		self.addHosts = () => {
			modals.create('bs-prompt', {
				type: 'modal-primary',
				title: 'Хост',
				label: 'Наименование сайта (без http://)',
				submit() {
					if (!(self.item.hosts instanceof Array))
						self.item.hosts = []

					self.item.hosts.push({name: this.name.value})
					self.update()
					this.modalHide()
				}
			})
		}

		self.addFilters = () => {
			modals.create('products-list-select-modal', {
				type: 'modal-primary',
				size: 'modal-lg',
				submit() {
					self.item.filters = self.item.filters || []

					let items = this.tags.catalog.tags.datatable.getSelectedRows()

					let ids = self.item.filters.map(item => {
						return item.id
					})

					items.forEach(item => {
						if (ids.indexOf(item.id) === -1)
							self.item.filters.push(item)
					})

					self.update()
					this.modalHide()
				}
			})
		}

		self.addParams = () => {
			modals.create('pay-system-params-edit-modal', {
				type: 'modal-primary',
				isNew: true,
				submit() {
					var _this = this

					_this.error = _this.validation.validate(_this.item, _this.rules)

					if (!_this.error) {
						API.request({
							object: 'BankAccount',
							method: 'Save',
							data: _this.item,
							success(response) {
								_this.item.id = response.id
								self.item.params.push(_this.item)
								self.update()
								_this.modalHide()
							}
						})
					}
				}
			})
		}

		self.editParam = e => {
			var oldParam = {}

			for (var key in e.item.row)
				oldParam[key] = e.item.row[key]

			modals.create('pay-system-params-edit-modal', {
				type: 'modal-primary',
				item: e.item.row,
				title: 'Редактирование параметра',
				submit() {
					var _this = this

					_this.error = _this.validation.validate(_this.item, _this.rules)

					if (!_this.error) {
						self.update()
						observable.trigger('pay-systems-reload')
						_this.modalHide()
						/*

						API.request({
							object: 'BankAccount',
							method: 'Save',
							data: _this.item,
							success(response) {

							}
						})
						*/
					}

				}

			})
		}
		self.removeParams = () => {
			self.paramsSelectedCount = 0
			self.item.params = self.tags.params.getUnselectedRows()
			self.update()
		}

		observable.on('pay-systems-edit', id => {
			self.error = false
			self.loader = true
			self.isNew = false
			self.item = {}
			self.update()

			API.request({
				object: 'PaySystem',
				method: 'Info',
				data: {id},
				success(response) {
					self.item = response
					observable.trigger('pay-systems-reload')
				},

				error(response) {
					self.item = {}
				},
				complete() {
					self.loader = false
					self.update()
				}
			})

		})

		observable.on('pay-systems-reload', item => {
			for (var i in self.item.params){
				var element = self.item.params[i]
				var t = String(element.code)
				if((t.search(/(CODE|SECRET|KEY|PASS|CERT)/ig) + 1) && (t.length  !== 0)){
					self.item.params[i].tvalue = '**********'
				} else {
					self.item.params[i].tvalue = element.value
				}
			}
			self.update({loader: false})
		})

		observable.on('pay-systems-new', () => {
			self.error = false
			self.loader = true
			self.isNew = true
			self.item = {}
			self.update()

			API.request({
				object: 'PaySystem',
				method: 'Info',
				success(response) {
					self.item = response
					observable.trigger('pay-systems-reload')
				},
				error(response) {
					self.item = {}
					self.item.plugins = []
				},
				complete() {
					self.loader = false
					self.update()
				}
			})
		})

		self.on('mount', () => {
			riot.route.exec()
		})