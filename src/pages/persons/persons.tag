| import 'pages/persons/persons-list.tag'
| import 'pages/persons/person-edit.tag'
| import 'pages/persons/companies-list.tag'
| import 'pages/persons/company-edit.tag'
| import 'pages/persons/accounts-list.tag'
| import 'pages/persons/persons-categories-list.tag'

persons
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }')
            a(href='#persons/{ link }')
                span { title }

    .column(if='{ !notFound }')
        persons-list(if='{ tab == "contacts" && !edit }')
        person-edit(if='{ tab == "contacts" && edit }')

        companies-list(if='{ tab == "companies" && !edit }')
        company-edit(if='{ tab == "companies" && edit }')

        persons-categories-list(if='{ tab == "categories" && !edit }')

        accounts-list(if='{ tab == "accounts" && !edit }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.edit = false

        self.tab = ''

        self.tabs = [
            {title: 'Контакты', name: 'contacts', link: ''},
            {title: 'Компании', name: 'companies', link: 'companies'},
            {title: 'Группы', name: 'categories', link: 'categories'},
            {title: 'Операции по счетам', name: 'accounts', link: 'accounts'},
        ]

        route('/persons', () => {
            self.edit = false
            self.tab = 'contacts'
            self.update()
        })

        route('/persons/([0-9]+)', id => {
            self.tab = 'contacts'
            observable.trigger('persons-edit', id)
            self.edit = true
            self.update()
        })

        route('/persons/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/persons/*/([0-9]+)', (tab, id) => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/persons/companies/new', tab => {
            self.update({edit: true, tab: 'companies'})
            observable.trigger('companies-new')
        })

        route('/persons..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })