| import './permissons-roles-add-modal.tag'

permissions-roles
    catalog(object='PermissionRole', cols='{ cols }', add='{ add }', remove='{ remove }', dblclick='{ open }',
    reload='true', store='permissions-roles')
        #{'yield'}(to='body')
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'PermissionRole'

        self.add = () => {
            modals.create('permissons-roles-add-modal', {
                type: 'modal-primary',
                submit() {
                    let _this = this
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'PermissionRole',
                            method: 'Save',
                            data: { name: this.name.value },
                            success(response) {
                                popups.create({title: 'Успех!', text: 'Роль добавлен!', style: 'popup-success'})
                                observable.trigger('permissions-roles-reload')
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

        observable.on('permissions-roles-reload', () => self.tags.catalog.reload())

        self.open = e => riot.route(`/settings/permissions/${e.item.row.id}`)

        self.cols = [
            {name: "name", value: "Наименование"}
        ]