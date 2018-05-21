

permission-rights-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/permissions') #[i.fa.fa-chevron-left]
            button.btn(onclick='{ submit }', class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { item.name || 'Редактирование прав' }

        .row
            .col-md-12
                datatable(rows='{ item.permissions }', cols='{ cols }', handlers='{ handlers }')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='')
                        input(type='checkbox', onclick='{ stopPropagation }',
                        onchange='{ handlers.toggleAll }', checked='{ row.mask == 15 }')
                    datatable-cell(name='')
                        input(type='checkbox', onclick='{ stopPropagation }',
                        onchange='{ handlers.toggle }', checked='{ handlers.calc(row.mask, 8) }', data-value='8')
                    datatable-cell(name='')
                        input(type='checkbox', onclick='{ stopPropagation }',
                        onchange='{ handlers.toggle }', checked='{ handlers.calc(row.mask, 4) }', data-value='4')
                    datatable-cell(name='')
                        input(type='checkbox', onclick='{ stopPropagation }',
                        onchange='{ handlers.toggle }', checked='{ handlers.calc(row.mask, 2) }', data-value='2')
                    datatable-cell(name='')
                        input(type='checkbox', onclick='{ stopPropagation }',
                        onchange='{ handlers.toggle }', checked='{ handlers.calc(row.mask, 1) }', data-value='1')

    script(type='text/babel').
        var self = this

        self.item = {}

        self.cols = [
            {name: 'name', value: 'Объект'},
            {name: '', value: 'Полный доступ', classes: 'text-center'},
            {name: '', value: 'Чтение', classes: 'text-center'},
            {name: '', value: 'Добавление', classes: 'text-center'},
            {name: '', value: 'Редактирование', classes: 'text-center'},
            {name: '', value: 'Удаление', classes: 'text-center'},
        ]

        self.submit = () => {
            self.loader = true

            API.request({
                object: 'PermissionRole',
                method: 'Save',
                data: self.item,
                success(response) {
                    self.item = response
                    popups.create({title: 'Успех!', text: 'Права сохранены!', style: 'popup-success'})
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        self.reload = () => {
            if (self.item && self.item.id)
                observable.trigger('permissions-edit', self.item.id)
        }

        self.handlers = {
            calc(value, k) {
                return parseInt(value || 0) & k
            },
            toggleAll(e) {
                let checked = e.target.checked
                e.item.row.mask = checked ? 15 : 0
            },
            toggle(e) {
                let checked = e.target.checked
                let k = parseInt(e.target.getAttribute('data-value'))
                e.item.row.mask = parseInt(e.item.row.mask || 0) + (checked ? k : -k)
            }
        }

        observable.on('permissions-edit', id => {
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'PermissionRole',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })

        })