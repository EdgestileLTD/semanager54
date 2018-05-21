| import 'pages/images/image-select.tag'
| import 'pages/products/products/products-list-select-modal.tag'
| import 'pages/news/news-list-select-modal.tag'

section-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#sections') #[i.fa.fa-chevron-left]
            button.btn(if='{ isNew ? checkPermission("news", "0100") : checkPermission("news", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Добавление содержания' : item.name || 'Редактирование содержания' }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-2
                    .form-group
                        .well.well-sm
                            image-select(name='picture', alt='0', size='256', section='sections' , value='{ item.picture }')

                .col-md-10
                    .row
                        .col-md-12
                            .form-group(class='{ has-error: error.name }')
                                label.control-label Заголовок
                                input.form-control(name='name', type='text', value='{ item.name }')
                                .help-block { error.name }
                    .row(if="{ item.type == 'url' }")
                        .col-md-12
                            .form-group
                                label.control-label URL
                                input.form-control(name='url', type='text', value='{ item.url }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Тип элемента
                                select.form-control(name='type', onchange='{ menuSelect }', value="{ item.type }")
                                    option(each="{ type, index in itemTypes }", value="{ type.code }", selected='{ type.code == item.type }', no-reorder) { type.value }
                        .col-md-6(if="{ item.type == 'idPrice' }")
                            .form-group
                                label.control-label Выберите товар
                                .input-group
                                    input.form-control(name='priceName',
                                    value='{ item.priceName }', data-value="{ item.idPrice }" , readonly)
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ itemsHandlers.selectProducts }')
                                            i.fa.fa-list
                        .col-md-6(if="{ item.type == 'idGroup' }")
                            .form-group
                                label.control-label Выберите категорию товаров
                                .input-group
                                    input.form-control(name='nameGroup', value='{ item.nameGroup }', data-value="{ item.idGroup }" , readonly)
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ itemsHandlers.selectGroup }')
                                            i.fa.fa-list
                        .col-md-6(if="{ item.type == 'idBrand' }")
                            .form-group
                                label.control-label Выберите бренд товаров
                                .input-group
                                    input.form-control(name='nameBrand', value='{ item.nameBrand }', data-value="{ item.idBrand }" , readonly)
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ itemsHandlers.selectBrand }')
                                            i.fa.fa-list
                        .col-md-6(if="{ item.type == 'idNew' }")
                            .form-group
                                label.control-label Выберите новость
                                .input-group
                                    input.form-control(name='nameNews', value='{ item.nameNews }', data-value="{ item.idNew }" , readonly)
                                    .input-group-btn
                                        .btn.btn-default(onclick='{ itemsHandlers.selectNews }')
                                            i.fa.fa-list

            .row
                .col-md-12
                    .form-group
                        label.control-label Текст примечания
                        ckeditor(name='note', value='{ item.note }')
            .row
                .col-md-12
                    .form-group
                        label.control-label Подробный текст
                        ckeditor(name='text', value='{ item.text }')

            .row
                .col-md-12
                    .form-group
                        .checkbox-inline
                            label
                                input(type='checkbox', name='enabled', checked='{ item.enabled }')
                                | Отображать на сайте



    script(type='text/babel').
        var self = this

        self.isNew = false

        self.item = {}
        self.orders = []

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            name: 'empty'
        }

        self.itemTypes = [
            { code: 'idPrice', value: 'Товар'},
            { code: 'idGroup', value: 'Категория товара'},
            { code: 'idBrand', value: 'Бренд'},
            { code: 'idNew',   value: 'Новость'},
            { code: 'url',     value: 'Ссылка'},
        ]

        self.itemsHandlers = {
            selectProducts() {
                modals.create('products-list-select-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        let _this = this
                        let items = _this.tags.catalog.tags.datatable.getSelectedRows()
                        self.item.items = self.item.items || []


                        if (items.length == 1) {
                            self.item.idPrice = items[0].id
                            self.item.priceName = items[0].name
                            self.update()
                        }
                        this.modalHide()
                        _this.modalHide()
                    }
                })
            },
            selectGroup () {
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
            },
            selectBrand(){
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
            },
            selectNews(){
                modals.create('news-list-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        let items = this.tags.catalog.tags.datatable.getSelectedRows()
                        self.item.idNew = items[0].id
                        self.item.nameNews = items[0].title
                        self.update()
                        this.modalHide()
                    }
                })
            }
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = e => {
            var params = self.item

            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'SectionItem',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/sections/${self.item.id}`)
                        observable.trigger('section-reload')
                    }
                })
            }
        }

        self.menuSelect = (e) => {
            let type = self.item.type = e.target.value;
            if(type != 'idPrice'){
                self.item.priceName = null
            }
            self.itemTypes.forEach(function(elem){
                if(elem.code != 'url'){
                    if(elem.code != type){
                        self.item[elem.code] = null
                    }
                }
            })
        }


        observable.on('section-new', id => {
            self.error = false
            self.isNew = true
            self.item = {
                idSection: id,
                type: 'url'
            }
            self.update()
        })

        observable.on('section-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.loader = true
            self.item = {}

            API.request({
                object: 'SectionItem',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    if (!self.item.type) self.item.type='url'
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
            })
        })

        self.on('update', () => {
            localStorage.setItem('SE_section', 'sections')
        })
        self.reload = () => {
            self.item.id ? observable.trigger('section-edit', self.item.id) : observable.trigger('section-new')
        }

        self.on('mount', () => {
            riot.route.exec()
        })