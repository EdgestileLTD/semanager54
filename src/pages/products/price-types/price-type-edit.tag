| import 'components/loader.tag'

price-type-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products/price-types') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("products", "0010") }', onclick='{ submit }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { item.name || 'Тип цены' }
        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-4
                    .form-group(class='{ has-error: error.code }')
                        label.control-label Код
                        input.form-control(name='code', type='text', value='{ item.code }')
                        .help-block { error.code }
                .col-md-8
                    .form-group(class='{ has-error: error.name }')
                        label.control-label Наименование
                        input.form-control(name='name', type='text', value='{ item.name }')
                        .help-block { error.name }


    script(type='text/babel').
        var self = this

        self.item = {}
        self.loader = false
        self.error = false
        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
           name: 'empty',
           code: 'empty'
        }

        self.afterChange = e => {
            self.error = self.validation.validate(self.item, self.rules, e.target.name)
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'PriceType',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        observable.trigger('price-types-reload')
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('price-types-edit', self.item.id)
        }

        observable.on('price-types-edit', id => {
            self.loader = true
            self.error = false
            var params = {id: id}

            API.request({
                object: 'PriceType',
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

        observable.on('price-types-new', () => {
            self.error = false
            self.item = {}
            self.isNew = true
            self.update()
        })

        self.on('update', () => {
            localStorage.setItem('SE_section', 'price-types')
        })

        self.on('mount', () => {
            riot.route.exec()
        })