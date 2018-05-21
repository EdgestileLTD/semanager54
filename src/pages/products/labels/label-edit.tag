| import 'pages/products/products/products-list-select-modal.tag'

label-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#products/labels') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("products", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Новая метка товара' : item.name || 'Редактирование метки' }
        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#label-edit-main') Информация о метки
            li: a(data-toggle='tab', href='#label-edit-products') Товары
        form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
            .tab-content
                #label-edit-main.tab-pane.fade.in.active
                    .form-group(class='{ has-error: error.name }')
                        .row
                            .col-md-2
                                .form-group
                                    label.control-label Иконка
                                    .well.well-sm
                                        image-select(name='imageFile', alt='0', section='labels', size='64', value='{ item.imageFile }')
                            .col-md-10
                                .form-group
                                    label.control-label Название метки
                                    input.form-control(name='name', type='text', value='{ item.name }')
                                    .help-block { error.name }
                                .form-group
                                    label.control-label Код
                                    input.form-control(name='code', type='text', value='{ item.code }')
                                    .help-block { error.code }
                #label-edit-products.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='products', add='{ addProducts }',
                            cols='{ productsCols }', rows='{ item.products }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.productsCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.rules = {
            name: 'empty',
            code: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = () => {
            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'ProductLabel',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Метка для товара сохранена!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`products/labels/${self.item.id}`)
                        observable.trigger('products-labels-reload')
                        self.update()
                    }
                })
            }
        }

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


        self.reload = () => observable.trigger('labels-edit', self.item.id)

        observable.on('label-new', () => {
            self.error = false
            self.item = {}
            self.isNew = true
            self.update()
        })

        observable.on('labels-edit', id => {
            self.error = false
            self.loader = true
            self.item = {}
            self.isNew = false
            self.update()

            API.request({
                object: 'ProductLabel',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        })

