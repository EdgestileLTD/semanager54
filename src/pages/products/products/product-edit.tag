| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'components/autocomplete.tag'
| import 'lodash/lodash'
| import 'pages/products/products/product-edit-images.tag'
| import 'pages/products/products/product-edit-modifications.tag'
| import 'pages/products/products/product-edit-parameters.tag'
| import 'pages/products/products/product-edit-categories.tag'
| import 'pages/products/products/product-edit-discounts.tag'
| import 'pages/products/groups/group-select-modal.tag'
| import 'pages/products/parameters/parameters-list-select-modal.tag'
| import 'pages/products/products/products-list-select-modal.tag'
| import 'pages/products/brands/brands-list-select-modal.tag'

| import parallel from 'async/parallel'

product-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#products') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("products", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isMulti }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isMulti ? item.name || 'Мультиредактирование товаров' : isClone ? 'Клонирование товара' : item.name || 'Редактирование товара' }

        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#product-edit-home') Основная информация
            li: a(data-toggle='tab', href='#product-edit-full-text') Описание
            li: a(data-toggle='tab', href='#product-edit-categories') Разделы
            li: a(data-toggle='tab', href='#product-edit-images') Картинки
            li: a(data-toggle='tab', href='#product-edit-parameters') Характеристики
            li: a(data-toggle='tab', href='#product-edit-similar-products') Похожие товары
            li: a(data-toggle='tab', href='#product-edit-accompanying-products') Сопутствующие товары
            li: a(data-toggle='tab', href='#product-edit-discounts') Скидки
            li: a(data-toggle='tab', href='#product-edit-seo') SEO
            li: a(data-toggle='tab', href='#product-edit-reviews') Отзывы
            li: a(data-toggle='tab', href='#product-edit-comments') Комментарии

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #product-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-6(if='{ !isMulti }')
                            .form-group(class='{ has-error: error.name }')
                                label.control-label Наименование
                                input.form-control(name='name', type='text', value='{ item.name }')
                                .help-block { error.name }
                        .col-md-6
                            .form-group
                                label Бренд
                                .input-group
                                    input.form-control(value='{ item.nameBrand }', readonly='{ true }')
                                    span.input-group-addon(onclick='{ permission(selectBrand, "products", "0010") }')
                                        i.fa.fa-list
                                    span.input-group-addon(onclick='{ permission(removeBrand, "products", "0010") }')
                                        i.fa.fa-times
                    .row
                        .col-md-6(if='{ !isMulti }'): .form-group
                                label.control-label URL товара
                                .input-group
                                    input.form-control(name='url', value='{ item.url }')
                                    span.input-group-addon(onclick='{ permission(translite, "products", "0010") }')
                                        | Транслитерация
                        //.col-md-4: .form-group
                                label.control-label Валюта
                                select.form-control(name='currency', value='{ item.curr }')
                                    option(each='{ c, i in currencies }', value='{ c.name }',
                                    selected='{ c.name == item.curr }', no-reorder) { c.title }
                        .col-md-6: .form-group
                            label.control-label Тип товара
                            select.form-control(name='idType', value='{ item.idType }')
                                option(value='')
                                option(each='{ item.productTypes }', value='{ id }',
                                selected='{ id == item.idType }', no-reorder) { name }
                    .row
                        .col-md-3
                            .form-group(if='{ !item.isUnlimited }')
                                label.control-label Количество
                                p.form-control { count || 0 }
                            .form-group(if='{ item.isUnlimited }')
                                label.control-label Текст при неогр. кол-ве
                                input.form-control(name='availableInfo', value='{ item.availableInfo }')
                        .col-md-3
                            label.hidden-xs &nbsp;
                            .checkbox
                                label
                                    input(name='isUnlimited', type='checkbox', checked='{ item.isUnlimited }')
                                    | Неограниченное
                        .col-md-3
                            .form-group
                                label.control-label Единицы измерения
                                select.form-control(name='idMeasure', value='{ item.idMeasure }')
                                    option(value='')
                                    option(each='{ item.measures }', value='{ id }',
                                    selected='{ id == item.idMeasure }', no-reorder) { name }
                        .col-md-3
                            .form-group
                                label.control-label Шаг количества
                                input.form-control(name='stepCount', type='number', min='0', step='0.01', value='{ parseFloat(item.stepCount) }')
                    .row: .col-md-12
                        product-edit-modifications(name='offers', value='{ item.offers }', is-unlimited='{ item.isUnlimited }',
                        add='{ item.idType ? modificationAdd : "" }')
                    .row: .col-md-12
                        .form-group
                            checkbox-list(items='{ item.labels }')
                    .row
                        .col-md-12
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                        | Отображать на сайте
                #product-edit-full-text.tab-pane.fade
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Краткое описание
                                ckeditor(name='description', value='{ item.description }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Полный текст
                                ckeditor(name='content', value='{ item.content }')

                #product-edit-images.tab-pane.fade
                    product-edit-images(name='images', value='{ item.images }', section='shopprice')

                #product-edit-parameters.tab-pane.fade
                    product-edit-parameters(name='specifications', value='{ item.specifications }')

                #product-edit-similar-products.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='similarProducts', add='{ permission(addSimilarProducts, "products", "0010") }',
                            cols='{ productsCols }', rows='{ item.similarProducts }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='name') { row.name }

                #product-edit-accompanying-products.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='accompanyingProducts', add='{ permission(addAccompanyingProducts, "products", "0010") }',
                            cols='{ productsCols }', rows='{ item.accompanyingProducts }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='name') { row.name }

                #product-edit-discounts.tab-pane.fade
                    product-edit-discounts(name='discounts', value='{ item.discounts }')

                #product-edit-categories.tab-pane.fade
                    product-edit-categories(name='groups', value='{ item.groups }')

                #product-edit-seo.tab-pane.fade
                    .row
                        .col-md-12
                            .form-group
                                button.btn.btn-primary.btn-sm(each='{ seoTags }', title='{ note }', type='button'
                                onclick='{ seoTag.insert }', no-reorder) { name }
                            .form-group
                                label.control-label  Head title
                                input.form-control(name='metaTitle', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.metaTitle }')
                            .form-group
                                label.control-label  Meta keywords
                                input.form-control(name='metaKeywords', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.metaKeywords }')
                            .form-group
                                label.control-label  Meta description
                                textarea.form-control(rows='5', name='metaDescription', onfocus='{ seoTag.focus }',
                                style='min-width: 100%; max-width: 100%;', value='{ item.metaDescription }')
                #product-edit-reviews.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='reviews', dblclick='{ editReview }',
                                cols='{ reviewsCols }', rows='{ item.reviews }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='date') { row.dateDisplay }
                                    datatable-cell(name='userName') { row.userName }
                                    datatable-cell(name='mark')
                                        star-rating(count='5', value='{ row.mark }')
                                    datatable-cell(name='likes') { row.likes }
                                    datatable-cell(name='dislikes') { row.dislikes }
                                    datatable-cell(name='commentary') { _.truncate(row.commentary.replace( /<.*?>/g, '' ), {length: 50}) }
                                    datatable-cell(name='merits') { _.truncate(row.merits.replace( /<.*?>/g, '' ), {length: 50}) }
                                    datatable-cell(name='demerits') { _.truncate(row.demerits.replace( /<.*?>/g, '' ), {length: 50}) }
                #product-edit-comments.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='comments',
                            cols='{ commentsCols }', rows='{ item.comments }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='date') { row.dateDisplay }
                                    datatable-cell(name='userName') { row.userName }
                                    datatable-cell(name='userEmail') { row.userEmail }
                                    datatable-cell(name='commentary') { _.truncate(row.commentary.replace( /<.*?>/g, '' ), {length: 50}) }
                                    datatable-cell(name='response') { _.truncate(row.response.replace( /<.*?>/g, '' ), {length: 50}) }

    style(scoped).
        .color {
            height: 12px;
            width: 12px;
            display: inline-block;
            border: 1px solid #ccc;
        }

    script(type='text/babel').
        var self = this

        self.item = {}
        self.currencies = []
        self.seoTags = []
        self.loader = false
        self.error = false

        self.seoTag = new app.insertText()

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.productsCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.reviewsCols = [
            {name: 'date', value: 'Дата/время'},
            {name: 'userName', value: 'Пользователь'},
            {name: 'mark', value: 'Звёзд'},
            {name: 'likes', value: 'Лайков'},
            {name: 'dislikes', value: 'Дислайков'},
            {name: 'commentary', value: 'Отзыв'},
            {name: 'merits', value: 'Достоинства'},
            {name: 'demerits', value: 'Недостатки'}
        ]

        self.commentsCols = [
            {name: 'id', value: '#'},
            {name: 'date', value: 'Дата/время'},
            {name: 'userName', value: 'Пользователь'},
            {name: 'userEmail', value: 'Email пользователя'},
            {name: 'commentary', value: 'Комментарий'},
            {name: 'response', value: 'Ответ администратора'}
        ]

        self.addSimilarProducts = () => {
            modals.create('products-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.item.similarProducts = self.item.similarProducts || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.item.similarProducts.map(item => {
                        return item.id
                    })

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1) {
                            self.item.similarProducts.push(item)
                        }
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.addAccompanyingProducts = () => {
            modals.create('products-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.item.accompanyingProducts = self.item.accompanyingProducts || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.item.accompanyingProducts.map(item => {
                        return item.id
                    })

                    items.forEach(function (item) {
                        if (ids.indexOf(item.id) === -1) {
                            self.item.accompanyingProducts.push(item)
                        }
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.modificationAdd = e => {
            var item
            if (e) item = e.item.row ? e.item.row : {}
            modals.create('product-edit-modifications-add-modal', {
                type: 'modal-primary',
                item,
                idType: self.item.idType,
                submit() {
                    let params = this.item
                    let modifications = self.item.offers.map(item => item.params.map(item => item.idValue))
                    let newModification = params.map(item => item.idValue).toString()

                    for(let i = 0; i < modifications.length; i++) {
                        if (modifications[i].toString() === newModification) {
                            popups.create({title: 'Ошибка!', text: 'Такая модификация уже существует', style: 'popup-danger'})
                            return
                        }
                    }

                    self.item.offers.push({
                        idProduct: self.item.id,
                        article: '',
                        price: 0,
                        count: 0,
                        params
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.submit = e => {
            var params = self.item

            if (self.isMulti) {
                self.error = false
                params = { ids: self.multiIds, ...self.item }
            } else {
                self.error = self.validation.validate(params, self.rules)
            }

            if (!self.error) {
                self.loader = true

                if (self.item.groups.length) {
                    self.item.groups[0].isMain = true
                }

                API.request({
                    object: 'Product',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Товар сохранен!', style: 'popup-success'})
                        if (self.isClone)
                            riot.route(`/products/${self.item.id}`)
                        observable.trigger('products-reload')
                    },
                    complete() {
                        self.loader = false
                        self.update()
                    }
                })
            }
        }

        self.selectGroup = e => {
            modals.create('group-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                    self.item.idGroup = items[0].id
                    self.item.nameGroup = items[0].name

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeGroup = e => {
            self.item.idGroup = 0
            self.item.nameGroup = ''
        }

        self.selectBrand = e => {
            modals.create('brands-list-select-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    self.item.idBrand = items[0].id
                    self.item.nameBrand = items[0].name
                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeBrand = e => {
            self.item.idBrand = null
            self.item.nameBrand = ''
        }

        self.editReview = e => {
            riot.route(`/reviews/${e.item.row.id}`)
        }

        self.translite = e => {
            var params = {vars:[self.item.url]}

            API.request({
                object: 'Functions',
                method: 'Translit',
                data: params,
                success(response, xhr) {
                    self.item.code = response.items[0]
                    self.update()
                }
            })
        }

        self.parametersChange = e => {
            if (parseInt(e.target.value)) {
                API.request({
                    object: 'ProductType',
                    method: 'Info',
                    data: {id: parseInt(e.target.value)},
                    success(response) {
                        self.item.specifications = response.features
                    },
                    complete() {
                        self.update()
                    }
                })
            }
        }


        function getProduct(id, callback) {
            var params = {id}

            parallel([
                callback => {
                    API.request({
                        object: 'Product',
                        method: 'Info',
                        data: params,
                        success(response) {
                            self.item = response
                            self.count = self.item.offers
                                .map(i => i.count)
                                .reduce((s,c) => +s + +c, 0)
                            callback(null, 'Product')
                        },
                        error(response) {
                            self.item = {}
                            callback('error', null)
                        }
                    })
                }, callback => {
                    API.request({
                        object: 'Currency',
                        method: 'Fetch',
                        data: {},
                        success(response) {
                            self.currencies = response.items
                            callback(null, 'Currencies')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }, callback => {
                    API.request({
                        object: 'SeoVariable',
                        method: 'Fetch',
                        data: {type: 'goods'},
                        success(response) {
                            self.seoTags = response.items
                            callback(null, 'SEOTagsVars')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                },
                //                  callback => {
                //                      API.request({
                //                          object: 'ProductType',
                //                          method: 'Fetch',
                //                          success(response) {
                //                              self.productTypes = response.items
                //                             callback(null, 'ProductType')
                //                          },
                //                          error(response) {
                //                              callback('error', null)
                //                          }
                //                      })
                //                  }
            ], (err, res) => {
                if (typeof callback === 'function')
                    callback.bind(this)()
            })
        }


        self.reload = () => {
            observable.trigger('products-edit', self.item.id)
        }

        observable.on('products-edit', id => {
            self.error = false
            self.isMulti = false
            self.isClone = false
            self.loader = true
            self.update()

            getProduct(id, () => {
                self.loader = false
                self.update()
            })
        })

        observable.on('products-clone', id => {
            self.error = false
            self.isMulti = false
            self.isClone = true
            self.loader = true
            self.update()

            getProduct(id, () => {
                self.loader = false
                delete self.item.id
                delete self.item.article
                self.item.images.forEach(item => {
                    delete item.id
                })

            self.update()
            })
        })

        observable.on('products-multi-edit', ids => {
            self.error = false
            self.isMulti = true
            self.isClone = false
            self.item = {}
            self.multiIds = ids
            self.update()
        })

        self.on('mount', () => {
            riot.route.exec()
        })