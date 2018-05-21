| import 'pages/products/groups/group-new-modal.tag'
| import 'components/catalog-tree.tag'


groups-list
    catalog-tree(
        object          = 'Category',
        label-field     = '{ "name" }',
        children-field  = '{ "childs" }',
        add             = '{ permission(add, "products", "0100") }',
        dblclick        = '{ handlers.open }',
        remove          = '{ permission(remove, "products", "0001") }',
        handlers        = '{ handlers }',
        allselect       = 'true',
        reload          = 'true',
        search          = 'true'
    )
        #{'yield'}(to='head')
            button.btn.btn-primary(if='{ selectedCount > 1 }', type='button', title='Мультиредактирование категорий',
            onclick='{ handlers.multiEdit }')
                i.fa.fa-pencil
        #{'yield'}(to='after')
            span { this[parent.childrenField].length ? "[" + this[parent.childrenField].length + "]" : "" }
            form.form-inline.pull-right
                //button.btn.btn-default(if='{ handlers.checkPermission("products", "1000") }', type='button', onclick='{ handlers.open }')
                    i.fa.fa-pencil.text-primary
                //button.btn.btn-default(if='{ handlers.checkPermission("products", "0100") }', type='button', onclick='{ handlers.add }')
                i.fa.fa-plus.text-success(title='Добавить категорию', if='{ handlers.checkPermission("products", "0100") }', onclick='{ handlers.add }', style='margin-right: 10px;')

    style(scoped).
        :scope {
            position: relative;
            display: block;
        }

        treenodes .treenode {
            width: 100%;
            display: inline-block;
            line-height: 2.2;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Category'

        self.add = (e) => {
            e.stopPropagation()

            var id, item
            if (e.item && e.item.id) {
                id = e.item.id
                item = e.item
            }

            modals.create('group-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (_this.name.value.toString().trim() != '' && !_this.error) {

                        var params, sortIndex, childs

                        if (item) {
                            sortIndex = item['childs'].length
                            item['childs'] = item['childs'] || []
                            childs = item['childs']
                        } else {
                            sortIndex = self.tags['catalog-tree'].nodes.length
                            self.tags['catalog-tree'].nodes = self.tags['catalog-tree'].nodes || []
                            childs = self.tags['catalog-tree'].nodes
                        }

                        if (id)
                            params = {name: _this.name.value, upid: id, sortIndex}
                        else
                            params = {name: _this.name.value, sortIndex}

                        API.request({
                            object: 'Category',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                childs.push(response)
                                popups.create({
                                    title: 'Успех!',
                                    text: 'Категория добавлена',
                                    style: 'popup-success'
                                })
                                self.tags['catalog-tree'].update()
                            }
                        })
                    }
                }
            })
        }

        self.removeNode = (e) => {
            e.stopPropagation()
            var self = this,
            params = {ids: [e.item.id]}

            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: 'Вы точно хотите удалить эту запись?',
                size: 'modal-sm',
                buttons: [
                    {action: 'yes', title: 'Удалить', style: 'btn-danger'},
                    {action: 'no', title: 'Отмена', style: 'btn-default'},
                ],
                callback(action) {
                    if (action === 'yes') {
                        API.request({
                            object: 'Category',
                            method: 'Delete',
                            data: params,
                            success(response) {
                                if (e.item.__parent__ instanceof Array) {
                                    e.item.__parent__.splice(e.item.__parent__.indexOf(e.item), 1)
                                } else if (e.item.__parent__ instanceof Object) {
                                    e.item.__parent__['childs'].splice(e.item.__parent__['childs'].indexOf(e.item), 1)
                                }

                                popups.create({title: 'Успешно удалено!', style: 'popup-success'})
                                self.tags['catalog-tree'].update()
                            }
                        })
                    }
                    this.modalHide()
                }
            })
        }

        function open(e) {
            e.stopPropagation()
            riot.route(`/products/categories/${e.item.id}`)
        }

        function multiEdit(e) {
            let ids = this.tags.treeview.getSelectedNodes().map(item => item.id).join(',')
            riot.route(`/products/categories/multi?ids=${ids}`)
        }

        function afterChangeParent(idParent, id, position) {
            let params = {}
            params.id = id
            params.upid = idParent
            params.position = position

            API.request({
                object: 'Category',
                method: 'Save',
                data: params,
                success() {
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                }
            })

        }

        function  afterChangePosition(indexes) {
            let params = { indexes: indexes }
            API.request({
                object: 'Category',
                method: 'Sort',
                data: params,
                success() {
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                }
            })
        }

        self.handlers = {
            checkMask: self.checkMask,
            checkPermission: self.checkPermission,
            permission: self.permission,
            add: self.add,
            open: open,
            remove: self.removeNode,
            multiEdit: multiEdit,
            afterChangeParent: afterChangeParent,
            afterChangePosition: afterChangePosition
        }

        observable.on('categories-reload', () => {
            self.tags['catalog-tree'].reload()
        })

