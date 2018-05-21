add-fields-group-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Категория поля
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', value='{ item.name }')
                    .help-block { error.name }
                .form-group
                    label.control-label Описание
                    textarea.form-control(name='description', value='{ item.description }', style='resize: none;')
                .form-group
                    .checkbox-inline
                        label
                            input(name='enabled', type='checkbox', checked='{ parseInt(item.enabled) }', data-bool='1,0')
                            | Активный

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.mixin('validation')
            modal.mixin('change')
            modal.item = {
                enabled: 1
            }

            modal.rules = {
                name: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }

            if (opts.id) {
                modal.loader = true

                API.request({
                    object: 'CustomFieldGroup',
                    method: 'Info',
                    data: {id: opts.id},
                    success(response) {
                        modal.item = response
                        modal.loader = false
                        modal.update()
                    }
                })
            }
        })