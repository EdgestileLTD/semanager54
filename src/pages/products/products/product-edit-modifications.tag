| import parallel from 'async/parallel'
| import 'components/ckeditor.tag'
| import 'components/datatable.tag'
//| import 'pages/images/images-gallery-modal.tag'

product-edit-modifications
    .row
        .col-md-12
            .form-inline.m-b-3
                .form-group
                    button.btn.btn-primary(type='button', onclick='{ addGroup }')
                        i.fa.fa-plus
                        |  Добавить группу
                    #{'yield'}(to='toolbar')
                        #{'yield'}(from='toolbar')
    .row
        .col-md-12
            ul.nav.nav-tabs.m-b-2(if='{ value.length > 0 }')
                li(each='{ item, i in value }', class='{ active: activeTab === i }')
                    a(onclick='{ changeTab }')
                        span { item.name }
                        button.close(onclick='{ closeTab }', type='button')
                            span &times;

    .row
        .col-md-12
            product-edit-modifications-group(if='{ value.length > 0 }', value='{ value[activeTab] }', images='{ images }')

    script(type='text/babel').
        var self = this
        self.images = []
        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value
                self.update()
            }
        })

        self.activeTab = 0

        self.changeTab = e => {
            self.activeTab = e.item.i
        }

        self.closeTab = e => {
            e.stopPropagation()
            e.stopImmediatePropagation()
            self.value = self.value.slice(0, self.value.length)
            self.value.splice(e.item.i, 1)

            if (e.item.i <= self.activeTab)
                if (self.activeTab > 0)
                    self.activeTab -= 1

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event)
        }

        self.addGroup = () => {
            modals.create('product-edit-modifications-group-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                beforeSuccess(response, xhr) {
                    if (self.value &&
                        self.value instanceof Array &&
                        self.value.length > 0) {
                        let ids = self.value.map(item => item.id)
                        let items = response.items.filter(item => {
                            return ids.indexOf(item.id) === -1
                        })

                        response.items = items
                    }
                },
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length > 0 && !(self.value instanceof Array))
                        self.value = []

                    items = items.map(item => {
                        item.items = []
                        return item
                    })

                    self.value = self.value.concat(items)

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)
                    this.modalHide()
                }
            })
        }

        self.on('update', () => {
            if (opts.value)
                self.value = opts.value
            if (opts.images)
                self.images = opts.images

            if (opts.name)
                self.root.name = opts.name
        })

