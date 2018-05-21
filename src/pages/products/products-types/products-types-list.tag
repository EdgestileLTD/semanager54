| import 'components/catalog.tag'
| import truncate from 'lodash/truncate'
| import './products-types-edit-modal.tag'

products-types-list
    catalog(
        object    = 'ProductType',
        cols      = '{ cols }',
        search    = 'true',
        reorder   = 'true',
        handlers  = '{ handlers }',
        allselect = 'true',
        reload    = 'true',
        store     = 'products-types-list',
        add       = '{ permission(addEdit, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(addEdit, "products", "1010") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='features') { handlers.truncate(row.features, {length: 75}) }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'ProductType'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'features', value: 'Параметры'},
        ]

        self.addEdit = e => {
            let id
            if (e && e.item && e.item.row)
                id = e.item.row.id

            modals.create('products-types-edit-modal', {
                type: 'modal-primary',
                id,
                submit() {
                    let _this = this

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'ProductType',
                            method: 'Save',
                            data: _this.item,
                            success(response) {
                                popups.create({title: 'Успех!', text: 'Тип продукта сохранен!', style: 'popup-success'})
                                observable.trigger('products-types-list-reload')
                                if (!id)
                                    _this.modalHide()
                            },
                        })
                    }
                }
            })
        }

        observable.on('products-types-list-reload', () => self.tags.catalog.reload())

        self.handlers = {truncate}

