delivery-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title { parent.opts.title || 'Справочник доставок' }
        #{'yield'}(to="body")
            catalog(
                object='Delivery',
                cols='{ parent.cols }',
                reload='true',
                handlers='{ parent.handlers }',
                dblclick='{ parent.opts.submit.bind(this) }'
            )
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='code') { handlers.types[row.code].name }
                    datatable-cell.text-right(name='period') { row.period != 0 ? row.period + " дн." : ""  }
                    datatable-cell.text-right(name='price')
                        span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                        span  { parseInt(row.price).toFixed(2) }
                        span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
                    datatable-cell(name='note') { row.note }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'Delivery'
        self.handlers = {}

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'code', value: 'Тип'},
            {name: 'period', value: 'Период'},
            {name: 'price', value: 'Цена'},
            {name: 'note', value: 'Примечание'},
        ]

        self.on('mount', () => {
            API.request({
                object: 'DeliveryType',
                method: 'Fetch',
                success(response) {
                    self.handlers.types = {}
                    response.items.forEach(item => {
                        self.handlers.types[item.id] = {
                            code: item.code,
                            name: item.name
                        }
                    })
                },
                error(response) {
                    self.handlers.types = {}
                },
                complete() {
                    self.update()
                }
            })
        })