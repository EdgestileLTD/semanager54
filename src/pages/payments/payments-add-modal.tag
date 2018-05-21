| import moment from 'moment'

payments-add-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Новый платёж
        #{'yield'}(to="body")
            form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                .row
                    .col-md-12
                        h4 Информация о заказе
                        .row
                            .col-md-12
                                .form-group
                                    label.control-label Заказ
                                    .input-group
                                        input.form-control(value='{ item.idOrder ? "Заказ № " + item.idOrder + " от " + order.dateOrder + " [" + order.customer + "]" : "" }',
                                            readonly='{ true }')
                                        .input-group-btn
                                            .btn.btn-default(onclick='{ selectOrder }')
                                                i.fa.fa-list.text-primary
                        .row(if='{ item.idOrder }')
                            .col-md-4
                                .form-group
                                    label.control-label Сумма заказа
                                    input.form-control(value='{ order.amount }', readonly='{ true }')
                            .col-md-4
                                .form-group
                                    label.control-label Оплачено
                                    input.form-control(value='{ order.paid }', readonly='{ true }')
                            .col-md-4
                                .form-group
                                    label.control-label Доплата
                                    input.form-control(value='{ order.surcharge % 1 == 0 ? Number(order.surcharge) : order.surcharge }', readonly='{ true }')

                .row
                    .col-md-12
                        h4 Информация о платеже
                        .row
                            .col-md-6
                                .form-group
                                    label.control-label Дата платежа
                                    datetime-picker.form-control(name='date', format='DD.MM.YYYY HH:mm', value='{ item.dateDisplay }')
                            .col-md-6
                                .form-group(class='{ has-error: error.amount }')
                                    label.control-label Сумма оплаты*
                                    input.form-control(name='amount', type='number', min='0', step='1', value='{ item.amount % 1 == 0 ? Number(item.amount) : item.amount }')
                                    .help-block { error.amount }
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
                                .form-group
                                    label.control-label Примечание
                                    textarea.form-control(rows='5', name='note',
                                    style='min-width: 100%; max-width: 100%;', value='{ item.note }')


        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Добавить

    script(type='text/babel').
        var self = this

        function loadPaySystems(modal) {
            var params = {}
            modal.paySystems = []
            API.request({
                object: 'PaySystem',
                method: 'Fetch',
                data: params,
                success: (response, xhr) => {
                    modal.paySystems.push({id: 0, name: "С лицевого счёта"})
                    modal.paySystems = modal.paySystems.concat(response.items)
                    modal.item.paymentTypeNames = modal.paySystems
                    modal.update()
                }
            })
        }


        self.reload = () => {
            //observable.trigger('payments-new')
        }

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = {}
            modal.order = {}
            modal.paySystems = []
            modal.error = false

            modal.item.paymentTarget = (opts.order.inpayee == "Y") ? 1 : 0
            modal.item.idOrder = opts.order.id
            modal.item.idAuthor = opts.order.idAuthor
            modal.item.idCompany = opts.order.idCompany
            modal.item.num = 1
            modal.item.note = '';
            modal.item.date = moment().format('YYYY-MM-DD HH:mm:ss');
            modal.item.dateDisplay = moment().format('DD.MM.YYYY HH:mm');
            modal.item.year = moment().format('YYYY');
            modal.item.paymentType = 1
            modal.item.idManager = app.config.idManager
            modal.item.amount = opts.order.surcharge
            modal.item.curr = opts.order.curr

            modal.order.paid = opts.order.paid
            modal.order.amount = opts.order.amount
            modal.order.surcharge = opts.order.surcharge
            modal.order.dateOrder = opts.order.dateOrder
            modal.order.customer = opts.order.customer

            modal.mixin('validation')
            modal.mixin('permissions')
            modal.mixin('change')

            modal.rules = () => {
                let rules = {
                    amount: ['empty', 'number']
                }
                modal.item.amount = parseFloat(modal.item.amount)
                if (self.item && (self.item.idAuthor || self.item.idCompany))
                    return { ...rules }
                else
                    return { ...rules, idAuthor: 'empty' }
            }


            loadPaySystems(modal)
            //modal.update

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules(), name)}
            }

            modal.checkForSave = () => {
                if (modal.item.amount <= 0) {
                    popups.create({
                        title: 'Сохранение платежа!',
                        text: 'Не указана сумма оплаты!',
                        style: 'popup-danger'
                    })
                    return false
                }

                if (modal.item.paymentType == 0 && modal.item.amount > modal.item.contact.balance) {
                    popups.create({
                        title: 'Сохранение платежа!',
                        text: 'Сумма платежа превышает сумму на лицевом счете плательщика!',
                        style: 'popup-danger'
                    })
                    return false
                }
                return true
            }


            modal.submit = e => {
                var params = modal.item
                if (!modal.checkForSave()) return
                modal.error = modal.validation.validate(modal.item, modal.rules())
                if (!modal.error) {
                    return true
                }
            }

        })



