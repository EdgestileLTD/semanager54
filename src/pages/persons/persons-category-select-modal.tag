| import './person-category-new-modal.tag'

persons-category-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Группы контактов
        #{'yield'}(to="body")
            catalog(
                object             = 'ContactCategory',
                cols               = '{ parent.cols }',
                add                = '{ parent.add }',
                remove             = '{ parent.remove }',
                dblclick           = '{ parent.opts.submit.bind(this) }',
                disable-col-select = 'true',
                writeDC            = 'true',
            )
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'}
        ]

        self.collection = "ContactCategory"
        self.remove = (e, items) => {
            var self = this,
            params = {ids: items}

            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: items.length > 1
                    ? 'Вы точно хотите удалить эти записи?'
                    : 'Вы точно хотите удалить эту запись?',
                size: 'modal-sm',
                buttons: [
                    {action: 'yes', title: 'Удалить', style: 'btn-danger'},
                    {action: 'no', title: 'Отмена', style: 'btn-default'},
                ],
                callback: function (action) {
                    if (action === 'yes') {
                        API.request({
                            object: self.collection,
                            method: 'Delete',
                            data: params,
                            success(response) {
                                popups.create({title: 'Успешно удалено!', style: 'popup-success'})
                                self.tags['bs-modal'].tags.catalog.reload()
                            }
                        })
                    }
                    this.modalHide()
                }
            })
        }

        self.add = () => {
            modals.create('person-category-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = {name: _this.name.value }
                    API.request({
                        object: 'ContactCategory',
                        method: 'Save',
                        data: params,
                        success(response, xhr) {
                            popups.create({title: 'Успех!', text: 'Группа добавлена!', style: 'popup-success'})
                            _this.modalHide()
                            self.tags['bs-modal'].tags.catalog.reload()
                        }
                    })
                }
            })
        }