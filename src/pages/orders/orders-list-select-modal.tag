orders-list-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Заказы
        #{'yield'}(to="body")
            catalog(object='Order', cols='{ parent.cols }', search='true', reload='false', disable-col-select='1',
                dblclick='{ parent.opts.submit.bind(this) }', filters='{ parent.filters }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='dateOrder') { row.dateOrderDisplay }
                    datatable-cell(name='customer') { row.customer }
                    datatable-cell(name='amount')
                        span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                        span  { row.amount.toFixed(2) }
                        span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'dateOrder' , value: 'Дата заказа' },
            { name: 'customer' , value: 'Заказчик' },
            { name: 'amount' , value: 'Сумма' }
        ]

        self.filters = [
            { "field": "is_delete",
              "value": "N"
            },
            { "field": "status",
              "sign": "<>",
              "value": "Y"
            }
        ]

