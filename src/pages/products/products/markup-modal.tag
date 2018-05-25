markup-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Наценка товаров
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label Тип наценки
                    select.form-control(name='value', value='{ item.value }')
                        option(value='p') Наценка в процентах
                        option(value='a') Наценка в абсолютном значении
                .form-group
                    label.control-label Значение
                    div(class='{ "input-group": item.value == "p" }')
                        input.form-control(name='price', type='number', step='0.01', value='{ item.price }')
                        span.input-group-addon(if='{ item.value == "p" }') %

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            self.tags['bs-modal'].mixin('change')
            self.tags['bs-modal'].item = {
                value: "p",
                price: 0
            }
        })