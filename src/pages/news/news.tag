| import 'pages/news/news-list.tag'
| import 'pages/news/news-edit.tag'
| import 'pages/news/news-categories-list.tag'

news
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }')
            a(href='#news/{ link }')
                span { title }

    .column
        news-list(if='{ tab == "news" && !edit }')
        news-edit(if='{ tab == "news" && edit }')
        news-categories-list(if='{ tab == "categories" && !edit }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.tab = ''

        self.tabs = [
            {title: 'Список новостей', name: 'news', link: ''},
            {title: 'Категории', name: 'categories', link: 'categories'},
        ]

        route('/news/([0-9]+)', id => {
            self.tab = 'news'
            observable.trigger('news-edit', id)
            self.edit = true
            self.update()
        })

        route('/news/new..', () => {
            let q = riot.route.query()
            let category = q.category
            let name = q.name
            self.tab = 'news'
            self.edit = true
            observable.trigger('news-new', {category, name})
            self.update()
        })

        route('/news/*/([0-9]+)', (tab, id) => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
            self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/news', () => {
            self.edit = false
            self.tab = 'news'
            self.update()
        })

        route('/news/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/news..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })