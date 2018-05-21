| import parallel from 'async/parallel'


product-edit-options
    .row
        .col-md-12
            .form-inline.m-b-3
                .form-group
                    button.btn.btn-primary(type='button', onclick='{ addOption }')
                        i.fa.fa-plus
                        |  Добавить опции
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
            product-edit-option-values(if='{ value.length > 0 }', value='{ value[activeTab] }')

    script(type='text/babel').
        var self = this

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

        self.addOption = () => {
            modals.create('product-edit-options-select-modal', {
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
                        item.columns = [{id: item.id, name: item.name }]
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

            if (opts.name)
                self.root.name = opts.name
        })

product-edit-option-values
    .form-inline.m-b-3
        .form-group
            button.btn.btn-primary(type='button', onclick='{ addValue }')
                i.fa.fa-plus
                |  Добавить
        .form-group
            button.btn.btn-danger(if='{ selectedCount }', onclick='{ remove }', title='Удалить', type='button')
                i.fa.fa-trash { (selectedCount > 1) ? "&nbsp;" : "" }
                span.badge(if='{ selectedCount > 1 }') { selectedCount }

    .table-responsive
        .col-sm-6
            datatable(cols='{ cols }', rows='{ items }', handlers='{ handlers }')
                datatable-cell(each='{ item, i in parent.parent.newCols }', name='{ item.name }') { row.values[i].value }
                datatable-cell(name='name', style="width: 60%") { row.name }
                datatable-cell(name='priceValue')
                    input(name='priceValue', type='number', min='-1000000', step='0.01', value='{ row.priceValue }', onchange='{ handlers.change }')
                datatable-cell(name='isDefault')
                    i.fa.fa-fw(onclick='{ handlers.toggleCheckbox }',
                    class='{ row.isDefault ? "fa-check-square-o" : "fa-square-o" }')


    bs-pagination(if='{ value.items.length > pages.limit }', name='paginator',
    onselect='{ pages.change }', pages='{ pages.count }', page='{ pages.current }')

    script(type='text/babel').
        var self = this

        self.items = []

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

        self.сols = [
            {name: 'name', value: 'Наименование'},
            {name: 'priceValue', value: 'Цена'},
            {name: 'isDefault', value: 'По умолчанию'},
        ]

        self.addValue = () => {
            modals.create('product-edit-option-values-add-modal', {
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
                        var fl = false

                        self.value.items.forEach(item => {
                            if (item.idOptionValue == values[0].id) {
                                //console.log(item.idOptionValue, values[0].id)
                                fl = true;
                            }
                        })
                        if (!fl) {
                            self.value.items.push({
                                name: values[0].name,
                                idOptionValue: values[0].id,
                                priceValue: values[0].price,
                                isDefault: 0
                            })
                        }
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
            toggleCheckbox(e) {
                this.row.isDefault = !this.row.isDefault
                this.update()
            },
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
            }
        }

        self.on('update', () => {
            if (opts.value) {
                if (self.value !== opts.value)
                    self.selectedCount = 0

                self.value = opts.value
                self.items = self.getPageItems() || []
            }
        })

        self.one('updated', () => {
            self.tags.datatable.on('row-selected', count => {
                self.selectedCount = count
                self.update()
            })
        })

product-edit-options-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Опции
        #{'yield'}(to="body")
            catalog(object='Option', cols='{ parent.cols }', remove='{ parent.remove }', dblclick='{ parent.opts.submit.bind(this) }',
            reload='true', handlers='{ parent.handlers }', before-success='{ parent.opts.beforeSuccess }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='type', style='width: 150px;') { row.groupName }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'Options'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'groupName', value: 'Группа'},
        ]


product-edit-option-values-add-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить значения
        #{'yield'}(to="body")
            div(each='{ table, i in parent.items }')
                h4 { table.name }
                datatable(cols='{ table.cols }', rows='{ table.items }')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') OK
    script(type='text/babel').
        var self = this

        self.columns = opts.columns || []
        self.items = []
        self.initCols = [
            {name: 'id', value: '#', width: '60px'},
        ]

        var request = function (index, id) {
            return (callback) => {
                API.request({
                    object: 'OptionItems',
                    method: 'Fetch',
                    data: {filters: {field: 'idOption', value: id}},
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



