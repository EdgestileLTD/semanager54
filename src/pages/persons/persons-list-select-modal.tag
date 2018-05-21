persons-list-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Контакты
        #{'yield'}(to="body")
            catalog(
                object             = 'Contact',
                cols               = '{ parent.cols }',
                search             = 'true',
                reload             = 'false',
                dblclick           = '{ parent.opts.submit.bind(this) }',
                disable-col-select = '1'
                exception          = '{ parent.opts.id }',
            )
                #{'yield'}(to='body')
                    datatable-cell(name = 'id') { row.id }
                    datatable-cell(name = 'displayName') { row.displayName }
                    datatable-cell(name = 'username') { row.username }
        #{'yield'}(to='footer')
            button(
                onclick = '{ modalHide }',
                type    = 'button',
                class   = 'btn btn-default btn-embossed'
            ) Закрыть
            button(
                onclick = '{ parent.opts.submit.bind(this) }',
                type    = 'button',
                class   = 'btn btn-primary btn-embossed'
            ) Выбрать

    script(type='text/babel').
        var self = this

        self.item = {}

        self.cols = [
            {name: 'id',          value: '#'},
            {name: 'displayName', value: 'Ф.И.О'},
            {name: 'username',    value: 'Логин'}
        ]

        self.submit = () => {
            let items = this.tags.datatable.getSelectedRows()
            if (!items.length) return
            self.item.idAuthor  = items[0].id
            self.item.customer  = items[0].displayName
            self.item.idCompany = null
            opts.submit.bind(this)()
        }



