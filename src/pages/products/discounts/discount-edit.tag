| import 'components/week-days-checkbox.tag'
| import 'components/catalog-static.tag'


discount-edit
    loader(if='{ loader }')
    virtual(if='{ !loader }')
        .btn-group
            a.btn.btn-default(href='#products/discounts') #[i.fa.fa-chevron-left]
            button.btn(if='{ isNew ? checkPermission("products", "0100") : checkPermission("products", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.title || 'Добавление скидки' : item.title || 'Редактирование скидки' }
        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#discount-edit-parameters') Параметры]
            li #[a(data-toggle='tab', href='#discount-edit-groups') Группы товаров]
            li #[a(data-toggle='tab', href='#discount-edit-products') Товары]
            li #[a(data-toggle='tab', href='#discount-edit-personsgroup') Группы Контактов]
            li #[a(data-toggle='tab', href='#discount-edit-persons') Контакты]

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #discount-edit-parameters.tab-pane.fade.in.active
                    .row
                        .col-md-4
                            .form-group(class='{ has-error: error.title }')
                                label.control-label Наименование
                                input.form-control(name='title', value='{ item.title }')
                                .help-block { error.title }
                        .col-md-2
                            .form-group
                                label.control-label Тип контакта
                                select.form-control(name='customerType', value='{ item.customerType }')
                                    option(value='') Для всех
                                    option(value='1') Для физических лиц
                                    option(value='2') Для юридических лиц (компаний)
                        .col-md-3
                            .form-group
                                label.control-label Тип значения
                                select.form-control(name='typeDiscount', value='{ item.typeDiscount }')
                                    option(value='absolute') Сумма
                                    option(value='percent') Процент
                        .col-md-3
                            .form-group
                                label.control-label Скидка
                                .input-group
                                    input.form-control(name='discount', step='0.01', min='0' type='number', value='{ item.discount }')
                                    span.input-group-addon
                                        | { item.typeDiscount == 'percent' ? '%' : 'р.' }

                    .row
                        .col-md-2
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', checked='{ floatingDiscount }', onchange='{ toggleFloatingDiscount }')
                                        | Плавающая скидка
                        .col-md-2
                            .form-group
                                .checkbox-inline
                                    label
                                        input(name='weekProduct', type='checkbox', checked='{ item.weekProduct }')
                                        | Товар недели
                    .row
                        .col-md-6
                            .form-group(if='{ floatingDiscount }')
                                label.control-label Шаг скидки
                                .input-group
                                    input.form-control(name='stepDiscount', type='number', step='0.01', value='{ item.stepDiscount }')
                                    span.input-group-addon
                                        | { item.typeDiscount == 'percent' ? '%' : 'р.' }
                        .col-md-6
                            .form-group(if='{ floatingDiscount }')
                                label.control-label Шаг времени
                                .input-group
                                    input.form-control(name='stepTime', type='number', min='0', value='{ item.stepTime }')
                                    span.input-group-addon
                                        | ч.

                    .row
                        .col-md-12
                            h4 Условия предоставления скидки
                            .row
                                .col-md-2
                                    .form-group
                                        label.control-label От даты
                                        datetime-picker.form-control(name='dateFrom',
                                        format='DD.MM.YYYY HH:mm', value='{ item.dateFrom }')
                                .col-md-2
                                    .form-group
                                        label.control-label До даты
                                        datetime-picker.form-control(name='dateTo',
                                        format='DD.MM.YYYY HH:mm', value='{ item.dateTo }')

                                .col-md-4
                                    .form-group
                                        label.control-label Дни недели
                                        br
                                        week-days-checkbox(name='week', value='{ item.week }')
                    .row
                        .col-md-12
                            .row
                                .col-md-4
                                    .form-group
                                        label.control-label Тип суммы
                                        select.form-control(name='summType', value='{ item.summType }')
                                            option(value='0') Сумма текущей корзины
                                            option(value='1') Сумма всех заказов
                                            option(value='2') Сумма всех заказов + сумма текущей корзины
                            .row
                                .col-md-3
                                    .form-group
                                        label.control-label От суммы
                                        .input-group
                                            input.form-control(name='summFrom', step='0.01', min='0' type='number', value='{ item.summFrom }')
                                            span.input-group-addon р.
                                .col-md-3
                                    .form-group
                                        label.control-label До суммы
                                        .input-group
                                            input.form-control(name='summTo', step='0.01', min='0' type='number', value='{ item.summTo }')
                                            span.input-group-addon р.
                                .col-md-3
                                    .form-group
                                        label.control-label От кол-ва
                                        input.form-control(name='countFrom', min='0' type='number', value='{ item.countFrom }')
                                .col-md-3
                                    .form-group
                                        label.control-label До кол-ва
                                        input.form-control(name='countTo', min='0' type='number', value='{ item.countTo }')

                #discount-edit-groups.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='listGroupsProducts', add='{ addGroupsProductsPersons("group-select-modal") }',
                            cols='{ cols }', rows='{ item.listGroupsProducts }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='name') { row.name }

                #discount-edit-products.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='listProducts', add='{ addGroupsProductsPersons("products-list-select-modal") }',
                            cols='{ cols }', rows='{ item.listProducts }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='name') { row.name }
                #discount-edit-personsgroup.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='listGroupsContacts', add='{ addGroupsProductsPersons("persons-category-select-modal") }',
                            cols='{ cols }', rows='{ item.listGroupsContacts }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='name') { row.name }
                                    datatable-cell(name='title') { row.title }
                #discount-edit-persons.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='listContacts', add='{ addGroupsProductsPersons("persons-list-select-modal") }',
                            cols='{ cols }', rows='{ item.listContacts }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='lastName') { [row.lastName, row.firstName, row.secondName].join(' ') }


    script(type='text/babel').
        var self = this

        self.prevStepDiscount = 0
        self.prevStepTime = 0

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.rules = {
            title: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.submit = () => {
            var params = self.item

            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Discount',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Скидка сохранена!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`products/discounts/${self.item.id}`)
                        observable.trigger('discount-reload')
                    }
                })
            }
        }

        self.addGroupsProductsPersons = function(modal) {
            return function() {
                let _this = this

                modals.create(modal, {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        _this.value = _this.value || []
                        let items = []

                        if (modal == 'group-select-modal') {
                            items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                        } else {
                            items = this.tags.catalog.tags.datatable.getSelectedRows()
                        }
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

        self.reload = () => {
            observable.trigger('discounts-edit', self.item.id)
        }

        observable.on('discounts-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.loader = true
            self.update()

            API.request({
                object: 'Discount',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.floatingDiscount =
                        (parseInt(self.item.stepDiscount) !== 0 && parseInt(self.item.stepTime) !== 0)
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        })

        self.toggleFloatingDiscount = () => {
            self.floatingDiscount = !self.floatingDiscount
            if (self.floatingDiscount) {
                self.item.stepDiscount = self.prevStepDiscount
                self.item.stepTime = self.prevStepTime
            } else {
                self.prevStepDiscount = self.item.stepDiscount
                self.prevStepTime = self.item.stepTime
                self.item.stepDiscount = 0
                self.item.stepTime = 0
            }
        }

        observable.on('discounts-new', () => {
            self.error = false
            self.isNew = true
            self.item = {}
            self.update()
        })

        self.on('mount', () => {
            riot.route.exec()
        })