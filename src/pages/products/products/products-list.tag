| import 'components/catalog.tag'
| import 'modals/import-products-modal.tag'
| import 'modals/import-products-modal-continue.tag'
| import 'modals/export-products-modal.tag'
| import 'pages/products/products/product-new-modal.tag'
| import 'pages/products/groups/groups-list.tag'
| import './markup-modal.tag'
| import './price-modal.tag'
| import './product-edit-modifications-modal.tag'
| import './product-edit-parameters-modal.tag'


products-list
    .row
        // лист групп
        .col-md-3.hidden-xs.hidden-sm
            catalog-tree(
                object          = 'Category',
                label-field     = '{ "name" }',
                children-field  = '{ "childs" }',
                reload          = 'true',
                deselAll        = 'true',
                descendants     = 'true',
                handlers        = '{ handlersGroups }'
            )
        // заголовки каталога товаров
        .col-md-9.col-xs-12.col-sm-12
            catalog(
                search          = 'true',
                sortable        = 'true',
                object          = 'Product',
                cols            = '{ cols }',
                combine-filters = 'true',
                add             = '{ permission(add, "products", "0100") }',
                remove          = '{ permission(remove, "products", "0001") }',
                dblclick        = '{ permission(productOpen, "products", "1000") }',
                handlers        = '{ handlers }',
                allselect       = "true",
                reload          = 'true',
                store           = 'products-list',
                filters         = '{ categoryFilters }'
            )
                #{'yield'}(to='filters')
                    .well.well-sm
                        .form-inline
                            .form-group
                                label.checkbox-inline
                                    input(type='checkbox', data-name='flagHit', data-bool='Y,N')
                                    | Хиты
                                label.checkbox-inline
                                    input(type='checkbox', data-name='flagNew', data-bool='Y,N')
                                    | Новинки
                                label.checkbox-inline
                                    input(type='checkbox', data-name='specialOffer', data-bool='Y,N')
                                    | Спецпредложения
                            .form-group(if='{ parent.labels.length }')
                                select.form-control(data-name='idLabel', onchange='{ parent.selectLabel }')
                                    option(value='') Все ярлыки
                                    option(each='{ label, i in parent.labels }', value='{ label.id }', no-reorder) { label.name }
                            .form-group
                                .input-group(style="width: 48%; float: left; margin: 0 2% 0 0;")
                                    span.input-group-addon
                                        i.fa.fa-percent
                                    select.form-control(data-name='discount')
                                        option(value='') Все
                                        option(value='Y') Со скидкой
                                        option(value='N') Без скидки
                                .input-group(style="width: 48%; float: left; margin: 0 0 0 2%;")
                                    span.input-group-addon
                                        i.fa.fa-eye
                                    select.form-control(data-name='enabled')
                                        option(value='') Все
                                        option(value='Y') Отображаемые
                                        option(value='N') Неотображаемые
                            .form-group
                                select.form-control(data-name='idBrand', onchange='{ parent.selectBrand }')
                                    option(value='') Все бренды
                                    option(each='{ brand, i in parent.brands }', value='{ brand.id }', no-reorder) { brand.name }

                // меню действий
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
                                a(href='#', data-field='enabled')
                                    i.fa.fa-fw.fa-eye
                                    |  Видимость (вкл/выкл)
                            li(onclick='{ handlers.toggleSelected }')
                                a(href='#', data-field='flagNew')
                                    i.fa.fa-fw.fa-asterisk
                                    |  Новинка (вкл/выкл)
                            li(onclick='{ handlers.toggleSelected }')
                                a(href='#', data-field='flagHit')
                                    i.fa.fa-fw.fa-star
                                    |  Хит (вкл/выкл)
                            li(onclick='{ handlers.toggleBool }')
                                a(href='#', data-field='isMarket')
                                    i.fa.fa-fw.fa-money
                                    |  Маркет (вкл/выкл)
                            li(onclick='{ handlers.toggleSelected }')
                                a(href='#', data-field='specialOffer')
                                    i.fa.fa-fw.fa-check
                                    |  Спец.
                            li.divider
                            li(onclick='{ handlers.setCategory }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Переопределить категорию
                            li(onclick='{ handlers.setBrand }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Назначить бренд
                            li.divider
                            li(onclick='{ handlers.setAddCategory }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Назначить доп. категории
                            li(onclick='{ handlers.addCategory }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Добавить доп. категории
                            li.divider
                            li(onclick='{ handlers.setFeatures }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Назначить атрибуты
                            li(onclick='{ handlers.addFeatures }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Добавить атрибуты
                            li(onclick='{ handlers.showFeatures }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Отображать атрибуты на сайте
                            li(onclick='{ handlers.hideFeatures }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Скрывать атрибуты на сайте
                            li.divider
                            li(onclick='{ handlers.setModifications }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Назначить модификации
                            li(onclick='{ handlers.addModifications }')
                                a(href='#')
                                    i.fa.fa-fw
                                    |  Добавить модификации
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
                        button.btn.btn-primary(
                        type='button', onclick='{ parent.exportProducts }', title='Экспорт')
                            i.fa.fa-upload
                        button.btn.btn-primary(if='{ checkPermission("products", "0111") }',
                        type='button', onclick='{ parent.importProducts }', title='Импорт')
                            i.fa.fa-download

                // лист каталога товаров
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='img', style="max-width: 50px; overflow: hidden;")
                        img(if='{ row.imageUrlPreview.trim() !== "" }', src='{ row.imageUrlPreview }', style='max-height: 40px;')
                    datatable-cell(name='article') { row.article }
                    datatable-cell(name='name', style="max-width: 150px; overflow: hidden; text-overflow: ellipsis;") { row.name }
                    datatable-cell.text-right(name='price')
                        span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                        span  { (row.price / 1).toFixed(2) }
                        span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
                    datatable-cell(name='nameBrand', style="max-width: 80px; overflow: hidden; text-overflow: ellipsis;") { row.nameBrand }
                    datatable-cell(name='nameGroup', style="max-width: 100px; overflow: hidden; text-overflow: ellipsis;") { row.nameGroup }
                    datatable-cell(name='enabled')
                        button.btn.btn-default.btn-sm(type='button',
                        onclick='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchend='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchstart='{ stopPropagation }',
                        disabled='{ !handlers.checkPermission("products", "0010") }')
                            i(class='fa { row.enabled == "Y" ? "fa-eye text-active" : "fa-eye-slash text-noactive" } ')
                    datatable-cell(name='flagNew')
                        button.btn.btn-default.btn-sm(type='button',
                        onclick='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchend='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchstart='{ stopPropagation }',
                        disabled='{ !handlers.checkPermission("products", "0010") }')
                            i(class='fa { row.flagNew == "Y" ? "fa-asterisk text-active" : "fa-asterisk text-noactive" } ')
                    datatable-cell(name='flagHit')
                        button.btn.btn-default.btn-sm(type='button',
                        onclick='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchend='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchstart='{ stopPropagation }',
                        disabled='{ !handlers.checkPermission("products", "0010") }')
                            i(class='fa { row.flagHit == "Y" ? "fa-star text-active" : "fa-star text-noactive" } ')
                    datatable-cell(name='isMarket')
                        button.btn.btn-default.btn-sm(type='button',
                        onclick='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchend='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchstart='{ stopPropagation }',
                        disabled='{ !handlers.checkPermission("products", "0010") }')
                            i(class='fa { row.isMarket ? "fa-money text-active" : "fa-money text-noactive" } ')
                    datatable-cell(name='specialOffer')
                        button.btn.btn-default.btn-sm(type='button',
                        onclick='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchend='{ handlers.permission(handlers.boolChange, "products", "0010") }',
                        ontouchstart='{ stopPropagation }',
                        disabled='{ !handlers.checkPermission("products", "0010") }')
                            i(class='fa { row.specialOffer == "Y" ? "fa-check text-active" : "fa-check text-noactive" } ')



    style(scoped).
        :scope {
            display: block;
            position: relative;
        }
        .text-active {
            color: #000;
        }
        .text-noactive {
            color: #ccc;
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
        self.labels = []
        self.categoryFilters = false

        self.add = e => {
            /*
            * СОЗДАНИЕ ТОВАРА
            * получаем базовыю валюту
            * формируем данные: name, idGroup, idBrand, curr
            * передаем в Product Save
            */
            API.request({
                object: 'Main',
                method: 'Info',
                data: {},
                success(response) {
                    self.basecurr = response.basecurr
                    modals.create('product-new-modal', {
                        type: 'modal-primary',
                        submit() {
                            var _this = this
                            var params = {
                                name: this.name.value,
                                idGroup: self.selectedCategory,
                                idBrand: self.selectedBrand,
                                curr: self.basecurr
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
            })
        }
        self.cols = [
            { name:'id', value:'#'},
            { name: 'img', value: 'Фото'},
            { name:'article', value:'Артикул'},
            { name:'name', value:'Наименование'},
            { name:'price', value:'Цена'},
            { name:'nameBrand', value:'Бренд'},
            { name:'nameGroup', value:'Группа'},
            { name:'enabled', value:'Вид'},
            { name:'flagNew', value:'Нв'},
            { name:'flagHit', value:'Хит'},
            { name:'isMarket', value:'ЯМ'},
            { name:'specialOffer', value:'Спец.'},
        ]

        function afterChangeParent(idParent, id, position) {
            let params = {}
            params.id = id
            params.upid = idParent
            params.position = position

            API.request({
                object: 'Category',
                method: 'Save',
                data: params,
                success() {
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                }
            })

        }

        function  afterChangePosition(indexes) {
            let params = { indexes: indexes }
            API.request({
                object: 'Category',
                method: 'Sort',
                data: params,
                success() {
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                }
            })
        }

        self.handlersGroups = {
            afterChangeParent: afterChangeParent,
            afterChangePosition: afterChangePosition
        }

        // сохранение измененных через лист параметров
        self.handlers = {
            checkPermission: self.checkPermission,
            permission: self.permission,
            boolChange(e) {
                var _this = this
                e.stopPropagation()
                e.stopImmediatePropagation()
                if (_this.opts.name == 'isMarket')
                    _this.row[_this.opts.name] = _this.row[_this.opts.name] ? 0 : 1
                else
                    _this.row[_this.opts.name] = _this.row[_this.opts.name] === 'Y' ? 'N' : 'Y'
                self.update()

                var params = {}
                params.id = _this.row.id
                params[_this.opts.name] = _this.row[_this.opts.name]

                params = self.tags.catalog.allParams(params);
                API.request({
                    object: 'Product',
                    method: 'Save',
                    data: params,
                    error(response) {
                        if (_this.opts.name == 'isMarket')
                            _this.row[_this.opts.name] = _this.row[_this.opts.name] ? 0 : 1
                        else
                            _this.row[_this.opts.name] = _this.row[_this.opts.name] === 'Y' ? 'N' : 'Y'
                        self.update()
                    }
                })
            },
            // селекторы
            toggleSelected(e) {
                let field = e.target.getAttribute('data-field')

                let oldValues = {}
                let rows = this.tags.datatable.getSelectedRows()
                let ids = rows.map(item => item.id)
                let newValue = rows[0][field] === 'Y' ? 'N' : 'Y'

                let params = self.tags.catalog.getSelectedMode()
                params[field] = newValue

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
            toggleBool(e) {
                let field = e.target.getAttribute('data-field')
                let oldValues = {}
                let rows = this.tags.datatable.getSelectedRows()
                let ids = rows.map(item => item.id)
                let newValue = rows[0][field] ? 0 : 1

                let params = self.tags.catalog.getSelectedMode()
                params[field] = newValue

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

            // МЕНЮ ДЕЙСТВИЙ
            // мультиредактирование товаров
            multiEdit(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id).join(',')
                riot.route(`/products/multi?ids=${ids}`)
            },
            // клонирование товара
            cloneProduct(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id).join(',')
                riot.route(`/products/clone?id=${ids}`)
            },
            /*
            * ПЕРЕОПРЕДЕЛИТЬ КАТЕГОРИЮ
            * ids                    id выделенных товаров
            * items                    id выбранных категорий для товаров
            * items[0], params        данные выбраннОЙ категории для товаров
            */
            setCategory(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id)

                modals.create('group-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()

                        if (items.length > 0) {
                            let params = { ids, idGroup: items[0].id }

                            params = self.tags.catalog.allParams(params);
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

            /*
            * НАЗНАЧЕНИЕ ДОП.КАТЕГОРИЙ
            * ids                    id выделенных товаров
            * items, params            данные выбранных категорий для товаров
            * itemsCrossGroups        массивы с данными по доп.категориям (отправляются нумерованным массивом)
            */
            setAddCategory(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id)

                modals.create('group-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()

                        if (items.length > 0) {
                            let itemsCrossGroups = {}
                            for(var i = 0; i < items.length; i++)
                                itemsCrossGroups[i] = items[i]

                            let params = {
                                ids,
                                crossGroups: itemsCrossGroups
                            }

                            params = self.tags.catalog.allParams(params);
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
            /** ДОБАВИТЬ ДОП.КАТЕГОРИИ
            * @param ids                id выделенных товаров
            * @param items, params      данные выбранных категорий для товаров
            */
            addCategory(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id)

                modals.create('group-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()

                        if (items.length > 0) {
                            let itemsCrossGroups = {}
                            for(var i = 0; i < items.length; i++)
                                itemsCrossGroups[i] = items[i]

                            let params = {
                                ids,
                                crossGroups:     itemsCrossGroups,
                                delCrosGroups:    "False"
                            }

                            params = self.tags.catalog.allParams(params);
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
            // добавить модификации
            addModifications(e) {
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
                                let params = { ids, add: true, ...this.item }
                                params = self.tags.catalog.allParams(params);
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
            contextMenu( Event, SelectedRow){
                return true;
            },
            // задать модификации
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

                                params = self.tags.catalog.allParams(params);
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
            // задать характеристики
            setFeatures(e) {
                let items = this.tags.datatable.getSelectedRows()
                let ids = items.map(item => item.id)
                let specifications = []

                API.request({
                    object: 'Product',
                    method: 'Info',
                    data: { id: ids , set: true},
                    success(response) {
                        specifications = response

                        modals.create('product-edit-parameters-modal', {
                            type: 'modal-primary',
                            size: 'modal-lg',
                            specifications,
                            submit() {
                                let _this = this
                                let params = { ids, ...this.item, isAddSpecifications: false }

                                params = self.tags.catalog.allParams(params);
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
            // добавить характеристики
            addFeatures(e) {
                let items = this.tags.datatable.getSelectedRows()
                let ids = items.map(item => item.id)
                //let specifications = []

                API.request({
                    object: 'Product',
                    method: 'Info',
                    data: { id: ids, set: true},
                    success(response) {
                        let specifications = response

                        modals.create('product-edit-parameters-modal', {
                            type: 'modal-primary',
                            size: 'modal-lg',
                            specifications,
                            submit() {
                                let _this = this
                                let params = { ids, ...this.item, isAddSpecifications: true }

                                params = self.tags.catalog.allParams(params);
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
            // задать бренд
            setBrand(e) {
                let ids = this.tags.datatable.getSelectedRows().map(item => item.id);
                let catalog = this;

                modals.create('brands-list-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags.catalog.tags.datatable.getSelectedRows();

                        let params = self.tags.catalog.getSelectedMode()
                        params['brand'] = { id: items[0].id, name: items[0].name }



                        /* let params = { ids, brand: { id: items[0].id, name: items[0].name }};

                        params = catalog.allParams(params); */

                        API.request({
                            object: 'Product',
                            method: 'Save',
                            data: params,
                            success(response) {
                                self.tags.catalog.reload()
                            }
                        });

                        self.update();
                        this.modalHide();
                    }
                })
            },
            // задать цену
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

                        params = self.tags.catalog.allParams(params);
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
            showFeatures(e) {
                let items = self.tags.catalog.tags.datatable.getSelectedRows()
                let ids = items.map(item => item.id)
                let params = { ids }
                params["isShowFeature"] = true;
                params = self.tags.catalog.allParams(params);
                API.request({
                    object: 'Product',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                    }
                })
            },
            hideFeatures(e) {
                let items = self.tags.catalog.tags.datatable.getSelectedRows()
                let ids = items.map(item => item.id)
                let params = { ids }
                params["isShowFeature"] = false;
                params = self.tags.catalog.allParams(params);
                API.request({
                    object: 'Product',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                    }
                })
            },
            // задать наценку
            setMarkup(e) {
                modals.create('markup-modal', {
                    type: 'modal-primary',
                    submit() {
                        let _this = this
                        let item = this.item
                        let params = self.tags.catalog.getSelectedMode()
                        params.value = item.value
                        params.price = item.price
                        params.source = item.source
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

        // получить бренды
        self.getBrands = () => {
            API.request({
                object: 'Brand',
                method: 'Fetch',
                success(response) {
                    self.brands = response.items
                    self.update()
                }
            })
        }

        // получить ярлыки
        self.getLabels = () => {
            API.request({
                object: 'ProductLabel',
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

        self.selectLabel = e => {
            self.selectLabel = e.target.value || undefined
        }

        // перезагрузка каталога продуктов
        observable.on('products-reload', (e) => {

            // принимаем группы для фильтрации
            if(e) {
                let items = e
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.categoryFilters = [{field: 'idGroup', sign: 'IN', value}]
                } else {
                    self.categoryFilters = false
                }
                self.update()
            }

            self.tags.catalog.reload()
        })

        // перезагрузка дерева категорий
        observable.on('categories-reload', (e) => {
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

        self.import = {}

        observable.on('products-imports', () => {
            modals.create('import-products-modal-continue', {
                type: 'modal-primary',
            })
        })
        observable.on('products-imports-end', () => {
            modal.modalHide()
        })

        self.importProducts = (e) => {
            modals.create('import-products-modal', {
                type: 'modal-primary'
            })
            //var formData = new FormData();
            //for (var i = 0; i < e.target.files.length; i++) {
            //   formData.append('file' + i, e.target.files[i], e.target.files[i].name)
            //}
            //
            //API.upload({
            //    object: 'Product',
            //    data: formData,
            //    success(response) {
            //        self.update();
            //    }
            //})
        }

        self.exportProducts = (e) => {
            modals.create('export-products-modal', {
                type: 'modal-primary'
            })

            // API.request({
            //     object: 'Product',
            //     method: 'Export',
            //     success(response, xhr) {
            //         let a = document.createElement('a')
            //         a.href = response.url
            //         a.download = response.name
            //         document.body.appendChild(a)
            //         a.click()
            //         a.remove()
            //     }
            // })

        }


        self.getBrands()
        self.getLabels()
