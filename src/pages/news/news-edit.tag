| import 'components/tags.tag'
| import './new-categories-list-modal.tag'
| import 'pages/settings/geotargeting/geotargeting-list-modal.tag'

news-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#news') #[i.fa.fa-chevron-left]
            button.btn(if='{ isNew ? checkPermission("news", "0100") : checkPermission("news", "0010") }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4  { isNew ? item.name || 'Добавление новости' : item.name || 'Редактирование новости' }

        ul.nav.nav-tabs.m-b-2
            li.active: a(data-toggle='tab', href='#news-edit-home') Основная информация
            li: a(data-toggle='tab', href='#news-edit-images') Галерея
            li(if='{ item.customFields && item.customFields.length }')
                a(data-toggle='tab', href='#news-edit-fields') Доп. информация
            li: a(data-toggle='tab', href='#news-edit-subscribers') Группы подписчиков
            li: a(data-toggle='tab', href='#news-edit-seo') SEO

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #news-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-2
                            .form-group
                                .well.well-sm
                                    image-select(name='imageFile', section='newsimg', alt='0', size='256', value='{ item.imageFile }')
                        .col-md-10
                            .row
                                .col-md-8
                                    .form-group(class='{ has-error: error.name }')
                                        label.control-label Заголовок
                                        input.form-control(name='name', type='text', value='{ item.name }')
                                        .help-block { error.name }
                                .col-md-4
                                    .form-group(class='{ has-error: error.url }')
                                        label.control-label URL
                                        input.form-control(name='url', type='text', value='{ item.url }')
                                        .help-block { error.url }
                            .row
                                .col-md-2
                                    .form-group
                                        label.control-label Дата
                                        datetime-picker.form-control(name='newsDate', format='DD.MM.YYYY', value='{ item.newsDateDisplay }', title='Дата публикации')
                                .col-md-4
                                    .form-group
                                        label.control-label Категория
                                        .input-group
                                            input.form-control(name='nameCategory', value='{ item.nameCategory }', readonly)
                                            .input-group-btn
                                                .btn.btn-default(onclick='{ changeCategory }')
                                                    i.fa.fa-list.text-primary
                                .col-md-6
                                    .form-group
                                        label.control-label Регион
                                        .input-group
                                            tags.form-control(name='geoCity', value='{ item.geoCity }')
                                            span.input-group-addon(onclick='{ addCity }')
                                                i.fa.fa-plus
                            .row
                                .col-md-2
                                    .form-group
                                        .checkbox-inline
                                            label
                                                input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                                | Отображать на сайте
                                .col-md-4
                                    .form-group
                                        .checkbox-inline
                                            label
                                                input(type='checkbox', name='isDatePublic', checked='{ item.isDatePublic }')
                                                | Отложенная публикация
                                        .form-group(if='{ item.isDatePublic }')
                                            datetime-picker.form-control(name='publicationDate', format='DD.MM.YYYY', value='{ item.publicationDateDisplay }')


                    .row
                        .col-md-12
                            .form-group
                                label.control-label Анонс ({ countAnonse } из 500 знаков)
                                textarea.form-control.text-anonse(name='shortTxt', value='{ item.shortTxt }', oninput='{ changeCountAnonse }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Подробный текст
                                ckeditor(name='text', value='{ item.text }')


                #news-edit-images.tab-pane.fade
                    product-edit-images(name='images', value='{ item.images }', section='newsimg')

                #news-edit-fields.tab-pane.fade(if='{ item.customFields && item.customFields.length }')
                    add-fields-edit-block(name='customFields', value='{ item.customFields }')

                #news-edit-subscribers.tab-pane.fade
                    catalog-static(name='subscribersGroups', rows='{ item.subscribersGroups }', add='{ addSubscribersGroups }',
                    cols='{ subscribersGroupsCols }', remove='true')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }
                #news-edit-seo.tab-pane.fade
                    form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                        .row
                            .col-md-12
                                .form-group
                                    label.control-label  Заголовок
                                    input.form-control(name='seotitle', type='text',
                                    onfocus='{ seoTag.focus }', value='{ item.seotitle }')
                                .form-group
                                    label.control-label  Ключевые слова
                                    input.form-control(name='keywords', type='text',
                                    onfocus='{ seoTag.focus }', value='{ item.keywords }')
                                .form-group
                                    label.control-label  Описание
                                    textarea.form-control(rows='5', name='description', onfocus='{ seoTag.focus }',
                                    style='min-width: 100%; max-width: 100%;', value='{ item.description }')

    style.
        textarea.text-anonse {
            min-height: 100px;
        }
    script(type='text/babel').
        var self = this

        self.isNew = false

        self.item = {}
        self.orders = []

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.countAnonse = 0

        self.rules = {
            name: 'empty'
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
                    object: 'News',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                        self.item = response
                        self.update()
                        if (self.isNew)
                            riot.route(`/news/${self.item.id}`)
                        observable.trigger('news-reload')
                    }
                })
            }
        }

        self.changeCategory = () => {
            modals.create('new-categories-list-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0) {
                        self.item.idCategory = items[0].id
                        self.item.nameCategory = items[0].title
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.subscribersGroupsCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.changeCountAnonse = e => {
            var value = (e === undefined) ? self.item.shortTxt : e.target.value;
            value = value || ''
            self.countAnonse = value.length
        }

        self.addCity = () => {
            modals.create('geotargeting-list-modal', {
                type: 'modal-primary',
                submit() {
                    self.item.geoCity = self.item.geoCity || []
                    let items = this.tags.geotargeting.tags.datatable.getSelectedRows()
                    let ids = self.item.geoCity.map(item => {
                        return item.id
                    })

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1)
                            self.item.geoCity.push(item)
                    })
                    self.update()
                    this.modalHide()
                }
            })
        }



        self.addSubscribersGroups = () => {
            modals.create('persons-category-select-modal', {
                type: 'modal-primary',
                submit() {
                    self.item.subscribersGroups = self.item.subscribersGroups || []
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.item.subscribersGroups.map(item => {
                        return item.id
                    })

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1) {
                            self.item.subscribersGroups.push(item)
                        }
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        observable.on('news-new', item => {
            let { category, name } = item
            self.error = false
            self.isNew = true
            self.item = {
                publicationDate: (new Date()).toLocaleDateString(),
                publicationDateDisplay: (new Date()).toLocaleDateString(),
                idCategory: category,
                nameCategory: decodeURI(name)
            }
            self.update()
        })

        observable.on('news-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.loader = true
            self.item = {}

            API.request({
                object: 'News',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    self.loader = false
                    self.changeCountAnonse()
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
            localStorage.setItem('SE_section', 'newsimg')
        })

        self.reload = () => {
            self.item.id ? observable.trigger('news-edit', self.item.id) : observable.trigger('news-new')
        }

        self.on('mount', () => {
            riot.route.exec()
        })