product-edit-modifications-group
    .form-inline.m-b-3
        .form-group
            button.btn.btn-primary(type='button', onclick='{ addModification }')
                i.fa.fa-plus
                |  Добавить модификацию
        .form-group
            button.btn.btn-danger(if='{ selectedCount }', onclick='{ remove }', title='Удалить', type='button')
                i.fa.fa-trash { (selectedCount > 1) ? "&nbsp;" : "" }
                span.badge(if='{ selectedCount > 1 }') { selectedCount }

    .table-responsive
        datatable(cols='{ cols }', rows='{ items }', handlers='{ handlers }')
            datatable-cell(each='{ item, i in parent.parent.newCols }', name='{ item.name }') { row.values[i].value }
            datatable-cell(name='article', style="width-max: 150px;")
                input(name='article', value='{ row.article }', onchange='{ handlers.change }')
            datatable-cell(name='count', style="width-max: 80px;")
                input(name='count', type='number', min='-1', value='{ row.count }', onchange='{ handlers.change }')
            datatable-cell(name='priceRetail', style="width-max: 100px;")
                input(name='priceRetail', type='number', min='0', step='0.01', value='{ row.priceRetail }', onchange='{ handlers.change }')
            datatable-cell(name='priceSmallOpt', style="width-max: 100px;")
                input(name='priceSmallOpt', type='number', min='0', step='0.01', value='{ row.priceSmallOpt }', onchange='{ handlers.change }')
            datatable-cell(name='priceOpt', style="width-max: 100px;")
                input(name='priceOpt', type='number', min='0', step='0.01', value='{ row.priceOpt }', onchange='{ handlers.change }')
            datatable-cell(name='description')
                input(name='description', value='{ row.description }', onchange='{ handlers.change }')
            datatable-cell(name='id', onclick='{ handlers.edit }')
                i.fa.fa-edit
                |  Настроить






    bs-pagination(if='{ value.items.length > pages.limit }', name='paginator',
    onselect='{ pages.change }', pages='{ pages.count }', page='{ pages.current }')

    script(type='text/babel').
        var self = this

        self.cols = []
        self.items = []
        self.images = []

        self.pages = {
            count: 0,
            current: 1,
            limit: 15,
            change(e) {
                self.pages.current = e.currentTarget.page
            }
        }

        self.getPageItems = () => {
            let count = self.value.items.length

            self.pages.count = Math.ceil(count / self.pages.limit)

            if (self.pages.current > self.pages.count) {
                self.pages.current = self.pages.count
            }

            self.pages.current = self.pages.current == 0 ? 1 : self.pages.current

            let offset = (self.pages.current - 1) * self.pages.limit
            let end = offset + self.pages.limit

            let items = self.value.items.filter((item, i) => (i > offset - 1 && i < end))

            return items
        }

        self.initCols = [
            {name: 'article', value: 'Артикул'},
            {name: 'count', value: 'Кол-во'},
            {name: 'priceRetail', value: 'Розница'},
            {name: 'priceSmallOpt', value: 'Малый опт'},
            {name: 'priceOpt', value: 'Опт'},
            {name: 'description', value: 'Описание'},
            {name: 'id', value: ''},
        ]


        self.addModification = () => {
            modals.create('product-edit-modifications-add-modal', {
                type: 'modal-primary',
                columns: self.value.columns,
                submit() {
                    let getIndexs = (counts = [], index = 0) => {
                        let count = counts.reduce((p, c) => p * c)
                        index = index > count ? count : index
                        let result = []

                        counts.reduceRight((p, c, i) => {
                            result[i] = p % c
                            return Math.floor(p / c)
                        }, index)

                        return result
                    }

                    let getValues = (items, indexs) => {
                        return items.map((item, i) => {
                            return item[indexs[i]]
                        })
                    }

                    let items = []

                    if (this.tags.datatable instanceof Array) {
                        this.tags.datatable.forEach(item => {
                            items.push(item.getSelectedRows())
                        })
                    } else {
                        items.push(this.tags.datatable.getSelectedRows())
                    }

                    let counts = items.map(item => item.length)
                    let count = counts.reduce((p, c) => p * c)
                    count = count > 1000 ? 1000 : count

                    for(let i = 0; i < counts.length; i++) {
                        if (counts[i] == 0) {
                            popups.create({
                                style: 'popup-danger',
                                title: 'Ошибка',
                                text: 'Должны быть выбраны один или несколько пунктов в каждой категории',
                                timeout: 0
                            })
                            return
                        }
                    }

                    for(let i = 0; i < count; i++) {
                        let indexs = getIndexs(counts, i)
                        let values = getValues(items, indexs)
                        self.value.items.push({
                            article: self.parent.parent.item.article,
                            count: -1,
                            priceRetail: 0,
                            priceSmallOpt: 0,
                            priceOpt: 0,
                            description: '',
                            values
                        })
                    }

                    this.modalHide()
                    self.update()
                }
            })
        }

        self.remove = () => {
            self.selectedCount = 0

            let items = self.tags.datatable.getSelectedRows()

            self.value.items = self.value.items.filter(item => {
                return items.indexOf(item) === -1
            })
        }

        self.handlers = {
            change(e) {
                if (!e.target.name) return

                var bannedTypes = ['checkbox', 'file', 'color', 'range', 'number']

                if (e.target && bannedTypes.indexOf(e.target.type) === -1) {
                    var selectionStart = e.target.selectionStart
                    var selectionEnd = e.target.selectionEnd
                }

                if (e.target && e.target.type === 'checkbox' && e.target.name)
                    e.item.row[e.target.name] = e.target.checked
                if (e.target && e.target.type !== 'checkbox' && e.target.name)
                    e.item.row[e.target.name] = e.target.value
                if (e.currentTarget.tagName !== 'FORM' && e.currentTarget.name !== '')
                    e.item.row[e.currentTarget.name] = e.currentTarget.value

                if (e.target && bannedTypes.indexOf(e.target.type) === -1) {
                    this.update()
                    e.target.selectionStart = selectionStart
                    e.target.selectionEnd = selectionEnd
                }
            },
            edit(e) {
                modals.create('product-edit-modifications-edit-modal', {
                    type: 'modal-primary',
                    item: e.item.row,
                    images: opts.images,
                    submit() {
                        e.item.row = this.item
                        this.modalHide()
                        self.update()
                    }
                })
            }
        }

        self.on('update', () => {
            if (opts.value) {
                if (self.value !== opts.value)
                    self.selectedCount = 0

                self.value = opts.value
                self.items = self.getPageItems() || []

                if (self.value.columns &&
                    self.value.columns instanceof Array) {

                    self.newCols = self.value.columns.map((item, i) => {
                        return { name: i, value: item.name }
                    })
                    self.newCols.sort(function(varA,varB){
                        return varA.id-varB.id
                    });

                    self.cols = self.newCols.concat(self.initCols)
                }
            }
            if (opts.images)
                self.images = opts.images
        })

        self.one('updated', () => {
            self.tags.datatable.on('row-selected', count => {
                self.selectedCount = count
                self.update()
            })
        })

