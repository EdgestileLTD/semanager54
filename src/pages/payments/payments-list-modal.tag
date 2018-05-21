payments-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Контакты
        #{'yield'}(to="body")
            catalog(object='Payment', cols='{ parent.cols }', search='true', reload='false',
            dblclick='{ parent.opts.submit.bind(this) }', disable-col-select='true')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='num') { row.num }
                    datatable-cell(name='date') { row.date }
                    datatable-cell(name='paymentTarget') { row.paymentTarget ? 'Пополнение счёта' : 'Оплата заказа'  }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='payer') { row.payer }
                    datatable-cell(name='amount') { row.amount }
                    datatable-cell(name='idOrder') { row.idOrder }
                    datatable-cell(name='note') { row.note }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'num', value: '№'},
            {name: 'date', value: 'Дата'},
            {name: 'paymentTarget', value: 'Назначение'},
            {name: 'name', value: 'Наименование'},
            {name: 'payer', value: 'Плательщик'},
            {name: 'amount', value: 'Сумма'},
            {name: 'idOrder', value: '№ заказа'},
            {name: 'note', value: 'Примечание'}
        ]

