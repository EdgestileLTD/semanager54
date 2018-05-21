measure-edit
    loader(if='{ loader }')
        virtual(hide='{ loader }')
            .btn-group
                a.btn.btn-default(href='#measurements') #[i.fa.fa-chevron-left]
                button.btn(if='{ checkPermission("paysystems", "0010") }', onclick='{ submit }',
                class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                    i.fa.fa-floppy-o
                    |  Сохранить
                button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                    i.fa.fa-refresh
            .h4 { isNew ? item.namePayment || 'Добавление платежной системы' : item.namePayment || 'Редактирование платежной системы' }

            form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                .form-group(class='{ has-error: error.namePayment }')
                    label.control-label Наименование
                    input.form-control(name='namePayment', type='text', value='{ item.namePayment }')
                    .help-block { error.namePayment }


    script(type='text/babel').
        var self = this


        observable.on('measure-edit', (id, section) => {
            console.log("ok")

            self.error = false
            self.loader = true
            self.isNew = false
            self.item = {}
            self.update()

            API.request({
                object: 'PaySystem',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                    observable.trigger('pay-systems-reload')
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

