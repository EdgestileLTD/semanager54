add-fields-list
    .row
        .col-md-3
            add-fields-groups(type='{ opts.type }')
        .col-md-9
            catalog(object='CustomField', cols='{ cols }', reload='true', handlers='{ handlers }', filters='{ filters }'
            add='{ permission(addEdit, "settings", "0100") }',
            remove='{ permission(remove, "settings", "0001") }',
            dblclick='{ permission(addEdit, "settings", "1010") }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='enabled')
                        i(class='fa { row.enabled == 1 ? "fa-check-circle-o" : "fa-circle-o  text-muted" } ')
                    datatable-cell(name='code') { row.code }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='type') { handlers.types[row.type] }
                    datatable-cell(name='required') { row.required == 0 ? 'Нет' : 'Да' }
                    datatable-cell(name='placeholder') { row.placeholder }
                    datatable-cell(name='description') { row.description }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'CustomField'

        self.filter = [{
            field: 'data',
            value: opts.type, //order, contacts, company
        }]

        self.filters = [...self.filter]

        self.addEdit = e => {
            let id

            if (e.item && e.item.row)
                id = e.item.row.id

            modals.create('add-fields-edit-modal', {
                type: 'modal-primary',
                id,
                data: opts.type,
                submit() {
                    let _this = this
                    _this.error = _this.validation.validate(_this.item, _this.rules)
                    let item =_this.item

                    if (opts.type)
                        item = {...this.item, data: opts.type}

                    if (!_this.error) {
                        API.request({
                            object: 'CustomField',
                            method: 'Save',
                            data: item,
                            success(response) {
                                popups.create({
                                    title: 'Успех!',
                                    text: 'Дополнительное поле сохранено!',
                                    style: 'popup-success'
                                })
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                }
            })
        }

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'enabled', value: 'Активно'},
            {name: 'code', value: 'Код'},
            {name: 'name', value: 'Наименование'},
            {name: 'type', value: 'Тип переменной'},
            {name: 'required', value: 'Обязательное'},
            {name: 'placeholder', value: 'Подсказка'},
            {name: 'description', value: 'Описание'},
        ]

        self.handlers = {
            types: {
                string: 'Строка',
                number: 'Число',
                text: 'Текст',
                select: 'Список',
                checkbox: 'Флажок',
                radio: 'Переключатель',
                date: 'Дата'
            }
        };

        self.one('updated', () => {
            var datatable = self.tags['add-fields-groups'].tags['catalog'].tags.datatable
            datatable.on('row-selected', (count, row) => {
                let items = datatable.getSelectedRows()

                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.filters = [{field: 'idGroup', sign: 'IN', value}, ...self.filter]
                } else {
                    self.filters = [...self.filter]
                }

                self.update()
                self.tags.catalog.reload()
            })
        })