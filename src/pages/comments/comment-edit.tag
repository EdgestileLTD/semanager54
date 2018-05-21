comment-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#reviews/comments') #[i.fa.fa-chevron-left]
            button.btn(if='{ isNew ? checkPermission("comments", "0100") : checkPermission("comments", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 Комментарий к товару:
            b {item.nameProduct}

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        label.control-label Дата
                        datetime-picker.form-control(name='date', format='YYYY-MM-DD', value='{ item.date }')
                .col-md-4
                    .form-group(class='{ has-error: error.idPrice }')
                        label.control-label Товар
                        .input-group
                            .input-group-btn
                                a.btn.btn-default(if='{ item.idPrice }', href='#products/{ item.idPrice }', target='_blank')
                                    i.fa.fa-eye
                            input.form-control(name='nameProduct', type='text', value='{ item.nameProduct }', readonly)
                            .input-group-btn
                                .btn.btn-default(onclick='{ changeProduct }')
                                    i.fa.fa-list.text-primary
                        .help-block { error.idPrice }
            .row
                .col-md-8
                    .form-group(class='{ has-error: error.name }')
                        label.control-label Автор комментария
                        input.form-control(name='name', type='text', value='{ item.name }')
                        .help-block { error.name }
                .col-md-4
                    .form-group(class='{ has-error: error.email }')
                        label.control-label Email
                        input.form-control(name='email', type='text', value='{ item.email }')
                        .help-block { error.email }
            .row
                .col-md-12
                    .form-group
                        label.control-label Комментарий
                        textarea.form-control(rows='5', name='commentary',
                        style='min-width: 100%; max-width: 100%;', value='{ item.commentary }')
            .row
                .col-md-12
                    .form-group
                        label.control-label
                            b Ответ администратора
                        textarea.form-control(rows='5', name='response',
                        style='min-width: 100%; max-width: 100%;', value='{ item.response }')



    script(type='text/babel').
        var self = this

        self.item = {}

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            idPrice: 'empty',
            name: 'empty',
            email: 'email',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = e => {
            var params = self.item

            self.error = self.validation.validate(self.item, self.rules)
            if (!self.error) {
                API.request({
                    object: 'Comment',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        if (self.isNew)
                            riot.route(`/reviews/comments/${self.item.id}`)
                        self.update()
                        observable.trigger('comments-reload')
                    }
                })
            }
        }

        self.changePerson = () => {
            modals.create('persons-list-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idUser = items[0].id
                        self.item.nameUser = items[0].displayName
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.changeProduct = () => {
            modals.create('products-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idPrice = items[0].id
                        self.item.nameProduct = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        observable.on('comment-edit', id => {
            var params = {id}
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Comment',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
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

        observable.on('comment-new', () => {
            self.isNew = true
            self.item = {}
            self.update()
        })

        self.reload = () => {
            observable.trigger('comment-edit', self.item.id)
        }

        self.on('mount', () => {
            riot.route.exec()
        })