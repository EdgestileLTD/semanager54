
| import 'components/datatable.tag'
| import 'pages/products/parameters/feature-new-edit-modal.tag'
| import 'pages/products/parameters/parameters-groups-list-modal.tag'

parameter-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#products/parameters') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("products", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { item.name || 'Редактирование параметра' }

        .tab-content
            form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
                .row
                    .col-md-3
                        .form-group(class='{ has-error: error.name }')
                            label.control-label Наименование
                            input.form-control(name='name', type='text', value='{ item.name }')
                            .help-block { error.name }
                    .col-md-2
                        .form-group
                            label.control-label Код (URL)
                            input.form-control(name='code', type='text', value='{ item.code }')
                    .col-md-3
                        .form-group
                            label.control-label Подсказка
                            input.form-control(name='placeholder', type='text', value='{ item.placeholder }')
                    .col-md-2
                        .form-group(class='{ has-error: error.type }')
                            label.control-label Тип переменной
                            select.form-control(name='type', value='{ item.type }')
                                option(each='{ feature, i in featuresTypes }', value='{ feature.code }') { feature.name }
                            .help-block { error.type }
                    .col-md-2
                        .form-group
                            label.control-label Единицы измерения
                            input.form-control(name='measure', type='text', value='{ item.measure }')
                .row
                    .col-md-3
                        .form-group
                            label.control-label Категория
                            .input-group
                                input.form-control(name='nameGroup', type='text', value='{ item.nameGroup }', readonly)
                                .input-group-btn
                                    .btn.btn-default(onclick='{ selectGroup }')
                                        i.fa.fa-list.text-primary
                .row
                    .col-md-12
                        .form-group
                            label.control-label Описание
                            textarea.form-control(rows='5', name='description',
                                style='min-width: 100%; max-width: 100%;', value='{ item.description }')
            .row(if='{ listTypes.indexOf(item.type) !== -1 }')
                .col-md-12
                    //catalog-static(rows='{ featureValues }', cols='{ featuresValuesCols }',
                    //dblclick='{ editFeatureValue }', add='{ addFeatureValue }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name')
                                i.color(if='{ parent.parent.parent.parent.item.valueType === "CL" }', style='background-color: \#{ row.color };')
                                | { row.name }
                    .form-group
                        label.control-label Список значений параметра
                        br
                        button.btn.btn-primary(onclick='{ addFeatureValue }', type='button')
                            i.fa.fa-plus
                            |  Добавить
                        button.btn.btn-danger(if='{ featuresSelectedCount }', onclick='{ removeFeatureValue }', title='Обновить', type='button')
                            i.fa.fa-trash { (featuresSelectedCount > 1) ? "&nbsp;" : "" }
                            span.badge(if='{ featuresSelectedCount > 1 }') { featuresSelectedCount }

                    datatable(name='features', cols='{ featuresValuesCols }', rows='{ item.values }',
                    dblclick='{ editFeatureValue }', reorder='true')
                        datatable-cell(name='value')
                            i.color(if='{ parent.parent.parent.item.type === "colorlist" }', style='background-color: \#{ row.color };')
                            | { row.value }
                        datatable-cell(name='code') { row.code }
            .row
                .col-md-12
                    .form-group
                        .checkbox
                            label
                                input(type='checkbox', name='isYAMarket', checked='{ item.isYAMarket }')
                                | Яндекс.Маркет

    style(scoped).
        .color {
            height: 12px;
            width: 12px;
            display: inline-block;
        }

    script(type='text/babel').
        var self = this
        
        self.item = {}
        self.listTypes = ['list', 'colorlist', 'check']
        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = {
            name: 'empty',
            type: 'empty'
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.featuresValuesCols = [
            //{name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'code', value: 'Код (URL)'},
        ]

        self.submit = e => {
            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'Feature',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Параметр сохранен!', style: 'popup-success'})
                        observable.trigger('parameters-groups-reload')
                        self.update()
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('parameters-edit', self.item.id)
        }

        self.addFeatureValue = () => {
            modals.create('feature-new-edit-modal', {
                type: 'modal-primary',
                color: self.item.type === 'colorlist',
                submit() {
                    var _this = this,
                        params = {}

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        params.idFeature = self.item.id
                        params.value = _this.item.value

                        if (_this.item.color)
                            params.color = _this.item.color

                        self.item.values = [params, ...self.item.values]
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.editFeatureValue = e => {
            modals.create('feature-new-edit-modal', {
                item: e.item.row,
                type: 'modal-primary',
                color: self.item.type === 'colorlist',
                submit() {
                    e.item.row = this.item
                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeFeatureValue = () => {
            self.item.values = self.tags.features.getUnselectedRows()
            self.update()
        }

        var getFeaturesTypes = () => {
            return API.request({
                object: 'FeatureType',
                method: 'Fetch',
                data: {},
                success(response) {
                    self.featuresTypes = response.items
                    self.update()
                }
            })
        }

        self.selectGroup = () => {
            modals.create('parameters-groups-list-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length) {
                        self.item.idFeatureGroup = items[0].id
                        self.item.nameGroup = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        observable.on('parameters-edit', id => {
            var params = {id: id}
            self.item = {}
            self.loader = true
            self.error = false
            self.featuresSelectedCount = 0
            self.update()
            
            API.request({
                object: 'Feature',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.update({
                        loader: false
                    })
                },
                error(response) {
                    self.update({
                        loader: false
                    })
                }
            })
        })

        self.on('mount', () => {
            riot.route.exec()
        })

        self.on('updated', () => {
            if (self.listTypes.indexOf(self.item.type) !== -1)  {
                self.tags.features.on('row-selected', (count) => {
                    self.featuresSelectedCount = count
                    self.update()
                })
                self.tags.features.on('reorder-end', () => {
                    self.item.values.forEach((item, index) => {
                        item.sort = index
                    })

                    self.update()
                })
                self.off('updated')
            }
        })

        getFeaturesTypes()
        
