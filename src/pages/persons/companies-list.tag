companies-list
    catalog(
        search    = 'true',
        sortable  = 'true',
        object    = 'Company',
        cols      = '{ cols }',
        allselect = 'true',
        reload    = 'true',
        add       = '{ permission(add, "contacts", "0100") }',
        remove    = '{ permission(remove, "contacts", "0001") }',
        dblclick  = '{ permission(companyOpen, "contacts", "1000") }',
        store     = 'persons-list'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='inn') { row.inn }
            datatable-cell(name='kpp') { row.kpp }
            datatable-cell(name='email') { row.email }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='note') { row.note }
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label Группа
                        select.form-control(data-name='idGroup', data-sign='IN')
                            option(value='') Все
                            option(each='{ category, i in parent.categories }', value='{ category.id }', no-reorder) { category.name }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Contact'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'inn', value: 'ИНН'},
            {name: 'kpp', value: 'KPP'},
            {name: 'email', value: 'E-mail'},
            {name: 'phone', value: 'Телефоны'},
            {name: 'note', value: 'Примечание'},
        ]

        self.add = () => riot.route(`/persons/companies/new`)

        self.companyOpen = e => riot.route(`/persons/companies/${e.item.row.id}`)

        self.getContactCategory = () => {
            API.request({
                object: 'ContactCategory',
                method: 'Fetch',
                success(response) {
                    self.categories = response.items
                    self.update()
                }
            })
        }

        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {
                self.getContactCategory()
            })
        })

        observable.on('companies-reload', () => self.tags.catalog.reload())

        self.getContactCategory()