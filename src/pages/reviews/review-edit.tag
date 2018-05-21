review-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#reviews') #[i.fa.fa-chevron-left]
            button.btn(onclick='{ submit }', type='button', class='{ item._edit_ ? "btn-success" : "btn-default" }')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  Отзыв к товару:
            b  { isNew ? '' : item.nameProduct}

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        label.control-label Дата
                        datetime-picker.form-control(name='date', format='YYYY.MM.DD HH:mm', value='{ item.date }')
                .col-md-2
                    .form-group
                        label.control-label Оценка
                        star-rating(name='mark', count='5', size='middle', value='{ item.mark }')
                .col-md-2
                    .form-group
                        label.control-label Опыт использования
                        select.form-control(name='useTime', value='{ item.useTime }')
                            option(value='1') Менее месяца
                            option(value='2') Несколько месяцев
                            option(value='3') Более года

                .col-md-3
                    .form-group
                        label.control-label Лайков
                        .input-group
                            input.form-control(type='number', name='likes', value='{ item.likes }', min='0')
                            span.input-group-addon
                                i.fa.fa-thumbs-o-up
                .col-md-3
                    .form-group
                        label.control-label Дислайков
                        .input-group
                            input.form-control(type='number', name='dislikes', value='{ item.dislikes }', min='0')
                            span.input-group-addon
                                i.fa.fa-thumbs-o-down
            .row
                .col-md-4
                    .form-group
                        label.control-label Автор отзыва
                        .input-group
                            .input-group-btn
                                a.btn.btn-default(if='{ item.idUser }', href='#persons/{ item.idUser }', target='_blank')
                                    i.fa.fa-eye
                            input.form-control(name='nameUser', type='text', value='{ item.nameUser }', readonly)
                            .input-group-btn
                                .btn.btn-default(onclick='{ changePerson }')
                                    i.fa.fa-list.text-primary
                .col-md-4
                    .form-group
                        label.control-label Товар
                        .input-group
                            .input-group-btn
                                a.btn.btn-default(if='{ item.idPrice }', href='#products/{ item.idPrice }', target='_blank')
                                    i.fa.fa-eye
                            input.form-control(name='nameProduct', type='text', value='{ item.nameProduct }', readonly)
                            .input-group-btn
                                .btn.btn-default(onclick='{ changeProduct }')
                                    i.fa.fa-list.text-primary
                .col-md-4
                    .form-group
                        label.control-label Email
                        input.form-control(name='contactEmail', type='text', value='{ item.contactEmail }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Достоинства
                        textarea.form-control(rows='5', name='merits',
                        style='min-width: 100%; max-width: 100%;', value='{ item.merits }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Недостатки
                        textarea.form-control(rows='5', name='demerits',
                        style='min-width: 100%; max-width: 100%;', value='{ item.demerits }')

            .row
                .col-md-12
                    .form-group
                        label.control-label Отзыв
                        textarea.form-control(rows='5', name='comment',
                        style='min-width: 100%; max-width: 100%;', value='{ item.comment }')

            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(name='isActive', type='checkbox', value='{ parseInt(item.isActive) }')
                                | Активен


    script(type='text/babel').
        var self = this

        self.item = {}
        self.orders = []

        self.mixin('change')

        self.submit = e => {
            var params = self.item
            self.loader = true

            API.request({
                object: 'Review',
                method: 'Save',
                data: params,
                success(response) {
                    self.item = response
                    if (self.isNew)
                        riot.route(`/reviews/${self.item.id}`)
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                    observable.trigger('reviews-reload')
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
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

        observable.on('review-edit', id => {
            var params = {id: id}
            self.loader = true
            self.isNew = false

            API.request({
                object: 'Review',
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

        observable.on('review-new', () => {
            self.item = {}
            self.isNew = true
            self.update()
        })

        self.reload = () => {
            observable.trigger('review-edit', self.item.id)
        }

        self.on('mount', () => {
            riot.route.exec()
        })