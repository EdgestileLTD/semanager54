delivery-condition-param-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Условие доставки
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-12
                        .h4 Условия
                        .form-group
                            label.control-label Критерий заказа
                            select.form-control(name='typeParam', value='{ item.typeParam }')
                                option(value='sum') Сумма
                                option(value='weight') Вес
                                option(value='volume') Объем
                .row
                    .col-md-6
                        .form-group
                            label.control-label От
                            input.form-control(name='minValue', value='{ item.minValue }', type='number', min='0')
                    .col-md-6
                        .form-group
                            label.control-label До
                            input.form-control(name='maxValue', value='{ item.maxValue }', type='number', min='0')
                .row
                    .col-md-12
                        .form-group
                            label.control-label Приоритет
                            input.form-control(name='priority', value='{ item.priority }', type='number')
                .row
                    .col-md-12
                        .h4 Формирование цены (алгоритм подсчета)
                        .form-group
                            label.control-label Арифметика
                            select.form-control(name='operation', value='{ item.operation }')
                                option(value='=') Приравнивать
                                option(value='+') Добавлять
                                option(value='-') Вычитать
                        .form-group
                            label.control-label Тип формирования
                            select.form-control(name='typePrice', value='{ item.typePrice }')
                                option(value='a') Абсолютное значение
                                option(value='s') Процент от суммы заказа
                                option(value='d') Процент от цены доставки
                        .form-group
                            label.control-label { item.typePrice == "a" ? "Цена" : "Процент" }
                            input.form-control(name='price', value='{ item.price }', type='number', min='0')
                        hr
                        input.form-control(value='{ parent.opts.formatPrice(item) }', disabled='disabled')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = opts.item || {
                typeParam: 'sum',
                minValue: 0,
                maxValue: 0,
                priority: 0,
                operation: '=',
                typePrice: 'a',
                price: 0,
            }
            modal.mixin('change')
            modal.mixin('validation')


        })