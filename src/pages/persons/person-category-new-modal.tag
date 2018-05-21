| import 'pages/persons/persons-category-select-modal.tag'

person-category-new-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Категория
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.parentName }')
                    label.control-label Родительская группа
                    .input-group
                        select.form-control(name='idParent')
                            option(each='{ groupsPerson }', value='{ id }', selected='{ id == item.idParent }', no-reorder) { title }
                        .input-group-btn
                            .btn.btn-default(onclick='{ removeGroup }')
                                i.fa.fa-times.text-danger
                .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
                .form-group
                    label.control-label Код категории рассылки
                    .input-group
                        input.form-control(name='emailSettings', type='text', value='{ item.emailSettings }')
                        .input-group-btn
                            .btn.btn-default(onclick='{ getEmailGroup }', title="Связать с группой рассылки")
                                i.fa.fa-cogs
                .form-group
                    label.control-label Вес сортировки
                    input.form-control(name='sort', type='number', value='{ item.sort }')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        function loadGroupPerson(modal) {
            var params = {}
            params.ignoreId = modal.item.id || 0;
            params.parentId = 0;

            modal.groupsPerson = []
            API.request({
                object: 'ContactCategory',
                method: 'Fetch',
                data: params,
                success: (response, xhr) => {
                    modal.groupsPerson.push({id: 0, title: "Без родителя"})
                    modal.groupsPerson = modal.groupsPerson.concat(response.items)
                    modal.update()
                }
            })
        }

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.groupsPerson = []
            modal.item = opts.item || {}

            loadGroupPerson(modal);

            modal.mixin('validation')
            modal.mixin('change')

            modal.rules = {
                name: 'empty'
            }

            modal.getEmailGroup = e => {
                var params = {
                    id: modal.item.id,
                    name: modal.item.name,
                    addBook: true
                }
                API.request({
                    object: 'ContactCategory',
                    data: params,
                    method: 'Save',
                    success(response) {
                        modal.item.emailSettings = response.emailSettings
                        popups.create({title: 'Успех!', text: 'Контакты синхронизированы с группой рассылки!', style: 'popup-success'})
                        modal.update()
                    }
                })


            }
            modal.removeGroup = e => {
                modal.item.idParent = null
                modal.item.nameParent = ''
            }

            modal.afterChange = e => {
                modal.error = modal.validation.validate(modal.item, modal.rules, e.target.name)
            }
        })