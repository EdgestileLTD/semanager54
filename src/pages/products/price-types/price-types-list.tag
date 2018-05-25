| import 'components/catalog.tag'

price-types-list

    catalog(
    search    = 'true',
    sortable  = 'true',
    object    = 'PriceType',
    cols      = '{ cols }',
    reorder   = 'true',
    allselect = 'true',
    reload    = 'true',
    store     = 'price-types-list',
    add       = '{ permission(add, "products", "0100") }',
    remove    = '{ permission(remove, "products", "0001") }',
    dblclick  = '{ permission(priceTypeOpen, "products", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='code') { row.code }
            datatable-cell(name='name') { row.name }

    style(scoped).
        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'PriceType'

        self.cols = [
            {name: 'id', value: '#', width: '50px'},
            {name: 'code', value: 'Код' },
            {name: 'name', value: 'Наименование' },
        ]

        self.add = () => riot.route('/products/price-types/new')

        self.priceTypeOpen = e => {
            riot.route(`/products/price-types/${e.item.row.id}`)
        }

        self.one('updated', () => {
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'Warehouse',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })

        observable.on('price-types-reload', () => {
            self.tags.catalog.reload()
        })