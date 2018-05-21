permissons-roles-add-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить новую роль
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text')
                    .help-block { error.name }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = {}
            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                name: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }
        })