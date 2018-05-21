| import md5 from 'blueimp-md5/js/md5.min.js'
| import parallel from 'async/parallel'


coupon-edit

    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products/coupons') #[i.fa.fa-chevron-left]
            button.btn(if='{ isNew ? checkPermission("products", "0100") : checkPermission("products", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.code || 'Добавление купона' : item.code || 'Редактирование купона' }

        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#coupon-edit-home') Параметры купона]
            li(if='{ item.type == "g" }') #[a(data-toggle='tab', href='#coupon-edit-products') Товары]
            li(if='{ item.type == "g" }') #[a(data-toggle='tab', href='#coupon-edit-categories') Категории товаров]
            li(if='{ item.type == "g" && checkPermission("orders", "1000") }')
                a(data-toggle='tab', href='#coupon-edit-history') История использования


        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #coupon-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-4
                            .form-group(class='{ has-error: error.code }')
                                label.control-label Код
                                .input-group
                                    input.form-control(name='code', value='{ item.code }', readonly='{ !isNew }')
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ generateCode }')
                                            i.fa.fa-random.text-primary
                                .help-block { error.code }
                        .col-md-4
                            .form-group(class='{ has-error: error.type }')
                                label.control-label Тип скидки
                                select.form-control(name='type', value='{ item.type }')
                                    option(value='p') Процент на скидку
                                    option(value='a') Абсолютная скидка на корзину
                                    option(value='g') Процент на позиции товаров
                                .help-block { error.type }
                        .col-md-4
                            .form-group
                                label.control-label До даты
                                datetime-picker.form-control(name='expireDate', value='{ item.expireDate }', format='YYYY-MM-DD')

                    .row
                        .col-md-3
                            .form-group
                                label.control-label Значение
                                div(class='{ "input-group": item.type != "a" }')
                                    input.form-control(name='discount', type='number', value='{ item.discount }')
                                    span.input-group-addon(if='{ item.type != "a" }')
                                        | %
                        .col-md-3
                            .form-group
                                label.control-label Кол-во
                                input.form-control(name='countUsed', type='number', value='{ item.countUsed }', step='1', min='0')


                        .col-md-3
                            .form-group
                                label.control-label Мин. сумма заказа
                                input.form-control(name='minSumOrder', type='number', value='{ item.minSumOrder }', step='0.01', min='0')

                        .col-md-3(if='{ item.type == "a" }')
                            .form-group
                                label.control-label Валюта
                                select.form-control(name='currency', value='{ item.curr }')
                                    option(each='{ c, i in currencies }', value='{ c.name }',
                                    selected='{ c.name == item.curr }', no-reorder) { c.title }

                    .row
                        .col-md-6
                            .form-group
                                label.control-label Пользователь
                                .input-group
                                    .input-group-btn(if='{ item.idUser }')
                                        a.btn.btn-default(href='#persons/{ item.idUser }', target='_blank')
                                            i.fa.fa-eye
                                    input.form-control(value='{ item.idUser ? item.idUser + " - "  + item.userName : "" }', readonly)
                                    .input-group-btn
                                        .btn.btn-default(if='{ checkPermission("contacts", "1000") }', onclick='{ changeUser }')
                                            i.fa.fa-list.text-primary
                                        .btn.btn-default(onclick='{ removeUser }')
                                            i.fa.fa-remove.text-danger
                    .row
                        .col-md-12
                            .form-group
                                .checkbox-inline
                                    label
                                        input(name='onlyRegistered', type='checkbox', checked='{ item.onlyRegistered == "Y" }', data-bool='Y,N')
                                        | Для авторизованных
                                .checkbox-inline
                                    label
                                        input(name='status', type='checkbox', checked='{ item.status == "Y" }', data-bool='Y,N')
                                        | Активен

                #coupon-edit-products.tab-pane.fade(if='{ item.type == "g" }')
                    catalog-static(name='products', rows='{ item.products }', cols='{ productsCols }', add='{ addProducts }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='code') { row.code }
                            datatable-cell(name='article') { row.article }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='price') { row.price }

                #coupon-edit-categories.tab-pane.fade(if='{ item.type == "g" }')
                    catalog-static(name='groups', rows='{ item.groups }', cols='{ groupsCols }', add='{ addGroups }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }

                #coupon-edit-history.tab-pane.fade(if='{ checkPermission("orders", "1000") }')
                    catalog-static(remove-toolbar='true', rows='{ item.orders }', cols='{ ordersCols }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='dateOrder') { row.dateOrder }
                            datatable-cell(name='customer') { row.customer }
                            datatable-cell(name='amount') { row.amount }
                            datatable-cell(name='couponDiscount') { row.couponDiscount }

    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.rules = {
            code: 'empty',
            type: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.productsCols = [
            {name: 'id', value: '#'},
            {name: 'code', value: 'Код'},
            {name: 'article', value: 'Артикул'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
        ]

        self.groupsCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.ordersCols = [
            {name: 'id', value: '#'},
            {name: 'dateOrder', value: 'Дата заказа'},
            {name: 'customer', value: 'Заказчик'},
            {name: 'amount', value: 'Сумма заказа'},
            {name: 'couponDiscount', value: 'Скидка'},
        ]

        self.addProducts = () => {
            modals.create('products-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.item.products = self.item.products || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.item.products.map(item => {
                        return item.id
                    })

                    items.forEach(function (item) {
                        if (ids.indexOf(item.id) === -1) {
                            self.item.products.push(item)
                        }
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.addGroups = () => {
            modals.create('group-select-modal', {
                type: 'modal-primary',
                submit() {
                    self.item.groups = self.item.groups || []

                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                    let ids = self.item.groups.map(item => item.id)

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1)
                            self.item.groups.push(item)
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.submit = () => {
            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Coupon',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Купон сохранен!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`products/coupons/${self.item.id}`)
                        self.update()
                    }
                })
            }
        }

        self.reload = () => observable.trigger('coupons-edit', self.item.id)

        self.generateCode = () => {
            if (self.isNew)
                self.item.code = md5(Math.random().toString(36).substring(7))
            self.error = self.validation.validate(self.item, self.rules, 'code')
        }

        self.changeUser = () => {
            modals.create('persons-list-select-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    self.item.idUser = items[0].id
                    self.item.userName = items[0].displayName
                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeUser = () => {
            self.item.idUser = null
            self.item.userName = null
        }

        observable.on('coupons-new', () => {
            self.error = false
            self.item = {}
            self.isNew = true
            self.update()

            API.request({
                object: 'Currency',
                method: 'Fetch',
                data: {},
                success(response) {
                    self.currencies = response.items
                },
                complete() {
                    self.update()
                }
            })
        })

        observable.on('coupons-edit', id => {
            self.error = false
            self.loader = true
            self.item = {}
            self.isNew = false
            self.update()

            parallel([
                callback => {
                    API.request({
                        object: 'Coupon',
                        method: 'Info',
                        data: {id},
                        success(response) {
                            self.item = response
                            callback(null, 'Coupon')
                        },
                        error() {
                            callback('error', null)
                        }
                    })
                },
                callback => {
                    API.request({
                        object: 'Currency',
                        method: 'Fetch',
                        data: {},
                        success(response) {
                            self.currencies = response.items
                            callback(null, 'Currencies')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }
            ], () => {
                self.loader = false
                self.update()
            })

        })
