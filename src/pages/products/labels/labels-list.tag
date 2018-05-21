| import 'components/catalog.tag'

labels-list
    catalog(
        object    = 'ProductLabel',
        cols      = '{ cols }',
        search    = 'true',
        reorder   = 'true',
        handlers  = '{ handlers }',
        allselect = 'true',
        reload    = 'true',
        store     = 'products-labels-list',
        add       = '{ permissiallselect = "true",on(add, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(edit, "products", "1010") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='imageUrlPreview')
                img(src='{ row.imageUrlPreview }', alt='', width='32', height='32')
            datatable-cell(name='code') { row.code }
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'ProductLabel'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'imageUrlPreview', value: 'Иконка'},
            {name: 'code', value: 'Код'},
            {name: 'name', value: 'Наименование'},
        ]

        self.add = () => riot.route('/products/labels/new')

        self.edit = e => riot.route(`products/labels/${e.item.row.id}`)

        observable.on('products-labels-reload', () => self.tags.catalog.reload())