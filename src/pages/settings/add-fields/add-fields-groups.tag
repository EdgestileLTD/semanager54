| import './add-fields-group-edit-modal.tag'

add-fields-groups
    catalog(object='CustomFieldGroup', cols='{ cols }', filters='{ filters }'
    add='{ permission(addEdit, "settings", "0100") }',
    remove='{ permission(remove, "settings", "0001") }',
    dblclick='{ permission(addEdit, "settings", "1010") }',
    reload='true', disable-limit='true', disable-col-select='true', disable-pagination='true')
        #{'yield'}(to='body')
            datatable-cell(name='name') { row.name }
    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'CustomFieldGroup'

        self.filters = [{
            field: 'data',
            value: opts.type,
        }]

        self.addEdit = e => {
            let id

            if (e.item && e.item.row)
                id = e.item.row.id

            modals.create('add-fields-group-edit-modal', {
                type: 'modal-primary',
                id,
                submit() {
                    let _this = this
                    _this.error = _this.validation.validate(_this.item, _this.rules)
                    let item =_this.item

                    if (opts.type)
                        item = {...this.item, data: opts.type}

                    if (!_this.error) {
                        API.request({
                            object: 'CustomFieldGroup',
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
            {name: 'name', value: 'Наименование'}
        ]