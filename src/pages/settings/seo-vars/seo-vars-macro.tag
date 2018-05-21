| import 'pages/settings/seo-vars/seo-var-macro-modal.tag'

seo-vars-macro
    catalog(object='SeoVariable', cols='{ cols }', reload='true',
    add='{ permission(addEdit, "settings", "0100") }',
    remove='{ permission(remove, "settings", "0001") }',
    handlers='{ variablesHandlers }',
    dblclick='{ permission(addEdit, "settings", "1010") }')
        #{'yield'}(to='body')
            datatable-cell(name='id', style='width: 1%;') { row.id }
            datatable-cell(name='name', style='width: 15%;') { row.name }
            datatable-cell(name='value')
                input.form-control(value='{ row.value }', type='text', readonly='true')
            datatable-cell(name='', style='width: 1%;')
                button.btn.btn-default(onclick='{ handlers.editVars }', title='Редактор')
                    i.fa.fa-edit

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')

        self.collection = "SeoVariable"

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'value', value: 'Значение'},
            {name: 'button', value: ''},
        ]

        self.variablesHandlers = {
            editVars(e) {
                return self.addEdit(e)
            }
        }


        self.addEdit = e => {
            var id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            modals.create('seo-var-macro-modal', {
                type: 'modal-primary',
                id: id,
                submit() {
                    var _this = this
                    var params = _this.item

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'SeoVariable',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                }
            })
        }


        observable.on('seo-vars-reload', () => {
            self.tags.catalog.reload()
        })
