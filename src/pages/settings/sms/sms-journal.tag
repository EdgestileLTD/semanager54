sms-journal
    catalog(search='true', sortable='true', object='SmsLog', cols='{ cols }', reload='true', store='sms-log')
        #{'yield'}(to='body')
            datatable-cell(name='date') { row.date }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='userName') { row.userName }
            datatable-cell(name='text') { row.text }
            datatable-cell(name='cost') { row.cost }
            datatable-cell(name='count') { row.count }
            datatable-cell(name='provider') { row.provider }
            datatable-cell(name='status') { row.status }

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'date', value: 'Время'},
            {name: 'phone', value: 'Телефон'},
            {name: 'userName', value: 'Пользователь'},
            {name: 'text', value: 'Текст'},
            {name: 'cost', value: 'Стоимость'},
            {name: 'count', value: 'Кол-во'},
            {name: 'provider', value: 'Провайдер'},
            {name: 'status', value: 'Статус'},
        ]

        observable.on('sms-reload', () => self.tags.catalog.reload())