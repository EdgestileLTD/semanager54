
modifications-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Модификации товара
        #{'yield'}(to="body")
            catalog-static(cols='{ parent.cols }', rows='{ parent.rows }', remove='true', dblclick='{ parent.opts.submit.bind(this) }')
                #{'yield'}(to='body')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='count') { row.count }
                    datatable-cell(name='price') { row.price }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this
        self.rows = []

        self.cols = [
            {name: 'name', value: 'Наименование'},
            {name: 'count', value: 'Кол-во'},
            {name: 'price', value: 'Цена'},
        ]

        self.on('update', () => {

        })

        self.on('mount', () => {
            self.loader = true
            API.request({
                object: 'Product',
                method: 'Info',
                data: {id: [opts.id]},
                notFoundRedirect: false,
                success(response) {
                    let name = response.name
                    let modifications = response.modifications

                    self.rows = []

                    if (modifications.length > 0) {
                        modifications.forEach(item => {
                            let _item = item
                            let count = item.columns.length
                            let names = item.columns.map(i => i.name)

                            if ('items' in item &&
                                item.items instanceof Array &&
                                item.items.length > 0) {

                                item.items.forEach(item => {
                                    item.price = item.priceRetail
                                    if (item.count == -1)
                                        item.count = null;
                                    let namesValues = item.values.map(i => i.value)
                                    let row = names.map((item, i) => `${item}: ${namesValues[i]}`)
                                    let value = `${name} (${row.join(', ')})`
                                    self.rows.push({...item, name: value})
                                })
                            }
                        })
                    }
                    self.loader = false
                    self.update()
                }
            })
        })