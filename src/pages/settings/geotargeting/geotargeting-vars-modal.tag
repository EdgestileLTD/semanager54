geotargeting-vars-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Изменить макропеременную
        #{'yield'}(to="body")
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label  Значение
                    textarea.form-control(name='value', value='{ item.value }', style='min-height: 200px;')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this
        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.mixin('change')
            modal.item = opts.item || {}
            self.update()
        })











