| import 'pages/products/parameters/parameters-list-select-modal.tag'


modification-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products/modifications') #[i.fa.fa-chevron-left]
            button.btn(if='{ isNew ? checkPermission("products", "0100") : checkPermission("products", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Добавление модификации' : item.name || 'Редактирование модификации' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-6
                    .form-group(class='{ has-error: error.name }')
                        label.control-label Наименование
                        input.form-control(name='name', value='{ item.name }')
                        .help-block { error.name }
                .col-md-6
                    .form-group(class='{ has-error: error.type }')
                        label.control-label Тип цены
                        select.form-control(name='vtype', value='{ item.vtype }')
                            option(value='0') Добавляет к цене
                            option(value='1') Умножает на цену
                            option(value='2') Замещает цену
                        .help-block { error.vtype }

            .row
                .col-md-12
                    catalog-static(name='values', add='{ addColumns }', cols='{ columnsCols }', rows='{ item.values }', remove='true')
                        #{'yield'}(to='body')
                            datatable-cell(name='name') { row.name }
                    .alert.alert-danger(if='{ error.values }')
                        | { error.values }


    script(type='text/babel').
        var self = this

        self.item = {}
        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            name: 'empty',
            values: {
                required: true,
                rules: [{
                    vtype: 'minLength[1]',
                    prompt: 'В списке должно быть не менее одного элемента'
                }]
            },
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        // o_O
        self.columnsCols = [
            {name: 'name', value: 'Наименование'},
        ]

        self.addColumns = function() {
            let _this = this
            modals.create('parameters-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                filters: {field: 'type', sign: 'IN', value: 'list, colorlist'},
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

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.tags.values.root.dispatchEvent(event)
                }
            })
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(self.item, self.rules)
            if (!self.error) {
                API.request({
                    object: 'Modification',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        self.update()
                        popups.create({title: 'Успех!', text: 'Модификация сохранена!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`products/modifications/${response.id}`)
                        observable.trigger('modifications-reload')
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('modifications-edit', self.item.id)
        }

        observable.on('modifications-new', () => {
            self.error = false
            self.isNew = true
            self.item = { values:[] }
            self.update()
        })

        observable.on('modifications-edit', id => {
            var params = {id: id }
            self.error = false
            self.loader = true
            self.isNew = false
            self.item = {}

            API.request({
                object: 'Modification',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.update({
                        loader: false
                    })
                }
            })
        })

        self.on('mount', () => {
            riot.route.exec()
        })