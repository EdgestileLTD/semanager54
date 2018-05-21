currency-new-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title { parent.opts.title || 'Добавить новую валюту' }
        #{'yield'}(to="body")
            form(name='form', onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-6
                        .form-group(class='{ has-error: error.name }')
                            label.control-label Обозначение*
                            input.form-control(name='name', value='{ item.name }')
                            .help-block { error.name }
                    .col-md-6
                        .form-group
                            label.control-label Предустановки
                            select.form-control(value='{ item.name }', onchange='{ currencyChange }')
                                option(value='')
                                option(each='{ currencies }', value='{ charCode }') { name }
                .row
                    .col-md-6
                        .form-group(class='{ has-error: error.title }')
                            label.control-label Название*
                            input.form-control(name='title', value='{ item.title }')
                            .help-block { error.title }
                    .col-md-6
                        .form-group
                            label.control-label Пред. текст
                            input.form-control(name='nameFront', value='{ item.nameFront }')
                .row
                    .col-md-6
                        .form-group
                            label.control-label Заверш. текст
                            input.form-control(name='nameFlang', value='{ item.nameFlang }')
                    .col-md-6
                        .form-group
                            label.control-label Код по ЦБРФ
                            input.form-control(name='cbrKod', value='{ item.cbrKod }')
                .row
                    .col-md-6
                        .form-group
                            label.control-label Мин. сумма
                            input.form-control(name='minSum', type='number', min='0.01', step='0.01', value='{ item.minSum }')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

        script(type='text/babel').
            var self = this

            self.on('mount', function () {
                let modal = self.tags['bs-modal']

                modal.mixin('validation')
                modal.mixin('change')
                modal.item = opts.item || { minSum: 0.01 }
                modal.error = false

                modal.rules = {
                    name: 'empty',
                    title: 'empty'
                }

                modal.afterChange = e => {
                    let name = e.target.name
                    delete modal.error[name]
                    modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
                }

                modal.currencyChange = e => {
                    let value = e.target.value
                    let item = modal.currencies.filter(item => {
                        return item.charCode == value
                    })

                    if (item.length) {
                        modal.item.cbrKod = item[0].id
                        modal.item.name = item[0].charCode
                        modal.item.title = item[0].name
                    }

                    modal.error = modal.validation.validate(modal.item, modal.rules)
                }

                API.request({
                    object: 'EnumValutes',
                    method: 'Fetch',
                    success(response){
                        modal.currencies = response.items
                        self.update()
                    }
                })

            })