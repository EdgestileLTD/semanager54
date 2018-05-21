

accounts
    .row
        .col-sm-12
            catalog(object='ClientAccount', search='true', cols='{ cols }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='customer') { row.customer }
                    datatable-cell(name='email') { row.email }
                    datatable-cell(name='balance') { row.balance }


    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'customer', value: 'Пользователь'},
            {name: 'email', value: 'E-mail'},
            {name: 'balance', value: 'На счету'},
        ]
