products-types-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Тип товара
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', value='{ item.name }')
                    .help-block { error.name }
                .h4 Параметры
                .alert.alert-danger(if='{ error.features }')
                    | { error.features }
                catalog-static(name='features', rows='{ item.features }', cols='{ cols }',
                dblclick='{ parent.opts.submit.bind(this) }', add='{ add }', remove='true')
                    #{'yield'}(to='body')
                        datatable-cell(name='name') { row.name }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.loader = opts.id
            modal.error = false
            modal.item = {}
            modal.cols = [
                {name: "name", value: "Наименование"}
            ]
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                name: 'empty',
                features: {
                    required: true,
                    rules: [{
                        type: 'minLength[1]',
                        prompt: 'Добавьте хотя бы один элемент в список'
                    }]
                }
            }

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {
                    ...modal.error,
                    ...modal.validation.validate(
                        modal.item,
                        modal.rules,
                        name
                    )
                }
            }

            modal.add = () => {
                modals.create('parameters-list-select-modal', {
                    type: 'modal-primary',
                    submit() {
                        modal.item.features = modal.item.features || []

                        let items = this.tags.catalog.tags.datatable.getSelectedRows()
                        let ids = modal.item.features.map(item => item.id)

                        items.forEach(item => {
                            if (ids.indexOf(item.id) === -1)
                                modal.item.features.push(item)
                        })

                        modal.update()
                        this.modalHide()

                        let event = document.createEvent('Event')
                        event.initEvent('change', true, true)
                        modal.tags.features.root.dispatchEvent(event)
                    }
                })
            }

            if (opts.id) {
                API.request({
                    object: 'ProductType',
                    method: 'Info',
                    data: {id: opts.id},
                    success(response) {
                        modal.item = response
                    },
                    complete() {
                        modal.loader = false
                        modal.update()
                    }
                })
            }

        })
