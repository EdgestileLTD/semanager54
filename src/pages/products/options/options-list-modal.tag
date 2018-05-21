options-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Опций
        #{'yield'}(to="body")
            catalog(
                object             = 'FeatureGroup',
                cols               = '{ parent.cols }',
                search             = 'true',
                remove             = '{ parent.remove }',
                reload             = 'true',
                disable-col-select = 'true',
                dblclick           = '{ parent.opts.submit.bind(this) }'
            )
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'Option'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]