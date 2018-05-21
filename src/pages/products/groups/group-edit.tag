| import 'components/ckeditor.tag'
| import 'components/loader.tag'

| import 'pages/images/image-select.tag'
| import 'pages/products/products/product-edit-additional-categories.tag'
| import 'pages/products/products/product-edit-discounts.tag'
| import 'pages/products/groups/filters-select-modal.tag'
| import parallel from 'async/parallel'

group-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products/categories') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("products", "0010") }', class='{ item._edit_ ? "btn-success" : "btn-default" }',
            onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isMulti }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isMulti ? 'Мультиредактирование категорий' : item.name || 'Редактирование категории' }
        ul.nav.nav-tabs.m-b-2
            li(if='{ !isMulti }', class='{ active: !isMulti }') #[a(data-toggle='tab', href='#group-edit-home') Основная информация]
            li(if='{ !isMulti }') #[a(data-toggle='tab', href='#group-edit-similar') Похожие категории]
            li(if='{ !isMulti }') #[a(data-toggle='tab', href='#group-edit-full-text') Полное описание]
            li(if='{ app.config.version=="5.3.1"} ', class='{ active: isMulti }') #[a(data-toggle='tab', href='#group-edit-images') Картинки]
            li #[a(data-toggle='tab', href='#group-edit-parameters-filters') Фильтры параметров]
            li #[a(data-toggle='tab', href='#group-edit-discounts') Скидки]
            li #[a(data-toggle='tab', href='#group-edit-seo') SEO]
            li #[a(data-toggle='tab', href='#group-edit-fields', if='{ item.customFields }') Поля]
        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                // главная страница
                #group-edit-home.tab-pane.fade(show='{ !isMulti }', class='{ "in active": !isMulti }')
                    .row
                        .col-md-2
                            .form-group
                                .well.well-sm
                                    image-select(name='picture', section='shopgroup', alt='0', size='256', value='{ item.picture }')

                        .col-md-10
                            .row
                                .col-md-6
                                    .form-group(class='{ has-error: error.name }')
                                        label.control-label Наименование
                                        input.form-control(name='name', type='text', value='{ item.name }')
                                        .help-block { error.name }
                                .col-md-6
                                    .form-group
                                        label.control-label Родитель
                                        .input-group
                                            input.form-control(name='nameGroup', value='{ item.nameParent }', readonly='{ true }')
                                            .input-group-btn
                                                .btn.btn-default(onclick='{ selectGroup }')
                                                    i.fa.fa-list.text-primary
                                                .btn.btn-default(onclick='{ removeGroup }')
                                                    i.fa.fa-times.text-danger
                            //.row
                                .col-md-12
                                    .form-group
                                        label.control-label Связанные группы
                                        product-edit-additional-categories(name='linksGroups', value='{ item.linksGroups }')
                            .row
                                .col-md-6
                                    .form-group
                                        label.control-label URL страницы
                                        input.form-control(name='codeGr', type='text', value='{ item.codeGr }')
                                .col-md-6
                                    .form-group
                                        label.control-label Группа модификаций по умолчанию
                                        select.form-control(name='idModificationGroupDef', value='{ item.idModificationGroupDef }')
                                            option(value='')
                                            option(each='{ item.modificationsGroups }', value='{ id }',
                                            selected='{ id == item.idModificationGroupDef }', no-reorder) { name }
                            .row
                                .col-md-3
                                    label.hidden-xs &nbsp;
                                    .checkbox
                                        label
                                            input(name='active', type='checkbox', checked='{ item.active == "Y" }')
                                            | Отображать на сайте
                                .col-md-3
                                    label.hidden-xs &nbsp;
                                    .checkbox
                                        label
                                            input(name='discount', type='checkbox', checked='{ item.discount == "Y" }')
                                            | Предоставлять скидку
                                .col-md-2
                                    .form-group
                                        label.control-label Порядок вывода
                                        input.form-control(name='position', type='number', step='1', value='{ item.position }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Краткое описание
                                ckeditor(name='commentary', value='{ item.commentary }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Похожие группы
                                product-edit-additional-categories(name='relatedGroups', value='{ item.relatedGroups }')
                    //.row
                        .col-md-12
                            .form-group
                                label.control-label Связанные группы
                                product-edit-additional-categories(name='linksGroups', value='{ item.linksGroups }')

                // раздел: похожие категории
                #group-edit-similar.tab-pane.fade(show='{ !isMulti }')
                    catalog-static(name='similar', rows='{ item.similar }', cols='{ similarCols }', add='{ addChild }',
                    reorder='true', dblclick='{ openGroup }', remove='true')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='position') { parseInt(row.position) || 0 }

                // полный тектс
                #group-edit-full-text.tab-pane.fade(show='{ !isMulti }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Полный текст
                                ckeditor(name='footertext', value='{ item.footertext }')

                // картинки
                #group-edit-images.tab-pane.fade(class='{ "in active": isMulti }')
                    product-edit-images(name='images', value='{ item.images }', section='shopgroup')

                #group-edit-parameters-filters.tab-pane.fade
                    catalog-static(name='parametersFilters', add='{ addParametersFilters }', reorder='true', remove='true',
                    cols='{ parametersFiltersCols }', rows='{ item.parametersFilters }', handlers='{ parametersFiltersHandlers }')
                        #{'yield'}(to='body')
                            datatable-cell(name='isActive')
                                i.fa.fa-fw(onclick='{ handlers.toggleCheckbox }',
                                class='{row.isActive ? "fa-check-square-o" : "fa-square-o" }')
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='sortIndex') { row.sortIndex }

                #group-edit-discounts.tab-pane.fade
                    product-edit-discounts(name='discounts', value='{ item.discounts }')

                #group-edit-seo.tab-pane.fade
                    .row
                        .col-md-12
                            .form-group
                                button.btn.btn-primary.btn-sm(each='{ seoTags }', title='{ note }', type='button',
                                    onclick='{ seoTag.insert }', no-reorder) { name }
                            .form-group
                                label.control-label Заголовок (title)
                                input.form-control(name='title', type='text', onfocus='{ seoTag.focus }',
                                    value='{ item.title }')
                            .form-group
                                label.control-label Ключевые слова (keywords)
                                input.form-control(name='keywords', type='text',
                                    onfocus='{ seoTag.focus }', value='{ item.keywords }')
                            .form-group
                                label.control-label Оглавление страницы (H1)
                                input.form-control(name='pageTitle', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.pageTitle }')
                            .form-group
                                label.control-label Описание (description)
                                textarea.form-control(rows='5', name='description', onfocus='{ seoTag.focus }',
                                    style='min-width: 100%; max-width: 100%;', value='{ item.description }')
                #group-edit-fields.tab-pane.fade(if='{ item.customFields }')
                    add-fields-edit-block(name='customFields', value='{ item.customFields }')


    script(type='text/babel').
        var self = this
        self.edit = false
        self.app = app
        self.item = {}
        self.loader = false
        self.error = false
        self.reloaded = false;
        self.seoTags = []

        self.parametersFiltersCols = [
            {name: 'isActive', value: '', width: '40px'},
            {name: 'name', value: 'Наименование'},
            {name: 'sortIndex', value: 'Индекс'}
        ]

        // шапка таблицы похожие категории
        self.similarCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'position', value: 'Индекс'}
        ]

        self.seoTag = new app.insertText()


        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            if (name == 'name')
                self.reloaded = true;
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        // отправить
        self.submit = e => {
            var params = self.item

            if (self.isMulti) {
                self.error = false
                params = { ids: self.multiIds, ...self.item }
            } else {
                self.error = self.validation.validate(params, self.rules)
            }

            self.loader = true

            if (!self.error) {
                self.loader = true

                API.request({
                    object: 'Category',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Категория сохранена!', style: 'popup-success'})
                        if (self.reloaded)
                           observable.trigger('categories-reload')
                    },
                    complete() {
                        self.loader = false
                        self.update()
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('categories-edit', self.item.id)
        }

        self.selectGroup = e => {
            let id = self.item.id
            modals.create('group-select-modal', {
                type: 'modal-primary',
                id,
                submit() {
                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()

                    if (items.length && items[0].id != self.item.id) {
                        self.item.upid = items[0].id
                        self.item.nameParent = items[0].name
                        self.update()
                        self.reloaded = true;
                        this.modalHide()
                    }
                }
            })
        }

        self.openGroup = e => {
            window.open(`#products/categories/${e.item.row.id}`, '_blank')
        }

        // добавление новой похожей категории
        self.addChild = () => {
            modals.create('group-select-modal', {
                type: 'modal-primary',
                submit() {
                    self.item.similar = self.item.similar || []

                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                    let ids = self.item.similar.map(item => item.id)

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1)
                        self.item.similar.push(item)
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.addParametersFilters = () => {
            modals.create('filters-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.item.parametersFilters = self.item.parametersFilters || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    let ids = self.item.parametersFilters .map(item => item.id)

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1)
                            self.item.parametersFilters.push(item)
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.parametersFiltersHandlers = {
            toggleCheckbox(e) {
                this.row.isActive = !this.row.isActive
            },
        }

        self.removeGroup = e => {
            self.item.upid = null
            self.item.nameParent = ''
        }

        // получение наддых по редактируемой категории
        observable.on('categories-edit', id => {
            self.item = {}
            self.isMulti = false
            self.loader = true
            self.error = false
            self.update()

            parallel([
                (callback) => {
                    var params = {id}

                    API.request({
                        object: 'Category',
                        method: 'Info',
                        data: params,
                        success(response) {
                            self.item = response
                            callback(null, 'success')
                        },
                        error(response) {
                            self.item = {}
                            callback('error', null)
                        }
                    })
                }, (callback) => {
                    API.request({
                        object: 'SeoVariable',
                        method: 'Fetch',
                        data: {type: 'goodsGroups'},
                        success(response) {
                            self.seoTags = response.items
                            callback(null, 'success')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }
            ], (err, res) => {
                self.loader = false
                self.update()
            })
        })

        observable.on('categories-multi-edit', ids => {
            self.item = {}
            self.isMulti = true
            self.error = false
            self.multiIds = ids
            self.update()
        })

        self.one('updated', () => {
            self.tags.similar.tags.datatable.on('reorder-end', (newIndex, oldIndex) => {
                let {current, limit} = self.tags.similar.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.similar.value.splice(offset + newIndex, 0, self.tags.similar.value.splice(offset + oldIndex, 1)[0])
                var temp = self.tags.similar.value
                self.rows = []
                self.update()
                self.tags.similar.value = temp

                self.tags.similar.items.forEach((item, sort) => {
                    item.sortIndex = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'Category',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
            self.tags.parametersFilters.tags.datatable.on('reorder-end', (newIndex, oldIndex) => {
                let {current, limit} = self.tags.similar.pages
                let offset = current > 0 ? (current - 1) * limit : 0
                self.tags.parametersFilters.value.splice(offset + newIndex, 0, self.tags.parametersFilters.value.splice(offset + oldIndex, 1)[0])
                var temp = self.tags.parametersFilters.value
                self.rows = []
                self.update()
                self.tags.parametersFilters.value = temp

                self.tags.parametersFilters.items.forEach((item, sort) => {
                    item.sortIndex = sort + offset
                })

                self.update()
            })
        })

        self.on('update', () => {
            localStorage.setItem('SE_section', 'shopgroup')
        })

        self.on('mount', () => {
            riot.route.exec()
        })
