price-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Наценка товаров
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label Цена
                    input.form-control(name='price', type='number', step='0.01', value='{ item.price }')
                .form-group
                    label.control-label Валюта
                    select.form-control(name='currency', value='{ item.currency }')
                        option(each='{ c, i in parent.currencies }', value='{ c.name }',
                        selected='{ c.name == item.curr }', no-reorder) { c.title }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        API.request({
            object: 'Currency',
            method: 'Fetch',
            data: {},
            success(response) {
                self.currencies = response.items
                self.update()
            }
        })

        self.on('mount', () => {
            self.tags['bs-modal'].mixin('change')
            self.tags['bs-modal'].item = {
                price: opts.price || 0
            }
        })