product-edit-modifications-group-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Модификации
        #{'yield'}(to="body")
            catalog(object='Modification', cols='{ parent.cols }', remove='{ parent.remove }', dblclick='{ parent.opts.submit.bind(this) }',
            reload='true', handlers='{ parent.handlers }', before-success='{ parent.opts.beforeSuccess }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='type', style='width: 150px;') { handlers.types[row.vtype] }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'Modification'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'type', value: 'Тип ценообразования'},
        ]

        self.handlers = {
            types: {
                0: 'Добавляет к цене',
                1: 'Умножает на цену',
                2: 'Замещает цену',
            }
        }

product-edit-modifications-add-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить модификации
        #{'yield'}(to="body")
            div(each='{ table, i in parent.items }')
                h4 { table.name }
                datatable(cols='{ table.cols }', rows='{ table.items }')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='value') { row.value }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') OK
    script(type='text/babel').
        var self = this

        self.columns = opts.columns
        self.items = []
        self.initCols = [
            {name: 'id', value: '#', width: '60px'},
        ]

        var request = function (index, id) {
            return (callback) => {
                API.request({
                    object: 'FeatureValue',
                    method: 'Fetch',
                    data: {filters: {field: 'idFeature', value: id}},
                    success(response) {
                        let { id: name, name: value } = self.columns[index]

                        self.columns[index].items = response.items
                        self.columns[index].cols = self.initCols.concat([{name, value}])
                        self.items[index] = self.columns[index]

                        callback(null, 'success')
                    },
                    error(response) {
                        callback('error', null)
                    }
                })
            }
        }

        self.on('mount', () => {
            let requests = self.columns.map((item, i) => {
                return new request(i, item.id)
            })

            parallel(requests, (err, res) => {
                self.update()
            })
        })
product-edit-modifications-images-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Выбрать из библиотеки
        #{'yield'}(to="body")
            .row
                .col-md-12
                    catalog-static(name='gallery', cols='{ cols }', rows='{ value }',
                    catalog='{ catalog }', upload='{ upload }')
                        //#{'yield'}(to='toolbar')
                            //.form-group(if='{ checkPermission("images", "0100") }')
                                .input-group(class='btn btn-primary btn-file')
                                    input(name='files', onchange='{ opts.upload }', type='file', multiple='multiple', accept='image/*')
                                    i.fa.fa-plus
                                    |  Добавить
                            //.form-group(if='{ checkPermission("images", "1000") }')
                                button.btn.btn-success(onclick='{ opts.catalog }', type='button')
                                    i.fa.fa-picture-o
                                    |  Каталог
                        #{'yield'}(to='body')
                            datatable-cell(name='', style='width: 100px;')
                                img(src='{ row.imageUrlPreview }', style='max-width: 64px;')
                            datatable-cell(name='')
                                p.form-control-static { row.imageFile }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this
        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.cols = [
                {name: '', value: 'Картинка'},
                {name: '', value: 'Наименование'},
            ]
            if ('value' in opts){
                modal.value = opts.value || []
                console.log(modal.value)
                modal.update()
            }
        })

