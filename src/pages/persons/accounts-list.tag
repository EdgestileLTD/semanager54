| import 'components/catalog.tag'
| import 'pages/persons/person-new-modal.tag'

accounts-list
    .col-md-12
        catalog(search='true', sortable='true', object='UserAccount', handlers='{ handlers }', cols='{ cols }', reload='true',
        before-success='{ getAggregation }',
        dblclick='{ permission(personOpen, "contacts", "1000") }', store='accounts-list', filters='{ allFilters }')
            #{'yield'}(to='body')
                datatable-cell(name='id') { row.id }
                datatable-cell(name='name') { row.name }
                datatable-cell.text-right(name='inPay')
                    span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                    span  { row.inPay.toFixed(2) }
                    span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
                datatable-cell.text-right(name='outPay')
                    span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                    span  { row.outPay.toFixed(2) }
                    span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }


            #{'yield'}(to='head')
                button.btn.btn-primary(onclick='{ parent.exportAccount }' title='Экспорт списка (XLS)', type='button')
                    i.fa.fa-file-excel-o(aria-hidden="true")
            #{'yield'}(to='filters')
                .well.well-sm
                    .form-inline.row
                        .form-group.col-sm-3
                            label.control-label От даты
                            datetime-picker.form-control(data-name='datePayee', data-sign='>=', format='YYYY-MM-DD', value='{ parent.startDate }')
                        .form-group.col-sm-3
                            label.control-label До даты
                            datetime-picker.form-control(data-name='datePayee', data-sign='<=', format='YYYY-MM-DD', value='{ parent.endDate }')

                        .form-group.col-sm-6
                            label.control-label Тип
                            select.form-control(data-name='isBonus')
                                option(value='') Все
                                option(value='1') Только бонусы
            #{'yield'}(to='aggregation')
                strong  Начислено:
                strong  {parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? parent.currTotal.nameFront : ""}
                strong  { (parent.totalInPay || 0).toFixed(2) +  " " }
                strong  { parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? "" : parent.currTotal.nameFlang !== null && parent.currTotal.nameFlang !== "" ? parent.currTotal.nameFlang : parent.currTotal.titleCurr }
                strong  Списано:
                strong  {parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? parent.currTotal.nameFront : ""}
                strong  { (parent.totalOutPay || 0).toFixed(2) +  " " }
                strong  { parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? "" : parent.currTotal.nameFlang !== null && parent.currTotal.nameFlang !== "" ? parent.currTotal.nameFlang : parent.currTotal.titleCurr }
                strong  Остаток:
                strong  {parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? parent.currTotal.nameFront : ""}
                strong  { (parent.totalBalansePay || 0).toFixed(2) +  " " }
                strong  { parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? "" : parent.currTotal.nameFlang !== null && parent.currTotal.nameFlang !== "" ? parent.currTotal.nameFlang : parent.currTotal.titleCurr }


    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'UserAccount'
        self.categoryFilters = false
        self.typeFilters = false
        self.allFilters = false
        self.managers = {}
        self.operations = []

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Ф.И.О'},
            {name: 'inPay', value: 'Начисление'},
            {name: 'outPay', value: 'Списание'}
        ]

        self.handlers = {
            params: {}
        }

        /*
        self.change = e => {
            var value = e.target.value
            if (value == '') {
                self.typeFilters = false
            } else {
                //var filter = {field: 'priceType', sign: 'IN', value: value}
                self.typeFilters = [{field: 'priceType', sign: 'IN', value: value}]
            }
            self.Filters()
        }
        */

        self.getAggregation = (response, xhr) => {
            self.totalInPay      = response.totalInPay
            self.totalOutPay     = response.totalOutPay
            self.totalBalansePay = response.totalBalansePay
            self.currTotal       = response.currTotal
        }

        self.Filters = () => {
            if (self.typeFilters && self.categoryFilters)
                self.allFilters = [...self.typeFilters, ...self.categoryFilters]
            else if (self.typeFilters)
                    self.allFilters = self.typeFilters
                else
                    self.allFilters = self.categoryFilters
            self.update()
            self.tags.catalog.reload()
        }

        self.personOpen = e => {
            riot.route(`/persons/${e.item.row.id}`)
        }

        /*
        self.personOpenItem = id => {
            riot.route(`/persons/${id}`)
        }

        self.importPersons = (e) => {
            var formData = new FormData();
            for (var i = 0; i < e.target.files.length; i++) {
                formData.append('file' + i, e.target.files[i], e.target.files[i].name)
            }

            API.upload({
                object: 'Contact',
                data: formData,
                success(response) {
                    self.update();
                }
            })
        }

        self.exportPersons = () => {
            var params = { filters: self.allFilters }
            API.request({
                object: 'Contact',
                method: 'Export',
                data: params,
                success(response, xhr) {
                    let a = document.createElement('a')
                    a.href = response.url
                    a.download = response.name
                    document.body.appendChild(a)
                    a.click()
                    a.remove()
                }
            })
        }

        self.exportCard = (e) => {
            var _this = this

            var rows = self.tags.catalog.tags.datatable.getSelectedRows()
            var params = { id: rows[0].id }

            API.request({
                object: 'Contact',
                method: 'Export',
                data: params,
                success(response, xhr) {
                    let a = document.createElement('a')
                    a.href = response.url
                    a.download = response.name
                    document.body.appendChild(a)
                    a.click()
                    a.remove()
                }
            })
        } */

        self.exportAccount = (e) => {
            var _this = this
            var params = self.handlers.params

            API.request({
                object: 'UserAccount',
                method: 'Export',
                data: params,
                success(response, xhr) {
                    let a = document.createElement('a')
                    a.href = response.url
                    a.download = response.name
                    document.body.appendChild(a)
                    a.click()
                    a.remove()
                }
            })
        }

        /* self.getOperations = () => {
            API.request({
                object: 'BankAccountTypeOperation',
                method: 'Fetch',
                success: (response, xhr) => {
                    self.operations = response.items
                    self.update()
                }
            })
        }


        self.getManagers = () => {
            self.managers = []
            API.request({
                object: 'PermissionUser',
                method: 'Fetch',
                success(response) {
                    self.managers = response.items
                    self.update()
                }
            })

        }

        self.getContactCategory = () => {
            self.categories = []
            API.request({
                object: 'ContactCategory',
                method: 'Fetch',
                success(response) {
                    for (var i = 0; i < response.items.length; i++) {
                        self.categories.push(response.items[i])
                        if (response.items[i].childs!== undefined) {
                            for (var ii = 0; ii < response.items[i].childs.length; ii++) {
                                self.categories.push(response.items[i].childs[ii])
                            }
                        }
                    }
                    self.update()
                }
            })
        }
        */

        self.one('updated', () => {
            /*self.tags['catalog-tree'].tags.treeview.on('nodeselect', node => {
                self.selectedCategory = node.__selected__ ? node.id : undefined
                let items = self.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.categoryFilters = [{field: 'idGroup', sign: 'IN', value}]
                    } else {
                    self.categoryFilters = false
                }
                self.Filters()

                //self.update()
                //self.tags.catalog.reload()
            })*/
        })

        //self.getContactCategory()
        //self.getManagers()
        //self.getOperations();

        observable.on('persons-reload', () => self.tags.catalog.reload())