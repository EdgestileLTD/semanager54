| import 'components/catalog.tag'

| import './brand-new-modal.tag'

brands-list

    catalog(
        search    = 'true',
        sortable  = 'true',
        object    = 'Brand',
        cols      = '{ cols }',
        reorder   = 'true',
        allselect = 'true',
        reload    = 'true',
        store     = 'brands-list',
        add       = '{ permission(add, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(brandOpen, "products", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='img')
                img(if='{ row.imageUrlPreview.trim() !== "" }', src='{ row.imageUrlPreview }', style='max-width: 200px;')
            datatable-cell(name='name') { row.name }
            datatable-cell(name='code') { row.code }

    style(scoped).
        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Brand'

        self.cols = [
            {name: 'id', value: '#', width: '50px'},
            {name: 'img', value: 'Логотип'},
            {name: 'name', value: 'Наименование' },
            {name: 'code', value: 'URL' },
        ]

        self.add = e => {
            modals.create('brand-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = {name: _this.name.value}
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Brand',
                            method: 'Save',
                            data: params,
                            success(response) {
                                popups.create({title: 'Успех!', text: 'Бренд добавлен!', style: 'popup-success'})
                                _this.modalHide()
                                observable.trigger('brands-reload')
                            }
                        })
                    }
                }
            })
        }


        self.brandOpen = e => {
            riot.route(`/products/brands/${e.item.row.id}`)
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
                    object: 'Brand',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })
                self.update()
            })
        })

        observable.on('brands-reload', () => {
            self.tags.catalog.reload()
        })