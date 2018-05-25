

product-edit-parameters-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Характеристики товаров
        #{'yield'}(to="body")
            form(onchange='{ change }')
                product-edit-parameters(name='specifications', value='{ item.specifications }')
                    #{'yield'}(to='toolbar')
                        button.btn.btn-success(type='button', onclick='{ parent.parent.copySpecifications }',
                        title='Скопировать из другого товара')
                            i.fa.fa-copy
                        .form-group
                            select.form-control(value='{ parent.parent.isAddSpecifications }', onchange='{ parent.parent.typeChange }')
                                option(value='1') Добавить к существующим
                                option(value='0') Заменить существующие

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            self.tags['bs-modal'].mixin('change')
            self.tags['bs-modal'].item = {
                specifications: opts.specifications
            }

            self.tags['bs-modal'].isAddSpecifications = 1

            self.tags['bs-modal'].typeChange = e => {
                self.tags['bs-modal'].isAddSpecifications = e.target.value
            }

            self.tags['bs-modal'].copySpecifications = () => {
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
                                        specifications: response.specifications
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

