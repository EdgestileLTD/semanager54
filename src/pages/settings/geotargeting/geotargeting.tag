geotargeting
    catalog(object='GeoTargeting', cols='{ cols }', reload='true',
    reorder='true', add='{ add }',
    remove='{ remove }',
    dblclick='{ edit }',
    disable-col-select='true', limit='1000')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='address') { row.address }
            datatable-cell(name='city') { row.city  }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='additionalPhones') { row.additionalPhones }
            datatable-cell(name='url') { row.url }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'GeoTargeting'
        self.handlers = {}

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'address', value: 'Адрес'},
            {name: 'city', value: 'Город'},
            {name: 'phone', value: 'Телефон'},
            {name: 'additionalPhones', value: 'Доп. телефоны'},
            {name: 'url', value: 'Домен'},
        ]

        self.add = () => riot.route('/settings/geotargeting/new')

        self.edit = e => riot.route(`settings/geotargeting/${e.item.row.id}`)

        observable.on('geotargeting-reload', () => {
            self.tags.catalog.reload()
        })


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
                    object: 'GeoTargeting',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })
                self.update()
            })
        })

