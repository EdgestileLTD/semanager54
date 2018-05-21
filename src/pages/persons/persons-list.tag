| import 'components/catalog.tag'
| import 'pages/persons/person-new-modal.tag'
| import 'pages/persons/persons-category-select-modal.tag'

persons-list

    .col-md-3.hidden-xs.hidden-sm
        catalog-tree(object='ContactCategory', label-field='{ "name" }', children-field='{ "childs" }',
        reload='true', descendants='true')
    .col-md-9.col-xs-12.col-sm-12
        catalog(
            search    = 'true',
            sortable  = 'true',
            object    = 'Contact',
            cols      = '{ cols }',
            allselect = 'true',
            reload    = 'true',
            add       = '{ permission(add, "contacts", "0100") }',
            remove    = '{ permission(remove, "contacts", "0001") }',
            handlers  = '{ handlers }',
            dblclick  = '{ permission(personOpen, "contacts", "1000") }',
            store     = 'persons-list',
            filters   = '{ allFilters }'
        )
            #{'yield'}(to='body')
                datatable-cell.text-right(name='id') { row.id }
                datatable-cell.text-right(name='regDate') { row.regDate }
                datatable-cell(name='displayName') { row.displayName }
                datatable-cell(name='company') { row.company }
                datatable-cell(name='username') { row.username }
                datatable-cell(name='email') { row.email }
                datatable-cell(name='phone') { row.phone }
                datatable-cell.text-right(name='countOrders') { row.countOrders }
                datatable-cell.text-right(name='amountOrders')
                    span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                    span  { (row.amountOrders / 1).toFixed(2) }/{ (row.paidOrders / 1).toFixed(2) }
                    span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
                datatable-cell(name='priceType') { row.priceType == 0 ? 'Розничная' : '' || row.priceType == 1 ? 'Корпоративная' : '' || row.priceType == 2 ? 'Оптовая' : '' }


            #{'yield'}(to='head')
                .dropdown(if='{ checkPermission("contacts", "0010") && selectedCount > 0 }', style='display: inline-block;')
                    button.btn.btn-default.dropdown-toggle(data-toggle="dropdown", aria-haspopup="true", type='button', aria-expanded="true")
                        | Действия&nbsp;
                        span.caret
                    ul.dropdown-menu
                        li(onclick='{ handlers.addCategory }', class='{ disabled: selectedCount < 2 }')
                            a(href='#')
                                i.fa.fa-fw
                                |  Добавить в группы
                        li(onclick='{ handlers.setCategory }', class='{ disabled: selectedCount < 2 }')
                            a(href='#')
                                i.fa.fa-fw
                                |  Переопределить группы

                button.btn.btn-primary(if='{ selectedCount == 1 }',  onclick='{ parent.exportCard }' title='Карточка контакта (XLS)', type='button')
                    i.fa.fa-file-excel-o(aria-hidden="true")
                button.btn.btn-primary(type='button', onclick='{ parent.exportPersons }', title='Экспорт')
                    i.fa.fa-upload
                .btn.btn-file.btn-primary
                    input(id="importFile", type='file', onchange='{ parent.importPersons }', title='Импорт')
                    i.fa.fa-download
            #{'yield'}(to='filters')
                .well.well-sm
                    .form-inline
                        .form-group.col-sm-12.hidden-lg.hidden-md
                            label.control-label Группа
                            select.form-control(data-name='idGroup', data-sign='IN')
                                option(value='') Все
                                option(each='{ category, i in parent.categories }', value='{ category.id }', no-reorder) { category.name }
                        .form-group
                            label.control-label Менеджер
                            select.form-control(data-name='managerId', data-sign='IN')
                                option(value='') Все
                                option(each='{ manager, i in parent.managers }', value='{ manager.id }', no-reorder) { manager.title }
                        .form-group
                            label.control-label Статус
                            select.form-control(onchange='{ parent.change }')
                                option(value='') Все цены
                                option(value='0') Розничные
                                option(value='1') Корпоративные
                                option(value='2') Оптовые

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Contact'
        self.categoryFilters = false
        self.typeFilters = false
        self.allFilters = false
        self.managers = {}

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'regDate', value: 'Дата рег.'},
            {name: 'displayName', value: 'Ф.И.О'},
            {name: 'company', value: 'Компания'},
            {name: 'username', value: 'Логин'},
            {name: 'email', value: 'E-mail'},
            {name: 'phone', value: 'Телефоны'},
            {name: 'countOrders', value: 'Кол-во зак.'},
            {name: 'amountOrders', value: 'Сумма/оплач. зак.'},
            {name: 'priceType', value: 'Тип цены'},
        ]

        self.handlers = {
            addCategory(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id)

                modals.create('persons-category-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    let groups = []
                    if (items.length > 0) {
                        items.forEach(item => {
                                if (groups.indexOf(item.id) === -1) {
                                groups.push({ id: item.id, name: item.name })
                                }
                                })

                        let params = { ids, add: true, groups: groups }
                        API.request({
                        object: 'Contact',
                        method: 'Save',
                        data: params,
                        success(response) {
                        self.tags.catalog.reload()
                        }
                        })
                }
                self.update()
                this.modalHide()
                }
                })
            },
            setCategory(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id)

                modals.create('persons-category-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags.catalog.tags.datatable.getSelectedRows()
                        let groups = []
                        if (items.length > 0) {
                            items.forEach(item => {
                                if (groups.indexOf(item.id) === -1) {
                                    groups.push({ id: item.id, name: item.name })
                                }
                            })

                            let params = { ids, upd: true, groups: groups }
                            API.request({
                                object: 'Contact',
                                method: 'Save',
                                data: params,
                                success(response) {
                                    self.tags.catalog.reload()
                                }
                            })
                        }
                        self.update()
                        this.modalHide()
                    }
                })
            },
        }

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



        self.add = function () {
            modals.create('person-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = { firstName: _this.name.value, email: _this.email.value }
                    API.request({
                        object: 'Contact',
                        method: 'Save',
                        data: params,
                        success(response, xhr) {
                            popups.create({title: 'Успех!', text: 'Контакт добавлен!', style: 'popup-success'})
                            _this.modalHide()
                            self.tags.catalog.reload()
                            if (response && response.id)
                                self.personOpenItem(response.id)
                        }
                    })
                }
            })
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
                    self.tags.catalog.reload();
                }
            })
            $("#importFile").val(undefined)
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

        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {
                self.getContactCategory()
            })
            self.tags['catalog-tree'].tags.treeview.on('nodeselect', node => {
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
            })
        })

        self.getContactCategory()
        self.getManagers()

        observable.on('persons-reload', () => self.tags.catalog.reload())