product-edit-modifications-list-images
    catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ value }',
    catalog='{ catalog }', upload='{ upload }', remove='true', reorder='true')
        #{'yield'}(to='toolbar')
            //.form-group(if='{ checkPermission("images", "0100") }')
                .input-group(class='btn btn-primary btn-file')
                    input(name='files', onchange='{ opts.upload }', type='file', multiple='multiple', accept='image/*')
                    i.fa.fa-plus
                    |  добавить
            .form-group(if='{ checkPermission("images", "1000") }')
                button.btn.btn-success(onclick='{ opts.catalog }', type='button')
                    i.fa.fa-picture-o
                    |  выбрать
        #{'yield'}(to='body')
            datatable-cell(name='', style='width: 100px;')
                img(src='{ row.imageUrlPreview }', style='max-widt: 40px;')
            datatable-cell(name='')
                p.form-control-static { row.imageFile }
    script(type='text/babel').
        var self = this
        self.mixin('permissions')
        self.value = []
        self.newIndex = -1
        self.oldIndex = -1

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
                set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.cols = [
            {name: '', value: 'Картинка'},
            {name: '', value: 'Наименование'},
        ]

        self.catalog = e => {
            //console.log(self.images)
            modals.create('product-edit-modifications-images-modal', {
                type: 'modal-primary',
                value: self.images,
                submit() {
                    self.value = self.value || []
                    var sort = 0;
                    self.value.forEach(item => {
                        if (item.sortIndex > sort) sort = item.sortIndex
                    })
                    this.tags.gallery.items.forEach(item => {
                        if (item.__selected__) {
                            var find = false
                            self.value.forEach(item1 => {
                                if (item1.id == item.id) find = true
                            })
                            if (!find) {
                                self.value.push({
                                    id: item.id,
                                    imageFile: item.imageFile,
                                    imageUrlPreview: item.imageUrlPreview,
                                    imageUrl: item.imageUrl,
                                    sortIndex: sort + 1
                                })
                            }
                        }
                    })
                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    //console.log(self.value)

                    self.update()
                    this.modalHide()
                }
            })
        }
        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('images' in opts)
                self.images = opts.images || []

            if ('value' in opts && !self.value)
                self.value = opts.value || []

        })
        self.on('updated', () => {
            self.tags['catalog-static'].tags.datatable.on('reorder-end', (newIndex, oldIndex) => {
                if (newIndex === self.newIndex && oldIndex === self.oldIndex){
                    return false
                }

                //console.log(newIndex, oldIndex, self.newIndex, self.oldIndex)
                self.newIndex = newIndex
                self.oldIndex = oldIndex

                self.tags['catalog-static'].value.splice(newIndex, 0, self.tags['catalog-static'].value.splice(oldIndex, 1)[0])
                var temp = self.tags['catalog-static'].value
                self.rows = []
                self.update()

                self.tags['catalog-static'].value = temp

                self.tags['catalog-static'].items.forEach((item, sort) => {
                    item.sortIndex = sort
                })

            })
        })


product-edit-modifications-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Настроить модификацию
        #{'yield'}(to="body")
            form(action='', onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-12
                        product-edit-modifications-list-images(name='images', value='{ item.images }', images='{ images }')
                hr
                .row
                    .col-md-12
                        .form-group
                            label.control-label Описание
                            ckeditor(name='description', value='{ item.description }')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Применить

    script(type='text/babel').
        var self = this
        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.mixin('change')
            modal.item = opts.item || {}
            modal.images = opts.images || {}
            self.update()
        })















