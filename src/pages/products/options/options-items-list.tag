| import 'components/catalog.tag'
| import 'pages/products/options/optionitem-edit-modal.tag'

options-items-list
    catalog(
        name      = 'optionItem',
        object    = 'OptionItems',
        cols      = '{ cols }',
        search    = 'true',
        allselect = 'true',
        reorder   = 'true',
        handlers  = '{ handlers }',
        reload    = 'true', store='parameters-list',
        filters   = '{ opts.filters }',
        add       = '{ permission(addItem, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(editItem, "products", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='image')
                img(if='{ row.imageUrlPreview.trim() !== "" }', src='{ row.imageUrlPreview }')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='price')
                span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                span  { row.price.toFixed(2) }
                span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
            datatable-cell(name='nameOption') { row.nameOption }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'OptionItems'

        self.addItem = () => {
            modals.create('optionitem-edit-modal', {
                type: 'modal-primary',
                submit() {
                var _this = this
                var params = _this.item
                _this.error = _this.validation.validate(_this.item, _this.rules)

                if (!_this.error) {
                        API.request({
                            object: 'OptionItems',
                            method: 'Save',
                            data: params,
                            success(response) {
                                self.tags['optionItem'].reload();
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

        self.editItem = e => {
            let item

            if (e.item && e.item.row)
            item = e.item.row
            modals.create('optionitem-edit-modal', {
                type: 'modal-primary',
                item: item,
                submit() {
                    var _this = this
                    var params = _this.item
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'OptionItems',
                            method: 'Save',
                            data: params,
                            success(response) {
                                self.tags['optionItem'].reload();
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

        self.cols = [
            {name: 'image', value: 'Фото'},
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'measure', value: 'Цена'},
            {name: 'nameOption', value: 'Опция'},
        ]


        self.one('updated', () => {
            self.tags['optionItem'].tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags['optionItem'].pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags['optionItem'].items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'OptionItems',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })