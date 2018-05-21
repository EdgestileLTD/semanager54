| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'components/autocomplete.tag'
| import 'components/checkbox-list-inline.tag'
| import 'pages/settings/add-fields/add-fields-edit-block.tag'
| import 'pages/products/products/product-edit-images.tag'
| import 'pages/products/products/product-edit-modifications.tag'
| import 'pages/products/products/product-edit-parameters.tag'
| import 'pages/products/products/product-edit-additional-categories.tag'
| import 'pages/products/products/product-edit-discounts.tag'
| import 'pages/products/products/product-files.tag'
| import 'pages/products/products/product-edit-options.tag'
| import 'pages/products/groups/group-select-modal.tag'
| import 'pages/products/parameters/parameters-list-select-modal.tag'
| import 'pages/products/products/products-list-select-modal.tag'
| import 'pages/products/brands/brands-list-select-modal.tag'
| import 'pages/products/products/description-tabs.tag'

| import parallel from 'async/parallel'

product-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("products", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isMulti }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isMulti ? item.name || 'Мультиредактирование товаров' : isClone ? 'Клонирование товара' : item.name || 'Редактирование товара' }

        // вкладки
        ul.nav.nav-tabs.m-b-2
            li.active
                a(data-toggle='tab', href='#product-edit-home', class="fa fa-shopping-bag", title="Основная информация")
                    span.hidden-xs  Главная
            li
                a(data-toggle='tab', href='#product-edit-full-text', class="fa fa-sticky-note-o", title="Полное описание")
                    span.hidden-xs  Описание
            li
                a(data-toggle='tab', href='#product-edit-images', class="fa fa-picture-o", title="Картинки")
                    span.hidden-xs  Картинки
            li
                a(data-toggle='tab', href='#product-edit-prices', class="fa fa-cog", title="Цены")
                    span.hidden-xs  Цены
            li(if='{ app.config.version > 530 }')
                a(data-toggle='tab', href='#product-edit-options', class="fa fa-list", title="Опции")
                    span.hidden-xs  Опции
            li
                a(data-toggle='tab', href='#product-edit-parameters', class="fa fa-cog", title="Характеристики товара")
                    span.hidden-xs  Аттрибуты
            li
                a(data-toggle='tab', href='#product-edit-modifications', class="fa fa-sliders", title="Модификации")
                    span.hidden-xs  Модифик.
            li
                a(data-toggle='tab', href='#product-edit-similar-products', class="fa fa-object-ungroup", title="Похожие товары")
                    span.hidden-xs  Похожие
            li
                a(data-toggle='tab', href='#product-edit-accompanying-products', class="fa fa-share-alt", title="Сопутствующие товары")
                    span.hidden-xs  Сопутствующие
            li
                a(data-toggle='tab', href='#product-edit-files', class="fa fa-files-o", title="Файлы")
                    span.hidden-xs  Файлы
            li
                a(data-toggle='tab', href='#product-edit-discounts', class="fa fa-percent", title="Скидки")
                    span.hidden-xs  Скидки

            li
                a(data-toggle='tab', href='#product-edit-seo')
                    i.fa SEO
                    span.hidden-xs  Продвижение
            li
                a(data-toggle='tab', href='#product-edit-reviews', class="fa fa-comment-o", title="Отзывы")
                    span.hidden-xs  Отзывы
            li(if='{ item.customFields }')
                a(data-toggle='tab', href='#product-edit-fields', title="Дополнительная информация") Доп.

        // вкладка-контент
        .tab-content
            #product-edit-home.tab-pane.fade.in.active
                // поля формы
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row(if='{ !isMulti }')
                        .col-md-2
                            .form-group
                                label.control-label Артикул
                                input.form-control(name='article', type='text', value='{ item.article }')
                        .col-md-4(if='{ !isMulti }')
                            .form-group(class='{ has-error: error.name }')
                                label.control-label Наименование
                                input.form-control(name='name', type='text', value='{ item.name }')
                                .help-block { error.name }
                        .col-md-6
                            .form-group
                                label.control-label URL товара
                                .input-group
                                    input.form-control(name='code', value='{ item.code }')
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ permission(translite, "products", "0010") }')
                                            | Транслитерация
                    .row
                        .col-md-6
                            .form-group
                                label Категория
                                .input-group
                                    input.form-control(name='nameGroup', value='{ item.nameGroup }', readonly='{ true }')
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ permission(selectGroup, "products", "0010") }')
                                            i.fa.fa-list.text-primary
                                        .btn.btn-default(onclick='{ permission(removeGroup, "products", "0010") }')
                                            i.fa.fa-times.text-danger
                        .col-md-6
                            .form-group
                                label Бренд
                                .input-group
                                    input.form-control(value='{ item.nameBrand }', readonly='{ true }')
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ permission(selectBrand, "products", "0010") }')
                                            i.fa.fa-list.text-primary
                                        .btn.btn-default(onclick='{ permission(removeBrand, "products", "0010") }')
                                            i.fa.fa-times.text-danger
                    .row
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Розничная цена
                                input.form-control(name='price', type='number', min='0', step='0.01', value='{ parseFloat(item.price) }')
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Валюта
                                select.form-control(
                                    name='curr',
                                    value='{ item.curr }'
                                )
                                    option(
                                        each='{ c, i in currencies }',
                                        value='{ c.name }',
                                        selected='{ c.name == item.curr }',
                                        no-reorder
                                    ) { c.title }
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Ед. измерения
                                input.form-control(name='measure', value='{ item.measure }')

                        .col-md-2.col-xs-4
                            .form-group(if='{ item.presenceCount >= 0 }')
                                label.control-label Количество
                                input.form-control(name='presenceCount', type='number', min='0', step='1', value='{ item.presenceCount }')
                            .form-group(if='{ item.presenceCount < 0 }')
                                label.control-label Текст при неогр. кол-ве
                                input.form-control(name='presence', value='{ item.presence }')
                        .col-md-2.col-xs-2
                            label.hidden-xs &nbsp;
                            .checkbox
                                label
                                    input(type='checkbox', checked='{ !item.presenceCount || item.presenceCount < 0 }',
                                    onchange='{ presenceChange }')
                                    | Неограниченное
                        .col-md-1.col-xs-6
                            .form-group
                                label.control-label Мин.кол-во
                                input.form-control(name='minCount', type='number', min='0', step='1', value='{ parseFloat(item.minCount) }')
                        .col-md-1.col-xs-6
                            .form-group
                                label.control-label Шаг количества
                                input.form-control(name='stepCount', type='number', min='0', step='0.01', value='{ parseFloat(item.stepCount) }')
                    .row
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Вес
                                input.form-control(name='weight', type='number', min='0.000', step='1.000', value='{ item.weightEdit ? parseFloat(item.weightEdit) : "" }',
                                    onkeyup='{ weightClick }', placeholder='0,000')
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Редакт. вес
                                select.form-control(name='idWeightEdit', value='{ item.idWeightEdit }', onchange='{ idWeightEditChange }')
                                    option(each='{ c, i in weights }', value='{ c.id }',
                                    selected='{ c.id == item.idWeightEdit }', no-reorder) { c.name }
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Отображ. вес
                                select.form-control(name='idWeightView', value='{ item.idWeightView }')
                                    option(each='{ c, i in weights }', value='{ c.id }',
                                    selected='{ c.id == item.idWeightView }', no-reorder) { c.name }

                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Объем
                                input.form-control(name='volume', type='number', min='0.000', step='1.000', value='{ item.volumeEdit ? parseFloat(item.volumeEdit) : "" }',
                                    onkeyup='{ volumeClick }', placeholder='0,000')
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Редакт. объем
                                select.form-control(name='idVolumeEdit', value='{ item.idVolumeEdit }', onchange='{ idVolumeEditChange }')
                                    option(each='{ c, i in volumes }', value='{ c.id }',
                                    selected='{ c.id == item.idVolumeEdit }', no-reorder) { c.name }
                        .col-md-2.col-xs-6
                            .form-group
                                label.control-label Отображ.объем
                                select.form-control(name='idVolumeView', value='{ item.idVolumeView }')
                                    option(each='{ c, i in volumes }', value='{ c.id }',
                                    selected='{ c.id == item.idVolumeView }', no-reorder) { c.name }

                    .row
                        .col-md-12
                            .form-group
                                label.control-label Дополнительные категории
                                product-edit-additional-categories(name='crossGroups', value='{ item.crossGroups }')

                    .row
                        .col-md-12
                            .form-group
                                label.control-label Краткое описание
                                ckeditor(name='note', value='{ item.note }')
                                //textarea.form-control(rows='5', name='note',
                                //style='min-width: 100%; max-width: 100%;', value='{ item.note }')

                    .row
                        .col-md-10
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='flagNew', checked='{ (item.flagNew == "Y") }', data-bool='Y,N')
                                        | Новый
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='flagHit', checked='{ (item.flagHit == "Y") }', data-bool='Y,N')
                                        | Хит
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='specialOffer', checked='{ (item.specialOffer == "Y") }', data-bool='Y,N')
                                        | Спец.
                                checkbox-list-inline(items='{ item.labels }')
                    .row
                        .col-md-10
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='enabled', checked='{ (item.enabled == "Y") }', data-bool='Y,N')
                                        | Отображать на сайте
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='isMarket', checked='{ item.isMarket }')
                                        | Выгрузка Яндекс.Маркет
                                .checkbox-inline(if='{ item.isMarket }')
                                    label
                                        input(type='checkbox', name='marketAvailable', checked='{ item.marketAvailable }')
                                        | В наличии на Яндекс.Маркет
                    .col-md-2
                            .form-group
                                label.control-label Популярность
                                    input.form-control(name='sort', type='number', step='1', value='{ item.sort }')



            // Полный текст
            #product-edit-full-text.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    description-tabs(name='text', value='{ item.text }')

            // Редактирование изображений продукта
            #product-edit-images.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    product-edit-images(name='images', value='{ item.images }', section='shopprice')

            // Цены на изменение продукта
            #product-edit-prices.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-3.col-xs-6
                            .form-group
                                label.control-label Закупочная цена
                                input.form-control(name='pricePurchase', type='number', min='0', step='0.01', value='{ parseFloat(item.pricePurchase) }')
                        .col-md-3.col-xs-6
                            .form-group
                                label.control-label Мелкий опт
                                input.form-control(name='priceOpt', type='number', min='0', step='0.01', value='{ parseFloat(item.priceOpt) }')
                        .col-md-3.col-xs-6
                            .form-group
                                label.control-label Опт
                                input.form-control(name='priceOptCorp', type='number', min='0', step='0.01', value='{ parseFloat(item.priceOptCorp) }')
                        .col-md-3.col-xs-6
                            .form-group
                                label.control-label Балловая стоимость
                                input.form-control(name='bonus', type='number', min='0', step='0.01', value='{ parseFloat(item.bonus) }')


            // Параметры редактирования продукта
            #product-edit-parameters.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    product-edit-parameters(name='specifications', value='{ item.specifications }')
                        #{'yield'}(to='toolbar')
                            .form-group
                                .checkbox-inline
                                    label
                                        input(type='checkbox', name='isShowFeature', checked='{ parent.parent.item.isShowFeature }' )
                                        | Отображать на сайте
                            .form-group(if='{ parent.parent.productTypes.length }')
                                label.control-label Тип
                                select.form-control(onchange='{ parent.parent.parametersChange }')
                                    option(value='')
                                    option(each='{ type, i in parent.parent.productTypes }', value='{ type.id }') { type.name }
            #product-edit-options.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    product-edit-options(name='options', value='{ item.options }')
            // Модификации редактирования продукта
            #product-edit-modifications.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    product-edit-modifications(name='modifications', value='{ item.modifications }')

            // Продукт редактировать похожие продукты
            #product-edit-similar-products.tab-pane.fade
                .row
                    .col-md-12
                        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                            catalog-static(name='similarProducts', add='{ permission(addSimilarProducts, "products", "0010") }',
                            cols='{ productsCols }', rows='{ item.similarProducts }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') { row.id }
                                    datatable-cell(name='code') { row.code }
                                    datatable-cell(name='article') { row.article }
                                    datatable-cell(name='name') { row.name }
                                    datatable-cell(name='price') { row.price }

            // Сопутствующие продукты
            #product-edit-accompanying-products.tab-pane.fade
                .row
                    .col-md-12
                        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                            catalog-static(name='accompanyingProducts', cols='{ accompCols }',
                                rows='{ item.accompanyingProducts }', remove='true')
                                #{'yield'}(to='toolbar')
                                    button.btn.btn-primary(onclick='{ parent.addAccompanyingProducts }', type='button')
                                        i.fa.fa-plus
                                        |  Добавить товар
                                    button.btn.btn-primary(onclick='{ parent.addAccompanyingGroups }', type='button')
                                        i.fa.fa-plus
                                        |  Добавить группу

                                #{'yield'}(to='body')
                                    datatable-cell(name='type') { row.type }
                                    datatable-cell(name='name') { row.name }

            // Файлы редактирования продукта
            #product-edit-files.tab-pane.fade
                form(action='', method='POST')
                    product-files(name='files', value='{ item.files }', section='shopprice')



            // Редакторование скидок на продукт
            #product-edit-discounts.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    product-edit-discounts(name='discounts', value='{ item.discounts }')
                        #{'yield'}(to='toolbar')
                            .form-group
                                label.control-label Макс.скидка %
                                input.form-control(value='{ parent.parent.item.maxDiscount }', type="number" min='0', max='100')
                            .form-group
                                label.control-label Скидка
                                select.form-control.select(onchange='{ parent.parent.discountChange }')
                                    option(each='{ v, n in parent.parent.discountTypes }', value='{ v }',
                                    selected='{ v == parent.parent.parent.item.discount }', no-reorder) { n }


            // Редактировать товар seo
            #product-edit-seo.tab-pane.fade
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    .row
                        .col-md-12
                            .form-group
                                button.btn.btn-primary.btn-sm(each='{ seoTags }', title='{ note }', type='button'
                                onclick='{ seoTag.insert }', no-reorder) { name }
                            .form-group
                                label.control-label  Заголовок
                                input.form-control(name='title', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.title }')
                            .form-group
                                label.control-label  Ключевые слова
                                input.form-control(name='keywords', type='text',
                                onfocus='{ seoTag.focus }', value='{ item.keywords }')
                            .form-group
                                label.control-label  Описание
                                textarea.form-control(rows='5', name='description', onfocus='{ seoTag.focus }',
                                style='min-width: 100%; max-width: 100%;', value='{ item.description }')
            // Отзывы о продукте
            #product-edit-reviews.tab-pane.fade
                .row
                    .col-md-12
                        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                            catalog-static(name='reviews', dblclick='{ editReview }',
                            cols='{ reviewsCols }', rows='{ item.reviews }', remove='true')
                                #{'yield'}(to='body')
                                    datatable-cell(name='date') { row.date }
                                    datatable-cell(name='nameUser') { row.nameUser }
                                    datatable-cell(name='mark')
                                        star-rating(count='5', value='{ row.mark }')
                                    datatable-cell(name='likes') { row.likes }
                                    datatable-cell(name='dislikes') { row.dislikes }
                                    datatable-cell(name='comment') { row.comment }
                                    datatable-cell(name='merits') { row.merits }
                                    datatable-cell(name='demerits') { row.demerits }
            // Поля редактирования продукта
            #product-edit-fields.tab-pane.fade(if='{ item.customFields }')
                form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                    add-fields-edit-block(name='customFields', value='{ item.customFields }')

    style(scoped).
        .color {
            height: 12px;
            width: 12px;
            display: inline-block;
            border: 1px solid #ccc;
        }
        a.fa span {
            font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;;
        }

    script(type='text/babel').
        var self = this

        self.app = app
        self.item = {}
        self.currencies = []
        self.seoTags = []
        self.loader = false
        self.error = false

        self.wieghts = []
        self.volumes = []

        self.seoTag = new app.insertText()

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }


        // клик по весу
        self.weightClick = function(e) {
            if (isNaN(e.target.value))
                e.target.v = 0

            self.item.weightEdit = e.target.value
            self.item.weight  = self.item.weightEdit / self.rateMeasure(self.weights, self.item.idWeightEdit)
            console.log(self.item.weightEdit)

        }

        // изменение веса (обработка) [при совершении события отпускания кнопки мыши]
        self.idWeightEditChange = e => {
            self.item.idWeightEdit = e.target.value
            self.item.weightEdit  = self.rateMeasure(self.weights, self.item.idWeightEdit) * self.item.weight
            self.update()
        }

        // изменение объемы (обработка) [при совершении события отпускания кнопки мыши]
        self.idVolumeEditChange = e => {
            self.item.idVolumeEdit = e.target.value
            self.item.volumeEdit  = self.rateMeasure(self.volumes, self.item.idVolumeEdit) * self.item.volume
            self.update()
        }

        // получение ед измерения
        self.rateMeasure = (items, id) => {
            var res = 1
            items.forEach(item => {
                if (id == item.id) {
                    res = item.value
                }
            })
            return res
        }

        // клик по объему
        self.volumeClick = e => {
            if (!isNaN(e.target.value)) {
                self.item.volumeEdit = e.target.value
                self.item.volume  = self.item.volumeEdit / self.rateMeasure(self.volumes, self.item.idVolumeEdit)
            }
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.productsCols = [
            {name: 'id', value: '#'},
            {name: 'code', value: 'Код'},
            {name: 'article', value: 'Артикул'},
            {name: 'name', value: 'Наименование'},
            {name: 'price', value: 'Цена'},
        ]

        self.accompCols = [
            {name: 'type', value: 'Тип'},
            {name: 'name', value: 'Наименование'},
        ]

        self.reviewsCols = [
            {name: 'date', value: 'Дата/время'},
            {name: 'nameUser', value: 'Пользователь'},
            {name: 'mark', value: 'Звёзд'},
            {name: 'likes', value: 'Лайков'},
            {name: 'dislikes', value: 'Дислайков'},
            {name: 'comment', value: 'Отзыв'},
            {name: 'merits', value: 'Достоинства'},
            {name: 'demerits', value: 'Недостатки'}
        ]

        // скидка вкл/выкл
        self.discountTypes = {
            'Y': 'Включена',
            'N': 'Отключена'
        }

        // Скидка Изменить
        self.discountChange = e => {
            self.item.discount = e.target.value
        }

        // Добавить похожие продукты
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

        // Добавить сопроводительные продукты
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
                            item.type = "Товар"
                            self.item.accompanyingProducts.push(item)
                        }
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        // Добавить сопроводительные группы
        self.addAccompanyingGroups = () => {
            modals.create('group-select-modal', {
                type: 'modal-primary',
                submit() {
                    self.item.accompanyingProducts = self.item.accompanyingProducts || []

                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                    let ids = self.item.accompanyingProducts.map(item => item.idGroup)

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1) {
                            let group = {}
                            group.idGroup = item.id
                            group.type = "Группа"
                            group.name = item.name
                            self.item.accompanyingProducts.push(group)
                        }
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }


        // Наличие изменений
        self.presenceChange = e => {
            if (e.target.checked)
                self.item.presenceCount = -1
            else
                self.item.presenceCount = 0
        }

        // Отправить
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

                // запрос на сохранение товара
                API.request({
                    object: 'Product',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Товар сохранен!', style: 'popup-success'})
                        if (self.isClone)
                        riot.route(`/products/${self.item.id}`)
                        if (self.isMulti)
                        riot.route(`/products`)
                        observable.trigger('products-reload')
                    },
                    complete() {
                        self.loader = false
                        self.update()
                    }
                })
            }
        }

        // Выбор группы
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

        // Удалить группу
        self.removeGroup = e => {
            self.item.idGroup = 0
            self.item.nameGroup = ''
        }

        // Выберите бренд
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

        // Удалить бренд
        self.removeBrand = e => {
            self.item.idBrand = null
            self.item.nameBrand = ''
        }

        // Редактировать обзор
        self.editReview = e => {
            riot.route(`/reviews/${e.item.row.id}`)
        }

        // перевести
        self.translite = e => {
            var params = {vars:[self.item.name]}
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



        // Изменение параметров
        self.parametersChange = e => {
            if (parseInt(e.target.value)) {
                API.request({
                    object: 'ProductType',
                    method: 'Items',
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


        // Получить продукт
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

                // получение ед измерения (Сравнивает/вычисляет?)
                }, callback => {
                    API.request({
                        object: 'Measure',
                        method: 'Info',
                        data: {},
                        success(response) {
                            self.weights = response.weights
                            self.volumes = response.volumes
                            callback(null, 'Measures')
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
                }, callback => {
                    API.request({
                        object: 'ProductType',
                        method: 'Fetch',
                        success(response) {
                            self.productTypes = response.items
                            callback(null, 'ProductType')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }
            ], (err, res) => {
                    if (typeof callback === 'function')
                        callback.bind(this)()
            })
        }


        // перезагружать
        self.reload = () => {
            observable.trigger('products-edit', self.item.id)
        }

        // Продукты-редактировать
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

        // продукты-клон
        observable.on('products-clone', id => {
            self.error = false
            self.isMulti = false
            self.isClone = true
            self.loader = true
            self.update()

            // Получить продукт
            getProduct(id, () => {
                self.loader = false
                delete self.item.id
                delete self.item.article
                self.item.images.forEach(item => {
                    delete item.id
                })
                self.item.modifications.forEach(item => {
                    item.items.forEach(mod => {
                        delete mod.article
                    })
                })

                self.update()
            })
        })

        // Автовключение СКИДКИ в товаре при добавлении новой
        // событие в product-edit-discounts.tag | observable.trigger('discount-on')
        observable.on('discount-on', () => {
            self.item.discount = 'Y'
            self.update()
        })

        // Продукты-мульти-редактирование
        observable.on('products-multi-edit', ids => {
            self.error = false
            self.isMulti = true
            self.isClone = false
            self.item = {}
            self.multiIds = ids
            self.update()
        })

        self.on('update', () => {
            localStorage.setItem('SE_section', 'shopprice')
        })

        self.on('mount', () => {
            riot.route.exec()
        })
