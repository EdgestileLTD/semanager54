| import './person-category-new-modal.tag'

persons-categories-list
    catalog-tree(
        object         = 'ContactCategory',
        label-field    = '{ "name" }',
        search         = 'true',
        sortable       = 'true',
        allselect      = 'true',
        cols           = '{ cols }',
        reload         = 'true',
        add            = '{ permission(addEdit, "contacts", "0100") }',
        children-field = '{ "childs" }',
        remove         = '{ permission(remove, "contacts", "0001") }',
        handlers       = '{ handlers }',
        dblclick       = '{ permission(addEdit, "contacts", "1000") }',
        store          = 'persons-category-list'
    )
        #{'yield'}(to='after')
            //span { this[parent.childrenField].length ? "[" + this[parent.childrenField].length + "]" : "" }
            span.small ({ this.userCount })
            span.form-inline.pull-right
                i.fa.fa-envelope-o(if='{ this.emailSettings }', title='Установлен код рассылки')
                span.f-sort(title='Вес сортировки группы') { this.sort }


    style(scoped).
        :scope {
            position: relative;
            display: block;
        }

        treenodes .treenode {
            padding: 2px;
            width: 100%;
            display: inline-block;
            line-height: 2.2;
        }
        .f-sort {
            margin-left: 30px;
            margin-right: 30px;
        }


    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'ContactCategory'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        function up(e) {

        }

        function down(e) {

        }

        self.handlers = {
            checkMask: self.checkMask,
            checkPermission: self.checkPermission,
            permission: self.permission,
            btnup: up,
            btndown: down
        }

        self.addEdit = e => {
            let item = {}

            if (e.item && e.item.id)
                item = e.item

            modals.create('person-category-new-modal', {
                type: 'modal-primary',
                item,
                submit() {
                    let _this = this

                    API.request({
                        object: 'ContactCategory',
                        data: _this.item,
                        method: 'Save',
                        success(response) {
                            observable.trigger('persons-category-reload')
                            popups.create({title: 'Успех!', text: 'Категория сохранена!', style: 'popup-success'})
                            _this.modalHide()
                            self.tags['catalog-tree'].reload()
                        }
                    })
                }
            })

        }
