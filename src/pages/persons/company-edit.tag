| import 'pages/settings/add-fields/add-fields-edit-block.tag'
| import md5 from 'blueimp-md5/js/md5.min.js'

company-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#persons/companies') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("contacts", "0010") }', onclick='{ submit }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Новая компания' : item.name || 'Редактирование компании' }

        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#company-edit-home') Основная информация]
            li #[a(data-toggle='tab', href='#company-edit-contacts') Контакты]
            li #[a(data-toggle='tab', href='#company-edit-orders') Заказы]
            li(if='{ item.customFields && item.customFields.length }')
                a(data-toggle='tab', href='#company-edit-fields') Доп. информация

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #company-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-6
                            .form-group(class='{ has-error: error.name }')
                                label.control-label Наименование
                                input.form-control(name='name', type='text', value='{ item.name }')
                                .help-block { error.name }
                        .col-md-6
                            .form-group(class='{ has-error: error.fullname }')
                                label.control-label Полное наименование
                                input.form-control(name='fullname', type='text', value='{ item.fullname }')
                                .help-block { error.fullname }
                    .row
                        .col-md-6
                            .form-group(class='{ has-error: error.inn }')
                                label.control-label ИНН
                                input.form-control(name='inn', type='text', value='{ item.inn }')
                                .help-block { error.inn }
                        .col-md-6
                            .form-group(class='{ has-error: error.kpp }')
                                label.control-label КПП
                                input.form-control(name='kpp', type='text', value='{ item.kpp }')
                                .help-block { error.kpp }
                    .row
                        .col-md-6
                            .form-group(class='{ has-error: error.phone }')
                                label.control-label Телефон
                                input.form-control(name='phone', type='text', value='{ item.phone }')
                                .help-block { error.phone }
                        .col-md-6
                            .form-group(class='{ has-error: error.email }')
                                label.control-label E-mail
                                input.form-control(name='email', type='text', value='{ item.email }')
                                .help-block { error.email }
                    .row
                        .col-md-12
                            .form-group(class='{ has-error: error.address }')
                                label.control-label Адрес
                                input.form-control(name='address', type='text', value='{ item.address }')
                                .help-block { error.address }
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Логин
                                input.form-control(name='username', type='text', value='{ item.username }')
                        .col-md-6
                            .form-group
                                label.control-label Пароль
                                input.form-control(name='password', type='password', value='{ item.password }')
                    .row
                        .col-md-12
                            .form-group(class='{ has-error: error.note }')
                                label.control-label Примечание
                                textarea.form-control(rows='5', name='note',
                                style='min-width: 100%; max-width: 100%;', value='{ item.note }')
                                .help-block { error.note }
                #company-edit-contacts.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='contacts', add='{ addModal("persons-list-select-modal") }',
                            cols='{ contactsCols }', rows='{ item.contacts }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='lastName') { [row.lastName, row.firstName, row.secondName].join(' ') }
                #company-edit-orders.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='orders', remove-toolbar='true',
                            cols='{ ordersCols }', rows='{ item.orders }', handlers='{ handlersOrders }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') {row.id}
                                    datatable-cell(name='dateOrder') {row.dateOrder}
                                    datatable-cell(name='amount') {row.amount}
                                    datatable-cell(name='status', class='{ handlers.orderText.colors[row.status] }')
                                        | { handlers.orderText.text[row.status] }
                                    datatable-cell(name='deliveryStatus', class='{ handlers.deliveryText.colors[row.deliveryStatus] }')
                                        | { handlers.deliveryText.text[row.deliveryStatus] }
                                    datatable-cell(name='note') { row.note }
                #company-edit-fields.tab-pane.fade(if='{ item.customFields && item.customFields.length }')
                    add-fields-edit-block(name='customFields', value='{ item.customFields }')

    script(type='text/babel').
        var self = this

        self.loader = false
        self.item = {}

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty',
            email: {
                rules: [{
                    type: 'email'
                }]
            }
        }

        self.contactsCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.ordersCols = [
            { name: 'id' , value: '#' },
            { name: 'dateOrder' , value: 'Дата заказа' },
            { name: 'amount' , value: 'Сумма' },
            { name: 'status' , value: 'Статус заказа' },
            { name: 'deliveryStatus' , value: 'Статус доставки' },
            { name: 'note' , value: 'Примечание' }
        ]

        self.orderText = {
            text: {
                Y: 'Оплачен', N: 'Не оплачен', K: 'Кредит', P: 'Подарок', W: 'В ожидании', C: 'Возврат', T: 'Тест'
            },
            colors: {
                Y: 'bg-success', N: 'bg-danger', K: 'bg-warning', P: null, W: null, C: null, T: null
            }
        }

        self.deliveryText = {
            text: {
                Y: 'Доставлен', N: 'Не доставлен', M: 'В работе', P: 'Отправлен'
            },
            colors: {
                Y: 'bg-success', N: 'bg-danger', M: null, P: null
            }
        }

        self.handlersOrders = {
            orderText: self.orderText,
            deliveryText: self.deliveryText
        }

        self.addModal = function(modal) {
            return function() {
                let _this = this

                modals.create(modal, {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        _this.value = _this.value || []

                        let items = this.tags.catalog.tags.datatable.getSelectedRows()
                        let ids = _this.value.map(item => item.id)

                        items.forEach(item => {
                            if (ids.indexOf(item.id) === -1)
                                _this.value.push(item)
                        })

                        self.update()
                        this.modalHide()
                    }
                })
            }
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.reload = () => {
            observable.trigger('companies-edit', self.item.id)
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (self.item && self.item.password && self.item.password.trim() === '')
                delete self.item.password
            else
                self.item.password = md5(self.item.password)
            if (!self.error) {
                API.request({
                    object: 'Company',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Компания сохранена!', style: 'popup-success'})
                        self.item = response
                        self.item.password = new Array(8).join(' ')
                        self.update()
                        if (self.isNew)
                            riot.route(`/persons/companies/${self.item.id}`)
                        observable.trigger('companies-reload')
                    }
                })
            }
        }

        observable.on('companies-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Company',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    self.item.password = new Array(8).join(' ')
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
            })
        })

        observable.on('companies-new', () => {
            self.error = false
            self.isNew = true
            self.item = {}
            self.update()
        })

        self.on('mount', () => {
            riot.route.exec()
        })