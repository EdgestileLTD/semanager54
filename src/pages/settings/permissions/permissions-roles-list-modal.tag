permissions-roles-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Роли
        #{'yield'}(to="body")
            catalog(object='PermissionRole', cols='{ cols }', disable-col-select='true',
            dblclick='{ parent.opts.submit.bind(this) }', disable-limit='true')
                #{'yield'}(to='body')
                    datatable-cell(name='name' ) { row.name }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            self.tags['bs-modal'].cols = [
                {name: 'name', value: 'Наименование'}
            ]
        })