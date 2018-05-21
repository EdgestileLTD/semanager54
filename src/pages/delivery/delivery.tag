| import 'pages/delivery/delivery-new-modal.tag'

delivery
    catalog(
        object    = 'Delivery',
        cols      = '{ cols }',
        allselect = 'true',
        reload    = 'true',
        handlers  = '{ handlers }',
        add       = '{ permission(add, "deliveries", "0100") }',
        remove    = '{ permission(remove, "deliveries", "0001") }',
        dblclick  = '{ permission(dOpen, "deliveries", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='code') { handlers.types[row.code]}
            datatable-cell.text-right(name='period')
                span  { row.period != 0 ? row.period : ""  }
                span(style='color: #ccc') { row.period != 0 ? " дн." : ""  }
            datatable-cell.text-right(name='price')
                span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                span  { parseInt(row.price).toFixed(2) }
                span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
            datatable-cell(name='note') { row.note }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Delivery'
        self.handlers = {
            types:{
                simple:     'Простая доставка',
                region:     'Доставка по регионам',
                subregion:  'Доставка по регионам с подпункта',
                ems:        'EMS',
                post:       'Почта России',
                sdek:       'СДЭК'
            }
        }

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'code', value: 'Тип'},
            {name: 'period', value: 'Период'},
            {name: 'price', value: 'Цена'},
            {name: 'note', value: 'Примечание'},
        ]

        //self.add = () => riot.route('/products/delivery/new')

        self.add = (e) => {
            e.stopPropagation()

            var id, item
            if (e.item && e.item.id) {
                id = e.item.id
                item = e.item
            }

            modals.create('delivery-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (_this.name.value.toString().trim() != '' && !_this.error) {

                        var params
                        params = {name: _this.name.value, code: 'simple'}

                        API.request({
                            object: 'Delivery',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                //childs.push(response)
                                popups.create({
                                    title: 'Успех!',
                                    text: 'Доставка добавлена',
                                    style: 'popup-success'
                                })
                                self.update()
                                riot.route('/products/delivery/' + response.id)
                            }
                        })
                    }
                }
            })
        }


        self.dOpen = e => riot.route(`/products/delivery/${e.item.row.id}`)

        self.on('mount', () => {
            /*API.request({
                object: 'DeliveryType',
                method: 'Fetch',
                success(response) {
                    self.handlers.types = {}
                    response.items.forEach(item => {
                        self.handlers.types[item.id] = {
                            code: item.code,
                            name: item.name
                        }
                    })
                },
                error(response) {
                    self.handlers.types = {}
                },
                complete() {
                    self.update()
                }
            })*/
        })

        observable.on('delivery-reload', () => {
            self.tags.catalog.reload()
        })
