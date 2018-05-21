new-categories-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Категории новостей
        #{'yield'}(to="body")
            catalog(object='NewsCategory', cols='{ parent.cols }', dblclick='{ parent.opts.submit.bind(this) }', reload='true')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='title') { row.title }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'title', value: 'Наименование'},
        ]