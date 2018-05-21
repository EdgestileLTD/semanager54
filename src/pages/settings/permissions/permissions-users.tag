| import 'pages/persons/persons-list-select-modal.tag'
| import './permissions-roles-list-modal.tag'


permissions-users
    catalog(object='PermissionUser', cols='{ cols }', add='{ add }', remove='{ remove }', reload='true',
    store='permissions-users', dblclick='{ edit }')
        #{'yield'}(to='head')
            button.btn.btn-success(if='{ selectedCount > 1 }', type='button', onclick='{ parent.edit }')
                i.fa.fa-group
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='regDate') { row.regDate }
            datatable-cell(name='login') { row.login }
            datatable-cell(name='lastName') { [row.firstName, row.secondName, row.lastName].join(' ').trim() }
            datatable-cell(name='roles') { row.roles }

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'PermissionUser'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'regDate', value: 'Дата. рег.'},
            {name: 'login', value: 'Логин'},
            {name: 'lastName', value: 'Ф.И.О.'},
            {name: 'roles', value: 'Роли'},
        ]

        self.add = () => {
            modals.create('persons-list-select-modal', {
                type: 'modal-primary',
                submit() {
                    let _this = this
                    let items = _this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length) {
                        let ids = items.map(i => i.id)
                        API.request({
                            object: 'PermissionUser',
                            method: 'Save',
                            data: {ids},
                            success(response) {
                                self.tags.catalog.reload()
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

        self.edit = e => {
            let ids

            if (e.item) {
                ids = [e.item.row.id]
            } else {
                ids = self.tags.catalog.tags.datatable.getSelectedRows().map(i => i.id)
            }

            modals.create('permissions-roles-list-modal', {
                type: 'modal-primary',
                submit() {
                    let _this = this
                    let items = _this.tags.catalog.tags.datatable.getSelectedRows()

                    if (items.length) {
                        let idsRoles = items.map(i => i.id)
                        API.request({
                            object: 'PermissionUser',
                            method: 'Save',
                            data: {ids, idsRoles},
                            success(response) {
                                self.tags.catalog.reload()
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }