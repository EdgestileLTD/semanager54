| import 'pages/products/products/products-list-select-modal.tag'


specials-list
    catalog(search='true', sortable='true', object='SpecialOffer', cols='{ cols }',
    add='{ permission(add, "products", "0100") }',
    remove='{ permission(remove, "products", "0001") }',
    dblclick='{ permission(open, "products", "1000") }',
    handlers='{ handlers }', reload='true', store='specials-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='article') { row.article }
            datatable-cell(name='name') { row.name }
            datatable-cell.text-right(name='price')
                span { (row.price / 1).toFixed(2) }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'SpecialOffer'

        self.cols = [
            { name:'id', value:'#'},
            { name:'article', value:'Артикул'},
            { name:'name', value:'Наименование'},
            { name:'price', value:'Цена'}
        ]

        observable.on('special-reload', () => {
            self.tags.catalog.reload()
        })

        self.open = e => riot.route(`/products/${e.item.row.id}`)

        self.add = () => {
            modals.create('products-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let _this = this
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    let ids = items.map(item => item.id)

                    API.request({
                        object: 'SpecialOffer',
                        method: 'Save',
                        data: {ids},
                        success() {
                            observable.trigger('special-reload')
                            _this.modalHide()
                        }
                    })
                }
            })
        }