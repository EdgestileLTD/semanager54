| import parallel from 'async/parallel'

optionitem-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Карточка элемента
        #{'yield'}(to="body")
            loader(if='{ loader }')
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-5
                        .form-group
                            .well.well-sm
                                image-select(name='image', section='options', alt='0', size='256', value='{ item.image }')

                    .col-md-7
                        .form-group(class='{ has-error: error.name }')
                            label.control-label Наименование
                            input.form-control(name='name', type='text', value='{ item.name }')
                            .help-block { error.name }
                        .form-group
                            label.control-label Цена
                            input.form-control(name='price', type='text', value='{ item.price }')

                        .form-group
                            label.control-label Опция
                            select.form-control(name='idOption', value='{ item.idOption }')
                                option(each='{ group in options }', selected='{ item.idOption == group.id }',  value='{ group.id }') { group.name }
                        .form-group
                            .checkbox
                                label
                                    input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                    | Отображать в магазине

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            let filters = []

            modal.mixin('validation')
            modal.mixin('change')

            modal.item = {}

            modal.rules = {
                name: 'empty',
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }

            if (opts.item) {
                modal.item = opts.item
            }

            modal.loader = true

            modal.getOptionGroup = () => {
                API.request({
                    object: 'Option',
                    method: 'Fetch',
                    success(response) {
                        modal.options = response.items
                        if (!modal.item.idOption) {
                            modal.options.forEach(item => {
                                modal.item.idOption = item.id
                                return true
                            })
                        }
                        modal.loader = false
                        modal.update()
                    }
                })
            }
            modal.getOptionGroup()
        })
