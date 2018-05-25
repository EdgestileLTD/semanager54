| import 'components/loader.tag'

warehouse-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products/warehouses') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("products", "0010") }', onclick='{ submit }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { item.name || 'Редактирование склада' }
        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-4
                    .form-group(class='{ has-error: error.name }')
                        label.control-label Наименование
                        input.form-control(name='name', type='text', value='{ item.name }')
                        .help-block { error.name }
                .col-md-3
                    .form-group
                        label.control-label Телефон
                        input.form-control(name='phone', type='text', value='{ item.phone }')
                .col-md-5
                    .form-group
                        label.control-label Адрес
                        input.form-control(name='address', type='text', value='{ item.address }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Примечание
                        textarea.form-control(rows='5', name='note',
                        style='min-width: 100%; max-width: 100%;', value='{ item.note }')


    script(type='text/babel').
        var self = this

        self.item = {}
        self.loader = false
        self.error = false
        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.afterChange = e => {
            self.error = self.validation.validate(self.item, self.rules, e.target.name)
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Warehouse',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Склад сохранен!', style: 'popup-success'})
                        observable.trigger('warehouses-reload')
                    }
                })
        }
        }

        self.reload = () => {
            observable.trigger('warehouses-edit', self.item.id)
        }

        observable.on('warehouses-edit', id => {
            self.loader = true
            self.error = false
            var params = {id: id}

            API.request({
                object: 'Warehouse',
                method: 'Info',
                data: params,
                success(response) {
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

        observable.on('warehouse-new', () => {
            self.error = false
            self.item = {}
            self.isNew = true
            self.update()
        })

        self.on('update', () => {
            localStorage.setItem('SE_section', 'warehouses')
        })

        self.on('mount', () => {
            riot.route.exec()
        })