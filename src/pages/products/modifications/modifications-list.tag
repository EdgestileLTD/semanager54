modifications-list
    catalog(
        object    = 'Modification',
        cols      = '{ cols }',
        allselect = 'true',
        reload    = 'true',
        handlers  = '{ handlers }',
        store     = 'modifications-list',
        add       = '{ permission(add, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(open, "products", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='vtype') { handlers.types[row.vtype] }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Modification'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'vtype', value: 'Тип ценообразования'},
        ]

        self.handlers = {
            types: {
                "0": 'Добавляет к цене',
                "1": 'Умножает на цену',
                "2": 'Замещает цену',
            }
        }

        self.add = () => {
            riot.route(`products/modifications/new`)
        }

        self.open = e => {
            riot.route(`products/modifications/${e.item.row.id}`)
        }

        observable.on('modifications-reload', () => self.tags.catalog.reload())