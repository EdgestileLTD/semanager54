| import parallel from 'async/parallel'

add-fields-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Карточка элемента
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', value='{ item.name }')
                    .help-block { error.name }
                .form-group(class='{ has-error: error.name }')
                    label.control-label Код
                    input.form-control(name='code', value='{ item.code }')
                    .help-block { error.name }
                .form-group
                    label.control-label Группа
                    select.form-control(name='idGroup', value='{ item.idGroup }')
                        option(value='') Без группы
                        option(each='{ group in groups }', selected='{ item.idGroup == group.id }',  value='{ group.id }') { group.name }
                .form-group
                    label.control-label Тип элемента
                    select.form-control(name='type', value='{ item.type }')
                        option(value='string') Строка
                        option(value='number') Число
                        option(value='text') Текст
                        option(value='select') Список
                        option(value='checkbox') Флажок
                        option(value='radio') Переключатель
                        option(value='date') Дата
                .form-group
                    label.control-label Подсказка
                    input.form-control(name='placeholder', value='{ item.placeholder }')
                .form-group(if='{ ~["select", "checkbox", "radio"].indexOf(item.type) }')
                    label.control-label Значения
                    input.form-control(name='values', value='{ item.values }', placeholder='Возможные значения (через запятую)')
                .form-group
                    label.control-label Описание
                    textarea.form-control(name='description', value='{ item.description }', style='resize: none;')
                .form-group
                    .checkbox-inline
                        label
                            input(name='enabled', type='checkbox', checked='{ parseInt(item.enabled) }', data-bool='1,0')
                            | Активный
                    .checkbox-inline
                        label
                            input(name='required', type='checkbox', checked='{ parseInt(item.required) }', data-bool='1,0')
                            | Обязательный

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            let filters = []

            if (opts.data)
                filters.push({
                    field: 'data',
                    value: opts.data
                })

            modal.mixin('validation')
            modal.mixin('change')

            modal.item = {
                idGroup: '',
                type: 'string',
                enabled: 1
            }

            modal.rules = {
                name: 'empty',
                code: 'empty'
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }

            modal.loader = true

            if (opts.id) {
                parallel([
                    callback => {
                        API.request({
                            object: 'CustomField',
                            method: 'Info',
                            data: {id: opts.id},
                            success(response) {
                                modal.item = response
                                callback(null, 'AddFieldOrder')
                            },
                            error() {
                                callback('error', null)
                            }
                        })
                    },
                    callback => {
                        API.request({
                            object: 'CustomFieldGroup',
                            method: 'Fetch',
                            data: {filters},
                            success(response) {
                                modal.groups = response.items
                                callback(null, 'AddFieldOrderGroup')
                            },
                            error() {
                                callback('error', null)
                            }
                        })
                    }
                ], (err, res) => {
                    modal.loader = false
                    modal.update()
                })
            } else {
                API.request({
                    object: 'CustomFieldGroup',
                    method: 'Fetch',
                    data: {filters},
                    success(response) {
                        modal.groups = response.items
                        modal.loader = false
                        modal.update()
                    }
                })
            }
        })