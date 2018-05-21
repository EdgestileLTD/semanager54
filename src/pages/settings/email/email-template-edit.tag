email-template-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/email') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("mails", "0010") }', onclick='{ submit }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { item.name || 'Редактирование шаблона письма' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .form-group(class='{ has-error: error.title }')
                label.control-label Заголовок
                input.form-control(name='title', type='text', value='{ item.title }')
                .help-block { error.title }
            .form-group(class='{ has-error: error.subject }')
                label.control-label Тема письма
                input.form-control(name='subject', type='text', value='{ item.subject }')
                .help-block { error.subject }
            .form-group(class='{ has-error: error.mailtype }')
                label.control-label Код письма
                input.form-control(name='mailtype', type='text', value='{ item.mailtype }')
                .help-block { error.mailtype }
            .form-group
                label.control-label Тело шаблона
                ckeditor(name='letter', value='{ item.letter }')

    script(type='text/babel').
        var self = this

        self.loader = false
        self.item = {}

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            title: 'empty',
            subject: 'empty',
            mailtype: 'empty',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.reload = () => {
            observable.trigger('email-edit', self.item.id)
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                API.request({
                    object: 'EmailTemplate',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Шаблон сохранен!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/settings/email/${self.item.id}`)
                        observable.trigger('email-reload')
                    }
                })
            }
        }

        observable.on('email-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'EmailTemplate',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
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

        observable.on('email-new', () => {
            self.error = false
            self.isNew = true
            self.item = {}
            self.update()
        })

        self.on('mount', () => {
            riot.route.exec()
        })