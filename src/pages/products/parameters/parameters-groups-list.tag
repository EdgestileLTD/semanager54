| import 'components/catalog.tag'
| import 'pages/products/parameters/parameter-group-new-modal.tag'

parameters-groups-list
    catalog(object='FeatureGroup', cols='{ cols }', search='true',
    add='{ permission(addEdit , "products", "0100") }',
    remove='{ permission(remove, "products", "0001") }',
    dblclick='{ permission(addEdit, "products", "1000") }',
    reorder='true', reload='true', store='parameters-groups-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='sort') { row.sort }
            datatable-cell(name='description') { row.description }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'FeatureGroup'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'sort', value: 'Индекс'},
            {name: 'description', value: 'Описание'},
        ]

        self.addEdit = e => {
            var id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            modals.create('parameter-group-new-modal', {
                type: 'modal-primary',
                id: id,
                submit() {
                    var _this = this
                    var params = _this.item

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'FeatureGroup',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                }
            })
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
                    object: 'FeatureGroup',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })

        observable.on('parameters-groups-reload', () => {
            self.tags.catalog.reload()
        })

