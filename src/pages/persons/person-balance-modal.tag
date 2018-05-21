person-balance-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Лицевой счёт
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-6
                        .form-group
                            label.control-label Дата
                            datetime-picker.form-control(name='datePayee', format='YYYY-MM-DD HH:mm:ss', value='{ item.datePayee }')
                    .col-md-6
                        .form-group
                            label.control-label Тип
                            select.form-control(name='operation')
                                option(each='{ typeOperation, i in parent.opts.typeOperations }', value='{ typeOperation.operationId }',
                                no-reorder) { typeOperation.name }
                .row
                    .col-md-6
                        .form-group
                            label.control-label Приход
                            input.form-control(name='inPayee', type='number', value='{  parseFloat(item.inPayee) }')
                    .col-md-6
                        .form-group
                            label.control-label Расход
                            input.form-control(name='outPayee', type='number', value='{ item.outPayee }')
                .row
                    .col-md-12
                        .form-group
                            label.control-label Документ/примечание
                            textarea.form-control(rows='3', name='docum',
                                style='min-width: 100%; max-width: 100%;', value='{ item.docum }')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            self.tags['bs-modal'].mixin('change')
            self.tags['bs-modal'].item = opts.item || { inPayee: 0, outPayee: 0};
        })