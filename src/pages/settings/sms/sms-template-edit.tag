sms-template-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/sms') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("products", "0010") }', onclick='{ submit }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Новый SMS шаблон' : item.name || 'Редактирование SMS шаблона' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-6
                    .form-group(class='{ has-error: error.name }')
                        label.control-label Заголовок
                        input.form-control(name='name', value='{ item.name }')
                        .help-block { error.name }
                .col-md-6
                    .form-group(class='{ has-error: error.code }')
                        label.control-label Код
                        input.form-control(name='code', value='{ item.code }')
                        .help-block { error.code }
                .col-md-6
                    .form-group(class='{ has-error: error.phone }')
                        label.control-label Телефон
                        input.form-control(name='phone', value='{ item.phone }')
                        .help-block { error.phone }
                .col-md-6
                    .form-group
                        label.control-label Отправитель
                        input.form-control(name='sender', value='{ item.sender }')
            .row
                .col-md-12
                    .form-group(class='{ has-error: error.text }')
                        label.control-label Текст
                        textarea.form-control(name='text', value='{ item.text }', rows='5',
                        style='min-width: 100%; max-width: 100%;')
                        .help-block { error.text }
            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(name='isActive', type='checkbox', checked='{ item.isActive == 1 }')
                                | Активен


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
            code: 'empty',
            text: 'empty',
            phone: {
                required: true,
                rules:[{
                    type: 'phone'
                }]
            }
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'SmsTemplate',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'SMS шаблон сохранен!', style: 'popup-success'})
                        observable.trigger('sms-reload')
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('sms-edit', self.item.id)
        }

        observable.on('sms-edit', id => {
            self.item = {}
            self.loader = true
            self.error = false
            var params = {id: id}
            self.update()

            API.request({
                object: 'SmsTemplate',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                },
                error(response) {
                    self.item = {}
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })

        })

        observable.on('sms-new', () => {
            self.item = {}
            self.loader = false
            self.error = false
        })