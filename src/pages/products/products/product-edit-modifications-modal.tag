

product-edit-modifications-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Модификации товаров
        #{'yield'}(to="body")
            form(onchange='{ change }')
                product-edit-modifications(name='modifications', value='{ item.modifications }')
                    #{'yield'}(to='toolbar')
                        button.btn.btn-success(type='button', onclick='{ parent.copyModifications }',
                        title='Скопировать из другого товара')
                            i.fa.fa-copy

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            self.tags['bs-modal'].mixin('change')
            self.tags['bs-modal'].item = {
                modifications: opts.modifications
            }

            self.tags['bs-modal'].copyModifications = () => {
                modals.create('products-list-select-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        let _this = this
                        let items = this.tags.catalog.tags.datatable.getSelectedRows()

                        if (items.length) {
                            API.request({
                                object: 'Product',
                                method: 'Info',
                                data: {id: items[0].id},
                                success(response) {
                                    self.tags['bs-modal'].item = {
                                        modifications: response.modifications
                                    }
                                    _this.modalHide()
                                    self.update()
                                }
                            })
                        }
                    }
                })
            }

        })