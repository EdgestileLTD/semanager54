pay-systems
    catalog(object='PaySystem', cols='{ cols }', reload='true',
    add='{ permission(add, "paysystems", "0100") }',
    remove='{ permission(remove, "paysystems", "0001") }',
    dblclick='{ permission(paySystemOpen, "paysystems", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='imageFile')
                img(if='{ row.imageUrlPreview.trim() !== "" }', src='{ row.imageUrlPreview }')
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'PaySystem'

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'imageFile', value: 'Картинка' },
            { name: 'name', value: 'Наименование'},
        ]

        self.add = () => riot.route('/settings/pay-systems/new')

        self.paySystemOpen = (e) => riot.route(`settings/pay-systems/${e.item.row.id}`)

        observable.on('pay-systems-reload', () => {
            self.tags.catalog.reload()
        })