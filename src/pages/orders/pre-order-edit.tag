| import 'pages/products/products/products-list-select-modal.tag'

pre-order-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#orders/pre-orders') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("orders", "0100") : checkPermission("orders", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? 'Новый предзаказ' : 'Редактирование предзаказа № ' + item.id + ' от ' + item.date }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-4
                    label.control-label Заказчик
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { (error.name) }
                .col-md-4
                    label.control-label Телефон
                    input.form-control(name='phone', type='text', value='{ item.phone }')
                .col-md-4
                    label.control-label Email
                    input.form-control(name='email', type='text', value='{ item.email }')
            .row
                .col-md-8
                    label.control-label Товар
                    .input-group
                        .input-group-btn(if='{ item.idPrice }')
                            a.btn.btn-default(target='_blank', href='{  "#products/" + item.idPrice }')
                                i.fa.fa-eye
                        input.form-control(name='idPrice',
                        value='{ item.product }', readonly)
                        .input-group-btn
                            .btn.btn-default(onclick='{ changeProduct }')
                                i.fa.fa-list
                .col-md-4
                    label.control-label Количество
                    input.form-control(name='count', type='number', min='0', step='1', value='{ item.count }')


    script(type='text/babel').
        var self = this

        self.isNew = false
        self.item = {}
        self.loader = false

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        observable.on('pre-order-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'PreOrder',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    console.log(self.item)
                    self.loader = false
                    self.update()
                }
           })
        })

        observable.on('pre-order-new', () => {
            self.error = false
            self.isNew = true
            self.update()
        })

        self.submit = e => {
            var params = self.item
            params.send = self.snd

            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'PreOrder',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        self.isNew = false
                        self.update()
                        if (self.isNew)
                          riot.route(`/orders/pre-orders/${self.item.id}`)
                        popups.create({title: 'Успех!', text: 'Предзаказ сохранен!', style: 'popup-success'})
                        observable.trigger('orders-reload')
                    }
                })
            }
        }

        self.changeProduct = () => {
            modals.create('products-list-select-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idPrice = items[0].id
                        self.item.product = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }


        self.reload = e => {
            observable.trigger('pre-order-edit', self.item.id)
        }

        self.on('mount', () => {
            riot.route.exec()
        })
