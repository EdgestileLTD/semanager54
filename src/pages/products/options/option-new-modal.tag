option-new-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Добавить опцию
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-sm-5
                        .form-group
                            .well.well-sm
                                image-select(name='image', section='options', alt='0', size='256', value='{ item.image }')
                    .col-sm-7
                        .form-group(class='{ has-error: error.name }')
                            label.control-label  Наименование
                            input.form-control(name='name', type='text', value='{ item.name }')
                            .help-block { error.name }
                        .form-group(class='{ has-error: error.name }')
                            label.control-label Метка (системное примечание)
                            input.form-control(name='code', value='{ item.code }')
                            .help-block { error.code }
                        .form-group
                            label.control-label Группа
                            select.form-control(name='idGroup', value='{ item.idGroup }')
                                option(value='') Без группы
                                option(each='{ group in groups }', selected='{ item.idGroup == group.id }',  value='{ group.id }') { group.name }
                        .form-group
                            label.control-label Тип цены
                            select.form-control(name='typePrice', value='{ item.typePrice }')
                                option(each='{ tp in ptypes }', selected='{ item.typePrice == tp.val }',  value='{ tp.val }') { tp.name }
                        .form-group
                            label.control-label Тип отображения
                            select.form-control(name='type', value='{ item.type }')
                                option(each='{ tp in vtypes }', selected='{ item.type == tp.val }',  value='{ tp.val }') { tp.name }
                        .form-group
                            label.control-label Описание
                            textarea.form-control(name='description', value='{ item.description }')


                        .form-group
                            .checkbox
                                label
                                    input(type='checkbox', name='isCounted', checked='{ item.isCounted }')
                                    | Позволять менять количество значений
                        .form-group
                            .checkbox
                                label
                                    input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                    | Отображать в магазине


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

            modal.groups = []

            modal.ptypes = [
                { val: 0, name: 'абсолютное значение' },
                { val: 1, name: 'процент'}
            ]

            modal.vtypes = [
                { val: 0, name: 'радиокнопки'},
                { val: 1, name: 'список'},
                { val: 2, name: 'чекбокс (множественный выбор)'}
            ]

            modal.rules = {
                name: 'empty',
                code: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }

            modal.getOptionGroup = () => {
                API.request({
                    object: 'OptionGroup',
                    method: 'Fetch',
                    success(response) {
                        modal.groups = response.items
                        modal.update()
                    }
                })
            }

            if (opts.item) {
                modal.item = opts.item
            }

            modal.getOptionGroup()
        })