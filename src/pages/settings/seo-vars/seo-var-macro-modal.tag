| import 'components/ckeditor.tag'

seo-var-macro-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить/изменить макропеременную
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(if='{ !item.id }', class='{ has-error: error.name }')
                    label.control-label  Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
                .form-group
                    label.control-label  Значение
                    textarea.form-control(name='value', value='{ item.value }', style='min-height: 150px')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.error = false
            modal.item = {}
            modal.mixin('validation')
            modal.mixin('change')
            //modal.update()

            modal.rules = {
                name: 'empty',
            }

            modal.afterChange = e => {
                let name = e.target.name
                delete modal.error[name]
                modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
            }


            if (opts.id) {
                modal.loader = true
                API.request({
                    object: 'SeoVariable',
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