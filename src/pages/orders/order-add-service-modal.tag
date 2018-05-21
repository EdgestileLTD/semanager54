order-add-service-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Услуга
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-12
                        .form-group(class='{ has-error: error.name }')
                            label.control-label Наименование*
                            input.form-control(name='name', value='{ item.name }')
                            .help-block { error.name }
                .row
                    .col-md-6
                        .form-group
                            label.control-label Цена
                            input.form-control(type='number', name='price', min='0', max='999999999', value='{ item.price }')
                    .col-md-6
                        .form-group
                            label.control-label Скидка
                            input.form-control(type='number', name='discount', min='0', max='999999999', value='{ item.discount }')
                .row
                    .col-md-6
                        .form-group
                            label.control-label Количество
                            input.form-control(type='number', name='count', min='0.001', step='0.001', max='999999999', value='{ item.count }')
                    .col-md-6
                        .form-group
                            label.control-label Итого
                            input.form-control(name='total', readonly='true', value='{ item.total }')
                .row
                    .col-md-12
                        .form-group
                            label.control-label Описание
                            textarea.form-control(name='note', cols='2')


        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(if='{ !error }', onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Добавить

    script(type='text/babel').
        var self = this
        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = {}
            modal.item.article = ''
            modal.item.name = ''
            modal.error = true
            modal.mixin('validation')
            modal.mixin('change')
            modal.rules = () => {
                let rules = {
                    name: 'empty',
                    count: 'empty',
                    price: 'empty'
                }
            }
            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }
            modal.on('update', () => {
                modal.item.price = modal.item.price || 0
                modal.item.discount = modal.item.discount || 0
                modal.item.count = modal.item.count || 1
                modal.item.total = (modal.item.price - modal.item.discount) * modal.item.count
            })
        })
