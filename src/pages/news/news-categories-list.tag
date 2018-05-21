| import './news-categories-edit-modal.tag'

news-categories-list
    catalog(object='NewsCategory', cols='{ cols }', remove='{ remove }', dblclick='{ addEdit }', add='{ addEdit }',
    reload='true', store='news-categories-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='title') { row.title }

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'NewsCategory'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'title', value: 'Наименование'},
        ]

        self.addEdit = (e) => {
            let id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            modals.create('news-categories-edit-modal', {
                type: 'modal-primary',
                id: id,
                submit() {
                    let _this = this
                    let params = _this.item
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'NewsCategory',
                            method: 'Save',
                            data: params,
                            success(response) {
                                popups.create({title: 'Успех!', text: 'Категория сохранена!', style: 'popup-success'})
                                observable.trigger('news-categories-reload')
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

        observable.on('news-categories-reload', () => {
            self.tags.catalog.reload()
        })