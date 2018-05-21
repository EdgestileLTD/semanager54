| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'pages/orders/orders-list-select-modal.tag'
| import 'pages/persons/persons-list-select-modal.tag'
| import moment from 'moment'

payments-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#payments') #[i.fa.fa-chevron-left]
            button.btn(if='{ isNew ? checkPermission("payments", "0100") : checkPermission("payments", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить')
                i.fa.fa-refresh
        .h4 { isNew ? 'Новый платёж' : ['Редактирование платежа:', "[#" + item.id + "]"].join(" ") }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-4
                    .form-group
                        label.control-label Назначение платежа
                        select.form-control(name='paymentTarget', value='{ item.paymentTarget }')
                            option(value="0") Оплата заказа
                            option(value="1") Пополнение счёта
                .col-md-4
                    .form-group
                        label.control-label Дата платежа
                        datetime-picker.form-control(name='date', format='DD.MM.YYYY HH:mm', value='{ item.dateDisplay }')
                .col-md-4
                    .form-group(class='{ has-error: error.amount }')
                        label.control-label Сумма оплаты*
                        input.form-control(name='amount', type='number', min='0', step='0.01', value='{ parseFloat(item.amount) }')
                        .help-block { error.amount }
            .row(if='{ item.paymentTarget == 0 }')
                .col-md-12
                    h4 Информация о заказе
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Заказ
                                .input-group
                                    input.form-control(value='{ item.idOrder ? "Заказ № " + item.idOrder + " от " + item.order.dateOrder + " [" + item.order.customer + "]" : "" }',
                                        readonly='{ true }')
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ selectOrder }')
                                            i.fa.fa-list.text-primary
                    .row(if='{ item.idOrder }')
                        .col-md-4
                            .form-group
                                label.control-label Сумма заказа
                                input.form-control(value='{ item.order.amount }', readonly='{ true }')
                        .col-md-4
                            .form-group
                                label.control-label Оплачено
                                input.form-control(value='{ item.order.paid }', readonly='{ true }')
                        .col-md-4
                            .form-group
                                label.control-label Доплата
                                input.form-control(value='{ item.order.surcharge }', readonly='{ true }')

            .row
                .col-md-12
                    h4 Информация о платеже
                    .row
                        .col-md-8
                            .form-group
                                label.control-label Тип оплаты
                                select.form-control(name='paymentType', value='{ item.paymentType }')
                                    option(each='{ paySystems }', value='{ id }', selected='{ id == item.paymentType }', no-reorder) { name }
                        .col-md-4(if='{ item.paymentType == 0 }')
                            .form-group
                                label.control-label Сумма на лицевом счёте
                                input.form-control(value='{ item.contact.balance }', readonly='{ true }')
                    .row
                        .col-md-12
                            .form-group(class='{ has-error: (error.idAuthor || error.idCompany) }')
                                label.control-label Плательщик*
                                .input-group
                                    input.form-control(value='{ item.payer }',
                                        readonly='{ true }')
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ selectPayer }')
                                            i.fa.fa-list.text-primary
                                .help-block { (error.idAuthor || error.idCompany) }
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Примечание
                                textarea.form-control(rows='5', name='note',
                                    style='min-width: 100%; max-width: 100%;', value='{ item.note }')

    script(type='text/babel').
        var self = this

        self.isNew = false

        self.item = {}
        self.paySystems = []

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = () => {
            let rules = {
                amount: ['empty', 'number']
            }

            if (self.item && (self.item.idAuthor || self.item.idCompany))
                return { ...rules }
            else
                return { ...rules, idAuthor: 'empty' }
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules(), name)}
        }

        self.checkForSave = () => {
            if (!self.item.idOrder && !self.item.paymentTarget) {
                popups.create({
                    title: 'Сохранение платежа!',
                    text: 'Не выбран заказ!',
                    style: 'popup-danger'
                })
                return false
            }

            if (self.item.amount <= 0) {
                popups.create({
                    title: 'Сохранение платежа!',
                    text: 'Не указана сумма оплаты!',
                    style: 'popup-danger'
                })
                return false
            }

            if (self.item.paymentType == 0 && self.item.amount > self.item.contact.balance) {
                popups.create({
                    title: 'Сохранение платежа!',
                    text: 'Сумма платежа превышает сумму на лицевом счете плательщика!',
                    style: 'popup-danger'
                })
                return false
            }


            return true
        }

        self.submit = e => {
            var params = self.item
            if (!self.checkForSave()) return

            self.error = self.validation.validate(self.item, self.rules())

            if (!self.error) {
                API.request({
                    object: 'Payment',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Платёж сохранен!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`payments/${response.id}`)
                        observable.trigger('payments-reload')
                    }
                })
            }
        }

        self.reload = () => {
            self.item.id ? observable.trigger('payments-edit', self.item.id) : observable.trigger('payments-new')
        }

        function getOrderInfo(id) {
            var params = {id: id}

            API.request({
                object: 'Order',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item.order = response
                    self.item.amount = self.item.order.surcharge
                    self.update()
                }
            })
        }

        function getContactInfo(id) {
            var params = {id: id}

            API.request({
                object: 'Contact',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item.contact = response
                    self.update()
                }
            })
        }

        function getCompanyInfo(id) {
            var params = {id: id}

            API.request({
                object: 'Company',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item.contact = response
                    self.update()
                }
            })
        }

        function loadPaySystems() {
            var params = {}
            self.paySystems = []
            API.request({
                object: 'PaySystem',
                method: 'Fetch',
                data: params,
                success: (response, xhr) => {
                    self.paySystems.push({id: 0, name: "С лицевого счёта"})
                    self.paySystems = self.paySystems.concat(response.items)
                    self.update()
                }
            })
        }

        observable.on('payments-new', () => {
            self.error = false
            self.isNew = true
            self.item = {
                paymentTarget: 0,
                paymentType: 1,
                date: moment().format('DD.MM.YYYY HH:mm'),
                amount: 0
            }
            loadPaySystems()
            self.update()
        })

        observable.on('payments-edit', id => {
            var params = {id: id}
            self.error = false
            self.loader = true
            self.item = {}
            self.isNew = false
            loadPaySystems()
            self.update()

            API.request({
                object: 'Payment',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
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

        self.selectOrder = () => {
            if (!self.isNew) return
            modals.create('orders-list-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    if (items.length) {
                        self.item.idOrder = items[0].id
                        getOrderInfo(self.item.idOrder)

                        if (items[0].idCompany) {
                            self.item.idCompany = items[0].idCompany
                            self.item.idAuthor = null
                            getCompanyInfo(self.item.idCompany)
                        } else {
                            self.item.idAuthor = items[0].idAuthor
                            self.item.idCompany = null
                            getContactInfo(self.item.idAuthor)
                        }

                        self.item.payer = items[0].customer

                        self.update()
                    }
                    this.modalHide()
                }
            })
        }

        self.selectPayer = () => {
            modals.create('persons-company-list-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let _this = this.tags['bs-modal']
                    let items = _this.tags[_this.tab].tags.datatable.getSelectedRows()
                    if (!items.length) return

                    if (_this.tab == 'contacts') {
                        self.item.idAuthor = items[0].id
                        self.item.payer = items[0].displayName
                        self.item.idCompany = null
                        getContactInfo(self.item.idAuthor)
                    } else {
                        self.item.idCompany = items[0].id
                        self.item.payer = items[0].name
                        self.item.idAuthor = null
                        getCompanyInfo(self.item.idCompany)
                    }

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.on('update', () => {
            localStorage.setItem('SE_section', 'shoppayment')
        })

        self.on('mount', () => {
            riot.route.exec()
        })