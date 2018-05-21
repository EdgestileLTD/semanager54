sms-templates
    catalog(search='true', sortable='true', object='SmsTemplate', cols='{ cols }', reload='true',
    add='{ permission(add, "settings", "0100") }',
    remove='{ permission(remove, "settings", "0001") }',
    dblclick='{ permission(open, "settings", "1000") }',
    store='sms-templates')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='code') { row.code }
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.mixin('permissions')

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'code', value: 'Код'},
            {name: 'name', value: 'Наименование'},
        ]

        self.add = () => {
            riot.route(`/settings/sms/new`)
        }

        self.open = e => {
            riot.route(`/settings/sms/${e.item.row.id}`)
        }

        observable.on('sms-reload', () => self.tags.catalog.reload())
