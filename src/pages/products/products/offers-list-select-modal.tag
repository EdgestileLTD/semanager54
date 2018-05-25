offers-list-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Торговые предложения
        #{'yield'}(to="body")
            catalog(object='Offer', cols='{ parent.cols }', search='true', reload='true', sortable='true')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='article') { row.article }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='price') { (row.price / 1).toFixed(2) }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'article', value: 'Артикул'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
        ]

