| import 'components/catalog.tag'
| import 'pages/products/options/option-new-modal.tag'
| import 'pages/products/options/options-items-list.tag'


options-list
    .row
        .col-md-4
            catalog(
                name      = 'option',
                object    = 'Option',
                cols      = '{ colsOption }',
                allselect = 'true',
                reload    = 'true',
                filters   = '{ categoryFilters }',
                add       = '{ permission(add, "products", "0100") }',
                remove    = '{ permission(remove, "products", "0001") }',
                dblclick  = '{ permission(optionEdit, "products", "1000") }'
            )
                #{'yield'}(to='filters')
                    .well.well-sm
                        .form-inline
                            .form-group
                                label.control-label Группы
                                select.form-control(data-name='idGroup', onclick='{ parent.selectCategory }')
                                    option(value='') Все
                                    option(each='{ category, i in parent.optionCategories }', value='{ category.id }', no-reorder) { category.name }

                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='groupName') { row.groupName }

        .col-md-8.col-xs-12.col-sm-12
            options-items-list(name='optionList', filters='{ optionFilters }')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Option'
        self.optionFilters = false
        self.optionCategories = []

        var getFeaturesTypes = () => {
            API.request({
                object: 'Option',
                method: 'Fetch',
                data: {},
                success(response) {
                    self.featuresTypes = response.items
                    self.update()
                }
            })
        }

        var featureName = type => {
            for (var i = 0; i < self.featuresTypes.length; i++) {
                if (self.featuresTypes[i].code === type)
                    return self.featuresTypes[i].name
            }
        }

        self.optionEdit = e => {
            let item

            if (e.item && e.item.row)
                item = e.item.row

            modals.create('option-new-modal', {
                type: 'modal-primary',
                item: item,
                submit() {
                    var _this = this
                    var params = _this.item
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Option',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags['option'].reload();
                            }
                        })
                    }
                }
            })
        }

        self.add = () => {
            modals.create('option-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = _this.item
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Option',
                            method: 'Save',
                            data: params,
                            success(response) {
                                self.tags['option'].reload();
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

        self.colsOption = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'groupName', value: 'Группа'},
        ]


        self.handlers = {
            featureName: featureName
        }

        self.one('updated', () => {
            var datatable = self.tags['option'].tags.datatable
            datatable.on('row-selected', (count, row) => {
                    let items = datatable.getSelectedRows()
                    if (items.length > 0) {
                        let value = items.map(i => i.id).join(',')
                        self.optionFilters = [{field: 'idOption', sign: 'IN', value}]
                    } else {
                        self.optionFilters = false
                    }
                    self.update()
                    self.tags['optionList'].tags['optionItem'].reload()
            })
        })
        self.getOptionGroup = () => {
            API.request({
                object: 'OptionGroup',
                method: 'Fetch',
                success(response) {
                    self.optionCategories = response.items
                    self.update()
                }
            })
        }

        observable.on('options-groups-reload', () => {
            self.tags.catalog.reload()
        })


        self.getOptionGroup()
