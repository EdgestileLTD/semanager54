| import 'components/autocomplete.tag'
| import 'components/datetime-picker.tag'
| import 'pages/delivery/delivery-list-modal.tag'
| import 'pages/persons/persons-company-list-modal.tag'
| import 'pages/products/modifications/modifications-list-modal.tag'
| import 'pages/payments/payments-list-modal.tag'
| import 'pages/payments/payments-add-modal.tag'
| import 'pages/orders/order-add-service-modal.tag'
| import 'components/loader.tag'
| import 'components/catalog.tag'

order-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#orders') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("orders", "0100") : checkPermission("orders", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reloadButton }', title='Обновить', type='button')
                i.fa.fa-refresh
            button.btn.btn-default(onclick='{ send }', title='Отсылать письмо', type='button')
                i(class='fa fa-paper-plane { text-noactive: !snd }')
        .h4 { isNew ? 'Новый заказ' : 'Редактирование заказа № ' + item.id }

        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#order-edit-home') Основная информация]
            li #[a(data-toggle='tab', href='#order-edit-delivery') Доставка]
            li(if='{ !isNew }') #[a(data-toggle='tab', href='#order-edit-pay') Платежи заказа]
            li(if='{ item.customFields && item.customFields.length }')
                a(data-toggle='tab', href='#order-edit-fields') Доп. информация

        .tab-content
            #order-edit-home.tab-pane.fade.in.active
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-1(if='{ !isNew }')
                            .form-group
                                label.control-label Ид
                                input.form-control(name='id', value='{ item.id }', readonly)
                        .col-md-2(if='{ !isNew }')
                            .form-group
                                label.control-label Дата заказа
                                datetime-picker.form-control(name='dateOrder',
                                format='DD.MM.YYYY', value='{ item.dateOrder }', icon='glyphicon glyphicon-calendar')
                        .col-md-3
                            .form-group(class='{ has-error: (error.idAuthor || error.idCompany) }')
                                label.control-label Заказчик
                                .input-group
                                    .input-group-btn(if='{ (item.idAuthor || item.idCompany) }')
                                        a.btn.btn-default(target='_blank', href='{item.idAuthor ? "#persons/" + item.idAuthor : "#persons/companies/" + item.idCompany }')
                                            i.fa.fa-eye
                                    input.form-control(name='idAuthor',
                                    value='{ (item.idAuthor || item.idCompany) ? (item.idAuthor || item.idCompany) + " - " + item.customer : "" }', readonly)
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ changeCustomer }')
                                            i.fa.fa-list
                                .help-block { (error.idAuthor || error.idCompany) }
                        .col-md-2
                            .form-group
                                label.control-label Статус заказа
                                select.form-control(name='status', onchange='{ changeStatus }', disabled='{ item.status=="Y" }')
                                    option(each='{ key, value in orderItems }', value='{ key }',
                                    selected='{ key == item.status }', no-reorder) { value }
                        .col-md-2
                            .form-group
                                label.control-label Статус доставки
                                select.form-control(name='deliveryStatus')
                                    option(each='{ key, value in deliveryItems }', value='{ key }',
                                    selected='{ key == item.deliveryStatus }', no-reorder) { value }
                        .col-md-2
                            .form-group
                                label.control-label Менеджер
                                select.form-control(name='idAdmin')
                                    option(value="" selected='{ item.idAdmin == "" }') -
                                    option(each='{ manager in managers }', value='{ manager.id }',
                                    selected='{ manager.id == item.idAdmin }', no-reorder) { manager.title }
                    .row
                        .col-md-12
                            .well.well-sm
                                catalog-static(name='items', rows='{ item.items }', cols='{ itemsCols }', remove='{item.status=="N"}',
                                handlers='{ itemsHandlers }', dblclick='{ itemsHandlers.editProduct }')
                                    #{'yield'}(to='toolbar')
                                        .form-group(if='{ parent.item.status=="N" }')
                                            button.btn.btn-primary(type='button', onclick='{ opts.handlers.addProducts }')
                                                i.fa.fa-plus
                                                |  Добавить товар
                                            button.btn.btn-primary(type='button', onclick='{ opts.handlers.addServices }')
                                                i.fa.fa-plus
                                                |  Добавить услугу
                                    #{'yield'}(to='body')
                                        datatable-cell(name='article', style="max-width: 60px;")
                                            input(value='{ row.article }', type='text', readonly)
                                        datatable-cell(name='name')
                                            input(value='{ row.name }', type='text', readonly)
                                        datatable-cell(name='count', style="max-width: 20px;")
                                            input(value='{ row.count }', type='number', step='1', min='1',
                                            onchange='{ handlers.numberChange }')
                                        datatable-cell(name='price' style="max-width: 20px;")
                                            input(value='{ row.price }', type='number', step='1.00', min='0',
                                            onchange='{ handlers.numberChange }')
                                        datatable-cell(name='curr') { (row.curr) }
                                        datatable-cell(name='discount' style="max-width: 20px;")
                                            input(value='{ row.discount }', type='number', step='1.00', min='0',
                                            onchange='{ handlers.numberChange }')
                                        datatable-cell(name='sum' style="max-width: 20px;") { (row.count * (row.price - row.discount)).toFixed(2).toLocaleString() }
                                        datatable-cell(name='note')
                                            input(value='{ row.note }',
                                            onchange='{ handlers.stringChange }')
                                .alert.alert-danger(if='{ error.items }')
                                    | { error.items }

                    .row
                        .col-md-12
                            .form-group
                                label.control-label Комментарий к заказу
                                input.form-control(name='commentary', value='{ item.commentary }')

                    .row
                        .col-md-12
                            .h4 Суммы
                            .row
                                .col-md-3
                                    .form-group
                                        label.control-label Товаров и услуг
                                        input.form-control(value='{ sumProductsDisplay }', readonly)
                                .col-md-3
                                    .form-group
                                        label.control-label Доставка
                                        input.form-control(name='deliveryPayee', type='number',
                                        value='{ item.deliveryPayee / 1 }', min='0.00', step='0.01')
                                .col-md-3
                                    .form-group
                                        label.control-label Скидка
                                        input.form-control(name='discount', type='number',
                                        value='{ (item.discount / 1).toLocaleString()}', min='0.00', step='0.01')
                                .col-md-3
                                    .form-group.has-success
                                        label.control-label Итого
                                        input.form-control(value='{ totalDisplay }', readonly)

            #order-edit-delivery.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Доставка
                                .input-group
                                    input.form-control(name='deliveryName', value='{ item.deliveryName } { item.deliveryNote }', readonly)
                                    .input-group-btn(onclick='{ changeDelivery }')
                                        .btn.btn-default
                                            i.fa.fa-list
                        .col-md-6
                            .form-group
                                label.control-label Почтовый индекс
                                input.form-control(name='postindex', value='{ item.postindex }')
                        .col-md-12
                            .form-group
                                label.control-label Адрес
                                input.form-control(name='address', value='{ item.address }')
                        .col-md-6
                            .form-group
                                label.control-label E-mail
                                input.form-control(name='email', value='{ item.email }')
                                .help-block { error.email }
                        .col-md-6
                            .form-group
                                label.control-label Телефон
                                input.form-control(name='telnumber', value='{ item.telnumber }')
                                .help-block { error.telnumber }
                        .col-md-6
                            .form-group
                                label.control-label Время звонка
                                input.form-control(name='calltime', value='{ item.calltime }')
                        .col-md-6
                            .form-group
                                label.control-label Дата доставки
                                datetime-picker.form-control(name='deliveryDate', format='DD.MM.YYYY', value='{ item.deliveryDate }')
            #order-edit-pay.tab-pane.fade(if='{ !isNew }')
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-12
                            catalog(
                                if                = '{ item.id }',
                                object            = 'Order',
                                id                = '{ item.id }',
                                curr              = '{ item.curr }',
                                method            = 'Info',
                                items             = 'payments',
                                count             = 'paymentsCount',
                                cols              = '{ paymentsCols }',
                                allselect         = 'true',
                                store             = 'order-edit',
                                add               = '{ addPayment }',
                                remove            = '{ removePayment }',
                                sortable          = 'true',
                                disablePagination = 'true',

                                getDC             = 'OrderPaymen',
                            )
                                #{'yield'}(to='body')
                                    datatable-cell(name='date') { row.dateDisplay }
                                    datatable-cell(name='name') { row.name }
                                    datatable-cell(name='payer') { row.payer }
                                    datatable-cell.text-right(name='amount')
                                        span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                                        span  { row.amount.toFixed(2) }
                                        span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.curr !== null && row.curr !== "" ? row.curr : row.titleCurr }
                                    datatable-cell(name='note') { row.note }

            #order-edit-fields.tab-pane.fade(if='{ item.customFields && item.customFields.length }')
                add-fields-edit-block(name='customFields', value='{ item.customFields }')
    style.
        .text-noactive {
            color: #cccccc;
        }
    script(type='text/babel').
        var self = this,
            route = riot.route.create()


        self.isNew = false
        self.item = {}
        self.loader = false
        self.sumProducts = 0
        self.total = 0
        self.snd = true

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.send = () => {

            self.debuger({ ...self.debugParam, method:"send" })

            self.snd = !self.snd;
            self.update()
        }

        self.rules = () => {

            self.debuger({ ...self.debugParam, method:"rules" })

            let rules = {
                items: {
                    required: true,
                    rules: [{
                        type: 'minLength[1]',
                        prompt: 'В списке должно быть не менее одного элемента'
                    }]
                },
                /*telnumber: {
                    required: false,
                    rules: [{
                        type: 'phone'
                    }]
                },
                email: {
                    required: false,
                    rules: [{
                        type: 'email'
                    }]
                },*/
            }

            if (self.item && (self.item.idAuthor || self.item.idCompany))
                return { ...rules }
            else
                return { ...rules, idAuthor: 'empty' }
        }

        self.changeStatus = e => {

            self.debuger({ ...self.debugParam, method:"changeStatus" })

            if (e.target.value == 'Y') {
                self.addPayment()
            }
        }

        self.afterChange = e => {

            self.debuger({ ...self.debugParam, method:"afterChange" })
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules(), name)}
        }

        self.dynFieldsChange = e => {

            self.debuger({ ...self.debugParam, method:"dynFieldsChange" })
            let type = e.item.field.type

            if (type !== 'checkbox') {
                e.item.field.value = e.target.value
            } else {
                let checkedValues = (e.item.field.value || '').split(',')
                let checkedValue = e.target.getAttribute('data-value')
                let idx = checkedValues.indexOf(checkedValue)

                if (idx !== -1)
                    checkedValues.splice(idx, 1)
                else
                    checkedValues.push(checkedValue)

                e.item.field.value = checkedValues.filter(i => i).join(',')
            }
        }

        self.itemsCols = [
            {name: 'article', value: 'Артикул'},
            {name: 'name', value: 'Наименование'},
            {name: 'count', value: 'Кол-во'},
            {name: 'price', value: 'Цена'},
            {name: 'curr', value: 'ОКВ'},
            {name: 'discount', value: 'Скидка'},
            {name: 'summ', value: 'Стоимость'},
            {name: 'note', value: 'Примечание'},
        ]

        self.paymentsCols = [
            {name: 'date', value: 'Дата'},
            {name: 'name', value: 'Наименование'},
            {name: 'payer', value: 'Плательщик'},
            {name: 'amount', value: 'Сумма'},
            {name: 'note', value: 'Примечание'},
        ]

        self.displayFormat = (price) => {

            self.debuger({ ...self.debugParam, method:"displayFormat" })

            if (self.currPrefix != null)
                return (self.currPrefix + ' ' + price.toLocaleString())
            if (self.currSuffix != null)
                return (price.toLocaleString() + ' ' + self.currSuffix)
        }

        /** элементы Обработчики */
        self.itemsHandlers = {
            numberChange(e) {
                self.debuger({ ...self.debugParam, method:"numberChange" })
                this.row[this.opts.name] = e.target.value
            },
            stringChange(e) {
                self.debuger({ ...self.debugParam, method:"stringChange" })
                this.row[this.opts.name] = e.target.value
            },
            addServices() {
                self.debuger({ ...self.debugParam, method:"addServices" })
                modals.create('order-add-service-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        var _this = this
                        if (_this.item.name && _this.item.count > 0) {
                            _this.item.curr = self.item.curr
                            self.item.items = self.item.items || []
                            self.item.items.push(_this.item)
                            self.update()
                            this.modalHide()
                        }
                    }
                })
            },
            addProducts() {

                self.debuger({ ...self.debugParam, method:"addProducts" })

                self.debuger({ ...self.debugParam, method:"addProducts",
                    groupLog: "addProdD", dComment:">Добавить self.item.items",
                    dArray: self.item.items })

                let order = self.item
                modals.create('products-list-select-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {

                        self.debuger({ ...self.debugParam, method:"addProducts",
                            groupLog: "addProdD", dComment:"submit данные добавлены",
                            dArray: self.item.items })

                        let _this = this
                        let items = _this.tags.catalog.tags.datatable.getSelectedRows()
                        self.item.items = self.item.items || []

                        if (items.length > 0) {
                            if ('countModifications' in items[0] &&
                                items[0].countModifications > 0
                            ) {
                                modals.create('modifications-list-modal', {
                                    type: 'modal-primary',
                                    size: 'modal-lg',
                                    id: items[0].id,
                                    submit() {
                                        let items = this.tags['catalog-static'].tags.datatable.getSelectedRows()
                                        items.forEach(item => {
                                            let price = item.price
                                            self.item.items.push({...item, count: 1, discount: 0, id: null, idPrice: item.id})
                                        })
                                        self.update()
                                        this.modalHide()
                                        _this.modalHide()

                                        let event = document.createEvent('Event')
                                        event.initEvent('change', true, true)
                                        self.tags.items.root.dispatchEvent(event)
                                    }
                                })
                            } else {
                                let ids = self.item.items.map(item => item.id)

                                items.forEach(item => {
                                    if (ids.indexOf(item.id) === -1) {

                                        self.debuger({ ...self.debugParam, method:"addProducts",
                                            groupLog: "addProdD", dComment:"до добавления массив item",
                                            dArray: item })

                                        self.debuger({ ...self.debugParam, method:"addProducts",
                                            groupLog: "addProdD", dComment:"до добавления self.item.items",
                                            dArray: self.item.items })

                                        self.item.items.push({...item, count: 1, discount: 0, id: null, idPrice: item.id})
                                    }
                                })

                                self.update()
                                _this.modalHide()

                                let event = document.createEvent('Event')
                                event.initEvent('change', true, true)
                                self.tags.items.root.dispatchEvent(event)
                            }
                        }

                        // self.convertPrices()
                    }
                })
            },
            editProduct(e) {

                self.debuger({ ...self.debugParam, method:"editProduct" })

                let oldItem = Object.assign({}, e.item.row);
                let index = -1;
                self.item.items.forEach((item, i) => {
                    if (item.id === oldItem.id)
                        index = i
                })

                if (oldItem.idPrice) {

                    if (oldItem["idsModifications"]) {
                        modals.create('modifications-list-modal', {
                            type: 'modal-primary',
                            size: 'modal-lg',
                            id: oldItem.idPrice,
                            submit() {
                                let items = this.tags['catalog-static'].tags.datatable.getSelectedRows()
                                if (items.length > 0) {
                                    self.item.items[index] = {...items[0]}
                                    self.item.items[index].id = oldItem.id
                                    self.item.items[index].count = oldItem.count
                                    self.item.items[index].discount = oldItem.discount
                                    self.item.items[index].idPrice = oldItem.idPrice
                                    self.item.items[index].idsModifications = items[0].id
                                }

                                self.update()
                                this.modalHide()

                                let event = document.createEvent('Event')
                                event.initEvent('change', true, true)
                                self.tags.items.root.dispatchEvent(event)
                            }
                        })

                    } else {
                        let filters =
                        {
                            field: 'id',
                            value: e.item.row.idPrice
                        }
                        modals.create('products-list-select-modal', {
                            type: 'modal-primary',
                            size: 'modal-lg',
                            systemFilters: filters,
                            submit() {
                                let _this = this
                                let items = _this.tags.catalog.tags.datatable.getSelectedRows()
                                if (items.length > 0) {
                                    self.item.items[index] = {...items[0]}
                                    self.item.items[index].id = oldItem.id
                                    self.item.items[index].count = oldItem.count
                                    self.item.items[index].discount = oldItem.discount
                                    self.item.items[index].idPrice = oldItem.id
                                }

                                self.update()
                                _this.modalHide()

                                let event = document.createEvent('Event')
                                event.initEvent('change', true, true)
                                self.tags.items.root.dispatchEvent(event)

                            }
                        })
                    }

                } else {

                }
            }
        }

        self.orderItems = {
            Y: 'Оплачен', N: 'Не оплачен', A: 'Предоплата', D: 'Отказ', K: 'Кредит', P: 'Подарок', W: 'В ожидании', C: 'Возврат', T: 'Тест'
        }

        self.deliveryItems = {
            Y: 'Доставлен', N: 'Не доставлен', M: 'В работе', P: 'Отправлен'
        }

        self.changeDelivery = () => {
            self.debuger({ ...self.debugParam, method:"changeDelivery" })
            modals.create('delivery-list-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let _this = this
                    let items = _this.tags.catalog.tags.datatable.getSelectedRows()
                    self.item.deliveryName = items[0].name
                    self.item.deliveryType = items[0].id
                    self.update()
                    this.modalHide()
                }
            })
        }

        self.changeCustomer = () => {
            self.debuger({ ...self.debugParam, method:"changeCustomer" })
            modals.create('persons-company-list-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let _this = this.tags['bs-modal']
                    let items = _this.tags[_this.tab].tags.datatable.getSelectedRows()
                    if (!items.length) return

                    if (_this.tab == 'contacts') {
                        self.item.idAuthor = items[0].id
                        self.item.customer = items[0].displayName
                        self.item.idCompany = null
                    } else {
                        self.item.idCompany = items[0].id
                        self.item.customer = items[0].name
                        self.item.idAuthor = null
                    }

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.addPayment = () => {

            /** ПЕРЕРАСЧЕТ ДОПЛАТЫ
             *  1 подсчет суммы оплаты
             *  2 подсчет суммы стоимости
             *  3 подсчет cуммы оставшейся оплаты
             */

            self.debuger({ ...self.debugParam, method:"addPayment" })

            var sumAmountItems = 0
            var totalValue = 0
            self.item.payments.forEach(item => {
                sumAmountItems += item.amount
            }) // 1
            self.item.items.forEach(item => {
                totalValue += item.count * item.price - item.discount
            }) // 2
            self.item.paid = sumAmountItems
            self.item.surcharge = (totalValue - sumAmountItems).toFixed(2) // 3

            /**
             * @param {array}   self.item.payments     строки платежей
             * @param {str/int} _this.item.paymentType тип платежа
             */

            self.debuger({ ...self.debugParam, method:"addPayment",
                groupLog: "addPayment", dComment:"данные в payments-add-modal",
                dArray: self.item })

            modals.create('payments-add-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                order: self.item,
                submit() {
                    var _this = this;
                    if (_this.submit()){

                        var params = _this.item

                        self.debuger({ ...self.debugParam, method:"addPayment",
                            groupLog: "addPayment", dComment:"из всплывающего params",
                            dArray: params })

                        params["nameFront"] = self.item.pageCurr.nameFront
                        params["titleCurr"] = self.item.pageCurr.title

                        self.getPaymentTypeName(params)
                        params.payer       = self.item.customer
                        params.orderAmount = self.item.amount
                        if ((_this.item.amount + self.item.paid) >=self.item.amount){
                            self.item.status = 'Y'
                            self.item.datePayee = _this.item.date;
                            self.update()
                        }

                        /** @param {object} params данные платежа */
                        self.item.payments.push(params)
                        observable.trigger('datacatalog', {"OrderPaymen" : self.item.payments})

                        self.update()
                        self.tags.catalog.reload()
                        this.modalHide()
                    }
                }
            })
        }

        self.getPaymentTypeName = (params) => {

            /** получить имя платежной системы
             * @param  {array}   params.paymentTypeNames данные по типам платежей
             * @param  {int/str} params.paymentType      id типа платежа
             * @return {str}     params.name             имя платежной
             */

            self.debuger({ ...self.debugParam, method:"getPaymentTypeName" })

            var paySystemsId = {}
            params.paymentTypeNames.forEach(item => {
                paySystemsId[item["id"]] = item
            })
            params.name = paySystemsId[Number(params.paymentType)]["name"]
            delete params.paymentTypeNames
        }

        self.removePayment = (e, itemsToRemove, self) => {

            /** удаление групп из временного списка
             *  (нужно, что бы все группы были на листе - нужны id для allDelete)
             *  @param  {object}          e             MouseEvent данные мыши
             *  @param  {array or object} itemsToRemove массив id's на удаление или объект с allMode and allModeLastParams
             *  @param  {object}          self          данные по контакту
             *  @return {object}          observable.trigger 'datacatalog'
             */

            self.debuger({ ...self.debugParam, method:"removePayment" })


            /** если "удалить все" - получаем список id групп для последующего удаления */
            if (itemsToRemove.allMode != undefined) {
                itemsToRemove = []
                self.items.forEach(item => {
                    itemsToRemove.push(item.id)
                })
            }

            var iddatacatalog  = {}
            self.datacatalog.OrderPaymen.forEach(item => {    // получаем id
                iddatacatalog[item.id] = item
            })
            self.datacatalog.OrderPaymen = []                 // чистим

            itemsToRemove.forEach(item => {
                delete iddatacatalog[item]                // удаляем по id
            })

            for (var item in iddatacatalog) {             // возвращаем
                self.datacatalog.OrderPaymen.push(iddatacatalog[item])
            }
            observable.trigger('datacatalog', self.datacatalog) // записываем в транс-табличные данные

            self.update()
            return true;
        }

        self.convertPrices = () => {

            self.debuger({ ...self.debugParam, method:"convertPrices" })

            self.debuger({ ...self.debugParam, method:"convertPrices",
                groupLog: "addProdD", dComment:"при конвертации self.item.items",
                dArray: self.item.items })

            self.item.items.forEach((item, i) => {
                if (item.curr != self.item.curr) {

                    self.debuger({ ...self.debugParam, method:"convertPrices",
                        groupLog: "addProdD", dComment:"конвертация item.price",
                        dArray: { 'price': item.price, 'source': item.curr, 'target': self.item.curr, 'item': item } })

                    let params = { 'price': item.price, 'source': item.curr, 'target': self.item.curr }
                    API.request({
                        object: 'Currency',
                        method: 'CONVERT',
                        data: params,
                        success(response) {
                            item.price = response.price
                            item.curr = self.item.curr
                            self.update()
                        }
                    })
                }
            })
        }

        self.submit = e => {

            self.debuger({ ...self.debugParam, method:"submit" })

            /** @param {array} self.payments нумерованный массив платежей */


            var paramsPayments = {"payments" : self.item.payments,
                                  "idOrder"  : self.item.id}
            var params = self.item
            params.send = self.snd

            self.error = self.validation.validate(self.item, self.rules())

            self.debuger({ ...self.debugParam, method:"submit",
                groupLog: "submit", dComment:"API Payment Save", dArray: paramsPayments })

            self.debuger({ ...self.debugParam, method:"submit",
                groupLog: "submit", dComment:"API Order Save", dArray: params })

            if (!self.error) {
                API.request({
                    object: 'Order',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        self.isNew = false

                        self.update()
                        if (self.isNew)
                            riot.route(`/orders/${self.item.id}`)
                        popups.create({title: 'Успех!', text: 'Заказ сохранен!', style: 'popup-success'})
                        if (self.tags.catalog) self.tags.catalog.reload() // перезагрузка каталога
                        observable.trigger('orders-reload')
                    }
                })
            }
        }

        self.reloadButton = () => {

            /** обновление страницы карточки контакта с всплывающим предупреждением */

            self.debuger({ ...self.debugParam, method:"reloadButton" })

            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: 'Будут потеряны не сохраненные данные. Вы точно хотите обновить эту страницу?',
                size: 'modal-sm',
                buttons: [
                    {action: 'yes', title: 'Обновить', style: 'btn-danger'},
                    {action: 'no', title: 'Отмена', style: 'btn-default'},
                ],
                callback: function (action) {
                    if (action === 'yes') {
                        self.reload()
                    }
                    this.modalHide()
                }
            })
        }

        self.reload = e => {
            self.debuger({ ...self.debugParam, method:"reload" })
            observable.trigger('orders-edit', self.item.id)
        } // перезагрузить

        self.on('update', () => {

            if (self.item && self.item.items) {
                self.sumProducts = self.item.items.map(i => i.count * (i.price - i.discount)).reduce((p, c) => p + c, 0)
                if (parseFloat(self.sumProducts) > 0)
                    self.total = parseFloat(self.sumProducts || 0) + parseFloat(self.item.deliveryPayee || 0) - parseFloat(self.item.discount || 0)
                else
                    self.total = 0
                self.totalDisplay = self.displayFormat(self.total.toFixed(2))
                self.sumProductsDisplay = self.displayFormat(self.sumProducts.toFixed(2))
            }
        })

        self.on('mount', () => {
            riot.route.exec()
        })

        observable.on('order-new', () => {

            self.debuger({ ...self.debugParam, method:"order-new" })

            self.error = false
            self.isNew = true
            self.sumProducts = 0
            self.item = {
                deliveryPayee: 0,
                discount: 0,
                status: 'N',
                statusOrder: 'N',
                deliveryStatus: 'N',
                idAdmin: null
            }
            if (app.config.idUser && (app.config.idUser != 'admin'))
                self.item.idAdmin = app.config.idUser
            self.total = 0
            self.update()
            self.getManagers()
            self.getBaseCurrency()
        })

        observable.on('orders-edit', id => {

            self.debuger({ ...self.debugParam, method:"orders-edit" })

            self.debuger({ ...self.debugParam, method:"orders-edit",
                groupLog: "ordersEdit", dComment:"self start",
                dArray: self })

            var params = {id}
            params["curr"] = self.item.curr
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()
            self.getManagers()

            API.request({
                object: 'Order',
                method: 'Info',
                data: params,
                success(response) {
                    self.debuger({ ...self.debugParam, method:"orders-edit",
                        groupLog: "ordersEdit", dComment:"response", dArray: response })
                    self.item = response
                    self.loader = false
                    self.getBaseCurrency()
                    self.update()
                    if (self.tags.catalog && self.catalogReload) self.tags.catalog.reload({dcreset:true}) // перезагрузка каталога
                    self.catalogReload = true // перезагружать каталог, только после первой прогрузки
                }
            })
        })

        observable.on('datacatalog', (e) => {

            self.debuger({ ...self.debugParam, method:"datacatalog" })

            /** получение транс-табличных данных
             *  @param {object} e именаТаблиц-массивыСтрок
             *  @return {object} observable.trigger 'datacatalog'
             */

            self.datacatalog = e
            self.item.payments = self.datacatalog.OrderPaymen
        })

        self.getManagers = () => {
            self.debuger({ ...self.debugParam, method:"getManagers"})
            self.debuger({ ...self.debugParam, method:"getManagers", groupLog: "getManagers", dComment:"self", dArray: self })
            self.managers = []
            API.request({
                object: 'PermissionUser',
                method: 'Fetch',
                success(response) {
                  self.managers = response.items
                  self.update()
                }
            })
        }

        self.getBaseCurrency = () => {
            self.debuger({ ...self.debugParam, method:"getBaseCurrency" })
            API.request({
                 object: 'Main',
                 method: 'Info',
                 success(response) {
                     if (!self.item.curr)
                        self.item.curr = response.basecurr
                     self.basecurr = response.basecurr
                     response.listCurrency.forEach(item => {
                         if (item.name.toLowerCase() == self.item.curr.toLowerCase()) {
                            self.currSuffix = item.curr
                            self.currPrefix = item.nameFront
                         }
                     })
                    self.update()
                 }
            })
        }

        self.debugParam = {
            module   : "order-edit.tag",
            dClass   : "ord-ed",
            method   : "",
            dComment : "",
            groupLog : "norm",
            dArray   : undefined
        }
        self.debuger = (dp = self.debugParam) => {

            /** ДЕБАГЕР
             * 1 Запуск логов
             * 2 Настройки
             * 3 Формирование строки
             * 4 Отступ
             * 5 Очередность и отображение
             *
             * self.debuger({ ...self.debugParam, method:"allParams" })
             *
             * self.debuger({ ...self.debugParam, method:"reload",
             *                groupLog: "reload", dComment:"response", dArray: response })
             */

            // 1
            let startList = {
                norm        : true,
                addProdD    : false,
                submit      : false,
                addPayment  : false,
                ordersEdit  : false,
                getManagers : false,
            }

            if (startList[dp.groupLog]==true && document.domain=="localhost") {

                // 2
                let ind=30;  let ind2=12;   let sy=" ";    let col=" |";
                let gr=true; let com=true;  let met=true;  let cl=true;  let mod=true;

                // 3
                let groupLog = "gr: " + dp.groupLog
                let comment  = "com: " + dp.dComment
                let method   = "met: " + dp.method
                let clas     = "cl: " + dp.dClass
                let module   = "mod: " + dp.module

                // 4
                let groupLogLen = sy.repeat( ind2-groupLog.length >=0 ? ind2-groupLog.length : 0 ) +col
                let commentLen  = sy.repeat(  ind-comment.length  >=0 ?  ind-comment.length  : 0 ) +col
                let methodLen   = sy.repeat(  ind-method.length   >=0 ?  ind-method.length   : 0 ) +col
                let clasLen     = sy.repeat(  ind-clas.length     >=0 ?  ind-clas.length     : 0 ) +col
                let modLen      = sy.repeat(  ind-module.length   >=0 ?  ind-module.length   : 0 ) +col

                // 5
                let consoleLog = "|"
                if (gr==true)  consoleLog += groupLog + groupLogLen
                if (com==true) consoleLog += comment + commentLen
                if (met==true) consoleLog += method + methodLen
                if (cl==true)  consoleLog += clas + clasLen
                if (mod==true) consoleLog += module + modLen

                console.warn(consoleLog)
                if (dp.dArray != undefined) console.log(dp.dArray)
            }
        }
