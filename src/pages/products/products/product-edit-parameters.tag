product-edit-parameters
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', add='{ addParameters }', handlers='{ parametersHandlers }',
            cols='{ parametersCols }', rows='{ value }', responsive='false')
                #{'yield'}(to='toolbar')
                    #{'yield'}(from='toolbar')
                #{'yield'}(to='body')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='value')
                        input.form-control(if='{ row.type == "number" }', value='{ row.value }', type='number', min='0.00',
                        oninput='{ handlers.changeValue }')
                        i.fa.fa-fw(if='{ row.type == "bool" }', onclick='{ handlers.toggleCheckbox }',
                        class='{ row.value ? "fa-check-square-o" : "fa-square-o" }')
                        input.form-control(if='{ row.type == "string" }', value='{ row.value }', type='text',
                        oninput='{ handlers.changeValue }')
                        autocomplete(if='{ row.type == "colorlist" }', load-data='{ handlers.getOptions(row.idFeature) }',
                        value='{ row.idValue }', value-field='value', id-field='id', onchange='{ handlers.changeColorValue }')
                            i.color(style='background-color: \#{ item.color };')
                            | &nbsp;&nbsp;{ item.value }
                        autocomplete(if='{ row.type == "list" }', load-data='{ handlers.getOptions(row.idFeature) }',
                        value='{ row.idValue }', value-field='value', id-field='id', onchange='{ handlers.changeColorValue }')
                            | { item.value }

    script(type='text/babel').
        var self = this

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value || []
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.parametersCols = [
            {name: 'name', value: 'Наименование'},
            {name: 'value', value: 'Значение'},
        ]

        self.addParameters = e => {
            modals.create('parameters-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.value = self.value || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.value.map(item => {
                        return item.idFeature
                    })

                    items.forEach(function (item) {
                        if (ids.indexOf(item.id) === -1) {
                            self.value.push({
                                idFeature: item.id,
                                name: item.name,
                                type: item.type
                            })
                        }
                    })

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.parametersHandlers = {
            getOptions(id) {
                var id = id
                return function () {
                    var _this = this
                    return API.request({
                        object: 'FeatureValue',
                        method: 'Fetch',
                        data: {filters: {field: 'idFeature', value: id}},
                        success(response) {
                            _this.data = response.items
                            if (!_this.isOpen) {
                                _this.data.forEach(item => {
                                    if (item[_this.idField] == _this.opts.value) {
                                        _this.filterValue = item[_this.valueField]
                                    }
                                })
                            }
                            _this.update()
                        }
                    })
                }
            },
            toggleCheckbox(e) {
                this.row.value = !this.row.value
            },
            changeValue(e) {
                var selectionStart = e.target.selectionStart
                var selectionEnd = e.target.selectionEnd

                this.row.value = e.target.value

                this.update()
                e.target.selectionStart = selectionStart
                e.target.selectionEnd = selectionEnd
            },
            changeColorValue(e) {
                this.row.idValue = this.row.valueIdList = e.target.value
            },
            changeListValue(e) {
                this.row.idValue = this.row.valueIdList = e.target.value
            }
        }

        self.on('update', () => {
            if ('value' in opts)
                self.value = opts.value || []

            if ('name' in opts)
                self.root.name = opts.name
        })

