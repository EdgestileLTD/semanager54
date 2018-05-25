| import 'components/catalog.tag'
| import 'modals/import-products-modal.tag'
| import 'pages/products/products/product-new-modal.tag'
| import 'pages/products/groups/groups-list.tag'
| import './markup-modal.tag'
| import './price-modal.tag'
| import './product-edit-modifications-modal.tag'
| import './product-edit-parameters-modal.tag'

products-list
    .row
        .col-md-2.hidden-xs.hidden-sm
            catalog-tree(object='Category', label-field='{ "name" }', children-field='{ "childs" }',
            reload='true', descendants='true')
        .col-md-10.col-xs-12.col-sm-12
            catalog(search='true', sortable='true', object='Product', cols='{ cols }', combine-filters='true'
            add='{ permission(add, "products", "0100") }',
            remove='{ permission(remove, "products", "0001") }',
            dblclick='{ permission(productOpen, "products", "1000") }',
            handlers='{ handlers }',  reload='true', store='products-list', filters='{ categoryFilters }')
                #{'yield'}(to='filters')
                    .well.well-sm
                        .form-inline
                            .form-group
                                label.control-label Бренды
                                select.form-control(data-name='idBrand', onchange='{ parent.selectBrand }')
                                    option(value='') Все
                                    option(each='{ brand, i in parent.brands }', value='{ brand.id }', no-reorder) { brand.name }

                #{'yield'}(to='head')
                    .dropdown(if='{ checkPermission("products", "0010") && selectedCount > 0 }', style='display: inline-block;')
                        button.btn.btn-default.dropdown-toggle(data-toggle="dropdown", aria-haspopup="true", type='button', aria-expanded="true")
                            | Действия&nbsp;
                            span.caret
                        ul.dropdown-menu
                            li(onclick='{ handlers.multiEdit }', class='{ disabled: selectedCount < 2 }')
                                a(href='#')
                                    i.fa.fa-fw.fa-pencil
                                    |  Мультиредактирование товаров
                            li(onclick='{ handlers.cloneProduct }', class='{ disabled: selectedCount > 1 }')
                                a(href='#')
                                    i.fa.fa-fw.fa-clone
                                    |  Клонирование товара
                            li.divider
                            li(onclick='{ handlers.toggleSelected }')
                                a(href='#', data-field='isActive')
                                    i.fa.fa-fw.fa-eye
                                    |  Видимость (вкл/выкл)
                            li.divider
                            li(onclick='{ handlers.setCategory }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Переопределить категорию
                            li(onclick='{ handlers.setModifications }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Назначить модификации
                            li(onclick='{ handlers.setFeatures }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Назначить спецификации
                            li(onclick='{ handlers.setBrand }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Назначить бренд
                            li.divider
                            li(onclick='{ handlers.setPrice }')
                                a(href='#')
                                    i.fa.fa-fw.fa-money
                                    |  Задать цены
                            li(onclick='{ handlers.setMarkup }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Произвести наценку
                    #{'yield'}(to='head')
                        //button.btn.btn-primary(type='button', onclick='{ parent.exportProducts }', title='Экспорт')
                        //    i.fa.fa-upload
                        button.btn.btn-primary(if='{ checkPermission("products", "0111") }',
                        type='button', onclick='{ parent.importProducts }', title='Импорт')
                            i.fa.fa-download

                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='imageUrlPreview')
                        img(src='{ row.imageUrlPreview }', alt='', width='32', height='32')
                    datatable-cell(name='enabled')
                        button.btn.btn-default.btn-sm(type='button',
                        onclick='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchend='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchstart='{ stopPropagation }',
                        disabled='{ !handlers.checkPermission("products", "0010") }')
                            i(class='fa { row.enabled == "Y" ? "fa-eye" : "fa-eye-slash text-muted" } ')
                    datatable-cell(name='article') { row.article }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='nameBrand') { row.nameBrand }
                    datatable-cell(name='price')
                        span { (row.price / 1).toFixed(2) }
                    datatable-cell(name='count') { row.countDisplay }
                    datatable-cell(name='nameGroup') { row.nameGroup }

    style(scoped).
        :scope {
            display: block;
            position: relative;
        }

        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Product'
        self.brands = []
        self.categoryFilters = false

        self.add = e => {
            modals.create('product-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = {
                        name: this.name.value,
                        idGroup: self.selectedCategory,
                        idBrand: self.selectedBrand
                    }

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Product',
                            method: 'Save',
                            data: params,
                            success(response, xhr) {
                                popups.create({title: 'Успех!', text: 'Товар добавлен!', style: 'popup-success'})
                                _this.modalHide()
                                self.tags.catalog.reload()
                                if (response && response.id)
                                    riot.route(`/products/${response.id}`)
                            }
                        })
                    }
                }
            })
        }

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'imageUrlPreview', value: ''},
            { name: 'enabled', value: 'Вид'},
            { name: 'article', value: 'Артикул'},
            { name: 'name', value: 'Наименование'},
            { name: 'nameBrand', value: 'Бренд'},
            { name: 'price', value: 'Цена'},
            { name: 'count', value: 'Остаток'},
            { name: 'nameGroup', value: 'Группа'},
        ]


        self.handlers = {
            checkPermission: self.checkPermission,
            permission: self.permission,
            boolChange(e) {
                var _this = this
                e.stopPropagation()
                e.stopImmediatePropagation()
                _this.row[_this.opts.name] = _this.row[_this.opts.name] === 'Y' ? 'N' : 'Y'
                self.update()

                var params = {}
                params.id = _this.row.id
                params[_this.opts.name] = _this.row[_this.opts.name]

                API.request({
                    object: 'Product',
                    method: 'Save',
                    data: params,
                    error(response) {
                        _this.row[_this.opts.name] = _this.row[_this.opts.name] === 'Y' ? 'N' : 'Y'
                        self.update()
                    }
                })
            },
            toggleSelected(e) {
                let field = e.target.getAttribute('data-field')

                let oldValues = {}
                let rows = this.tags.datatable.getSelectedRows()
                let ids = rows.map(item => item.id)
                let newValue = rows[0][field] === 'Y' ? 'N' : 'Y'

                let params = { ids, [field]: newValue }

                rows.forEach(item => {
                    oldValues[item.id] = { [field]: item[field] }
                    item[field] = newValue
                })

                API.request({
                    object: 'Product',
                    method: 'Save',
                    data: params,
                    error(response) {
                        rows.forEach(item => {
                            item[field] = oldValues[item.id][field]
                        })

                        self.update()
                    }
                })
            },
            multiEdit(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id).join(',')
                riot.route(`/products/multi?ids=${ids}`)
            },
            cloneProduct(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id).join(',')
                riot.route(`/products/clone?id=${ids}`)
            },
            setCategory(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id)

                modals.create('group-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()

                        if (items.length > 0) {
                            let params = { ids, idGroup: items[0].id }

                            API.request({
                                object: 'Product',
                                method: 'Save',
                                data: params,
                                success(response) {
                                    self.tags.catalog.reload()
                                }
                            })

                            self.update()
                            this.modalHide()
                        }
                    }
                })
            },
            setModifications(e) {
                let items = this.tags.datatable.getSelectedRows()
                let ids = items.map(item => item.id)

                API.request({
                    object: 'Product',
                    method: 'Info',
                    data: { id: items[0].id },
                    success(response) {
                        let modifications = response.modifications

                        modals.create('product-edit-modifications-modal', {
                            type: 'modal-primary',
                            size: 'modal-lg',
                            modifications,
                            submit() {
                                let _this = this
                                let params = { ids, ...this.item }

                                API.request({
                                    object: 'Product',
                                    method: 'Save',
                                    data: params,
                                    success(response) {
                                        _this.modalHide()
                                        self.tags.catalog.reload()
                                    }
                                })
                            }
                        })
                    }
                })
            },
            setFeatures(e) {
                let items = this.tags.datatable.getSelectedRows()
                let ids = items.map(item => item.id)
                let specifications = []

                modals.create('product-edit-parameters-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    specifications,
                    submit() {
                        let _this = this
                        let isAddSpecifications = _this.isAddSpecifications
                        let params = { ids, ...this.item, isAddSpecifications: parseInt(isAddSpecifications) }

                        API.request({
                            object: 'Product',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                })

            },
            setBrand(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id)

                modals.create('brands-list-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags.catalog.tags.datatable.getSelectedRows()

                        let params = { ids, brand: { id: items[0].id, name: items[0].name }}

                        API.request({
                            object: 'Product',
                            method: 'Save',
                            data: params,
                            success(response) {
                                self.tags.catalog.reload()
                            }
                        })

                        self.update()
                        this.modalHide()
                    }
                })
            },
            setPrice(e) {
                let items = self.tags.catalog.tags.datatable.getSelectedRows()
                let price = items[0].price

                modals.create('price-modal', {
                    type: 'modal-primary',
                    price,
                    submit() {
                        let _this = this
                        let item = this.item
                        let ids = items.map(item => item.id)
                        let params = { ids, ...item}

                        API.request({
                            object: 'Product',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                })
            },
            setMarkup(e) {
                modals.create('markup-modal', {
                    type: 'modal-primary',
                    submit() {
                        let _this = this
                        let item = this.item
                        let items = self.tags.catalog.tags.datatable.getSelectedRows()
                        let ids = items.map(item => item.id)
                        let params = { ids, ...item}

                        API.request({
                            object: 'Product',
                            method: 'AddPrice',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                })
            }
        }

        self.productOpen = e => riot.route(`/products/${e.item.row.id}`)

        self.getBrands = () => {
            let data = { sortBy: "name", sortOrder: "asc", limit: 1000 }
            API.request({
                object: 'Brand',
                data: data,
                method: 'Fetch',
                success(response) {
                    self.brands = response.items
                    self.update()
                }
            })
        }

        self.getLabels = () => {
            let data = { sortBy: "id", sortOrder: "asc", limit: 1000 }
            API.request({
                object: 'ProductLabel',
                data: data,
                method: 'Fetch',
                success(response) {
                    self.labels = response.items
                    self.update()
                }
            })
        }

        self.selectBrand = e => {
            self.selectedBrand = e.target.value || undefined
        }

        observable.on('products-reload', () => {
           // self.tags.catalog.reload()
        })

        observable.on('categories-reload', () => {
            self.tags['catalog-tree'].reload()
        })

        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {
                self.getBrands()
                self.getLabels()
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
                self.update()
                self.tags.catalog.reload()
            })
        })

        self.importProducts = () => riot.route(`/import`)

        self.exportProducts = () => {
            API.request({
                object: 'Product',
                method: 'Export',
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


        self.getBrands()
        self.getLabels()