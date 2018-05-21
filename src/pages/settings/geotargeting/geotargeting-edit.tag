| import parallel from 'async/parallel'
| import 'pages/delivery/delivery-regions.tag'
| import 'pages/settings/geotargeting/geotargeting-vars-modal.tag'

geotargeting-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/geotargeting') #[i.fa.fa-chevron-left]
            button.btn(onclick='{ submit }', class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Добавление контакта' : item.name || 'Редактирование контакта' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-4
                    .form-group(class='{ has-error: error.name }')
                        label.control-label Наименование
                        input.form-control(name='name', value='{ item.name }')
                        .help-block { error.name }
                .col-md-4
                    .form-group(class='{ has-error: error.city }')
                        label.control-label Город привязки
                        .input-group
                            input.form-control(value='{ item.city }', readonly='{ true }')
                            .input-group-btn
                                .btn.btn-default(onclick='{ selectCity }')
                                    i.fa.fa-list.text-primary
                                .btn.btn-default(onclick='{ removeCity }')
                                    i.fa.fa-times.text-danger
                        .help-block { error.city }
                .col-md-4
                    .form-group(class='{ has-error: error.address }')
                        label.control-label Адрес
                        input.form-control(name='address', value='{ item.address }')
                        .help-block { error.address }
            .row
                .col-md-4
                    .form-group(class='{ has-error: error.phone }')
                        label.control-label Телефон
                        input.form-control(name='phone', value='{ item.phone }')
                        .help-block { error.phone }
                .col-md-4
                    .form-group(class='{ has-error: error.additionalPhones }')
                        label.control-label Доп. телефоны
                        input.form-control(name='additionalPhones', value='{ item.additionalPhones }')
                        .help-block { error.additionalPhones }
                .col-md-4
                    .form-group(class='{ has-error: error.url }')
                        label.control-label URL домена
                        input.form-control(name='url', value='{ item.url }')
                        .help-block { error.url }
            .row
                .col-md-12
                    .form-group
                        label.control-label Примечание
                        textarea.form-control(name='description', rows='5', style='min-width: 100%; max-width: 100%;',
                        value='{ item.description }')
            .row
                .col-md-12
                    .form-group
                        catalog-static(name='variables', rows='{ item.variables }', cols='{ variablesCols }',
                        handlers='{ variablesHandlers }')
                            #{'yield'}(to='toolbar')
                                a.control-label(href='#settings/seo-variables') SEO переменные
                            #{'yield'}(to='body')
                                datatable-cell(name='id', style='width: 1%;') { row.id }
                                datatable-cell(name='name', style='width: 15%;') { row.name }
                                datatable-cell(name='value')
                                    input.form-control(value='{ row.value }', type='text',
                                    oninput='{ handlers.changeValue }')
                                datatable-cell(name='edit', style='width: 1%')
                                    button.btn.btn-default(onclick='{ handlers.editVars }', title='Редактор')
                                        i.fa.fa-edit

            .row
                .col-md-2
                    .form-group
                        label.control-label Порядок
                        input.form-control(name='sort', type='number', min='0', step='1', value='{ item.sort }')
            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(name='isVisible', type='checkbox', checked='{ item.isVisible }')
                                | Отображать контакт в магазине

    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.variablesCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'value', value: 'Значение'},
            {name: '', value: ''},
        ]

        self.variablesHandlers = {
            changeValue(e) {
                this.row.value = e.target.value
            },
            editVars(e) {
                var _this = this
                //this.row.value = e.target.value
                modals.create('geotargeting-vars-modal', {
                    type: 'modal-primary',
                    item: this.row,
                    submit() {
                        this.row = this.item
                        this.modalHide()
                        self.update()
                    }
                })
            }
        }

        observable.on('geotargeting-edit', id => {
            self.error = false
            self.loader = true
            self.isNew = false
            self.item = {}
            self.update()

            API.request({
                object: 'GeoTargeting',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                },
                error() {
                    self.item = {}
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })

        })


        self.submit = () => {
            var params = self.item
            self.loader = true
            self.update()

            API.request({
                object: 'GeoTargeting',
                method: 'Save',
                data: params,
                success(response) {
                    self.item = response
                    popups.create({title: 'Успех!', text: 'Контакт геотаргетинга сохранен!', style: 'popup-success'})
                    observable.trigger('geotargeting-reload')
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })

        }

        self.rules = {
            name: 'empty',
            phone: {
                required: true,
                rules:[{
                    type: 'phone'
                }]
            },
            additionalPhones: {
                required: true,
                rules:[{
                    type: 'phone'
                }]
            },
            url: {
                rules:[{
                    type: 'url'
                }]
            },
            text: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        observable.on('geotargeting-new', () => {
            self.error = false
            self.isNew = true
            self.item = { sort: 0, isVisible: true  }
            self.update()
        })

        self.selectCity = () => {
            modals.create('delivery-regions', {
                type: 'modal-primary',
                item: { idCityTo: self.item.idCity },
                submit() {
                    if (this.tags.idCityTo.value) {
                        self.item.idCity = this.tags.idCityTo.value
                        self.item.city = this.tags.idCityTo.filterValue
                    }
                    this.modalHide()
                    self.update()
                }
            })
        }

        self.removeCity = () => {
            self.item.idCity = null
            self.item.city = null
            self.update()
        }

        self.reload = () => {
            observable.trigger('geotargeting-edit', self.item.id)
        }



