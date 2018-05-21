| import debounce from 'lodash/debounce'

settings-main-preferences
    loader(if='{ loader }')
    div(show='{ !loader }')
        .row
            .col-md-8.col-sm-12.col-xs-12
                catalog-static(onchange='{ change }', onkeyup='{ change }', cols='{ cols }',
                rows='{ items[0].parameters }', remove-toolbar='{ true }', handlers='{ handlers }')
                    #{'yield'}(to='body')
                        datatable-cell(name='name') { row.name }
                        datatable-cell(name='value')
                            input(if='{ row.valueType == "S" }', type='text', value='{ row.value }', onclick='{ stopPropagation }',
                            onchange='{ handlers.change }', onkeyup='{ handlers.change }')
                            input(if='{ row.valueType == "B" }', type='checkbox', checked='{ parseInt(row.value) }',
                            onclick='{ stopPropagation }', onchange='{ handlers.change }', onmousedown='{ handlers.change }')
                            input(if='{ row.valueType == "I" }', type='number', step='1', value='{ row.value }',
                            onclick='{ stopPropagation }', onchange='{ handlers.change }', onkeyup='{ handlers.change }')
                            input(if='{ row.valueType == "D" }', type='number', step='0.01', value='{ row.value }',
                            onclick='{ stopPropagation }', onchange='{ handlers.change }', onkeyup='{ handlers.change }')
            .col-md-4.hidden-sm.hidden-sm
                .h5
                    b Примечание по параметру
                p { note }

    script(type='text/babel').
        var self = this
        self.items = []
        self.note = ''

        self.mixin('permissions')

        self.cols = [
            {name: 'name', value: 'Наименование параметра'},
            {name: 'value', value: 'Значение'},
        ]

        var save = debounce(e => {
            API.request({
                object: 'Integration',
                method: 'Save',
                data: { parameters: self.items[0].parameters },
                complete: () => self.update()
            })
        }, 600)

        self.change = e => {
            if (self.checkPermission('settings', '0010')) save()
        }

        self.handlers = {
            change(e) {
                if (self.checkPermission('settings', '0010')) {
                    if (e.target.type === 'checkbox')
                        this.row.value = e.target.checked
                    else
                        this.row.value = e.target.value
                } else {
                    if (e.target.type === 'checkbox')
                        e.target.checked = parseInt(this.row.value)
                    else
                        e.target.value = this.row.value
                }
                this.update()
            }
        }

        self.reload = () => {
            self.loader = true
            self.update()

            API.request({
                object: 'Integration',
                method: 'Fetch',
                success(response) {
                    self.items = response.items
                    self.loader = false
                    self.update()
                }
            })
        }

        self.one('updated', () => {
            self.tags['catalog-static'].tags.datatable.on('row-selected', (count, item) => {
                self.note = item.note
                self.update()
            })
        })

        self.on('mount', () => {
            self.reload()
        })