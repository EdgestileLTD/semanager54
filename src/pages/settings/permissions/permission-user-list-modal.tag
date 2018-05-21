permission-user-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Менеджеры
        #{'yield'}(to="body")
            catalog(object='PermissionUser', cols='{ parent.cols }', search='true', reload='false',
            dblclick='{ parent.opts.submit.bind(this) }', disable-col-select='1')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='lastName') { row.lastName } { row.firstName } { row.secName }
                    datatable-cell(name='roles') { row.roles }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'lastName', value: 'Ф.И.О'},
            {name: 'roles', value: 'Роль'}
        ]

