| import 'pages/images/image-gallery.tag'

images
    .row(if='{ !notFound }')
        .col-sm-2.hidden-xs
            ul.nav.nav-pills.nav-stacked
                li(each='{ tabs }', class='{ active: name == tab }')
                    a(href='#images/{ link }') { title }

        .col-xs-12.hidden-sm.hidden-lg.hidden-md.form-group
            select.form-control(onchange='{ menuSelect }')
                option(each='{ tabs }', value='{ name }', selected='{ name == tab }', no-reorder) { title }

        .col-sm-10.col-xs-12
            image-gallery(name='gallery')

    script(type='text/babel').
        var self = this,
            route = riot.route.create(),
            path

        self.state = {}

        route('/images/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.notFound = false
                self.tab = tab

                self.tabs.forEach(item => {
                    if (item.name == tab)
                        path = item.path
                })

                if (!self.state[self.tab]) {
                    self.state[self.tab] = {}
                    self.state[self.tab].section = path
                    self.state[self.tab].limit = self.tags.gallery.pages.limit
                    self.state[self.tab].offset = 0
                }

                self.tags.gallery.update({ params: self.state[self.tab] })
                self.tags.gallery.reload()

                self.update()
            } else {
                self.notFound = true
                self.update()
                observable.trigger('not-found')
            }
        })

        observable.on('images-page-change', (params) => {
            self.state[self.tab] = params
        })

        self.tab = ''
        self.tabs = [
            {title: 'Товары', name: 'products', link: 'products', path: 'shopprice'},
            {title: 'Категории товаров', name: 'categories', link: 'categories', path: 'shopgroup'},
            {title: 'Новости', name: 'news', link: 'news', path: 'newsimg'},
            {title: 'Бренды', name: 'brands', link: 'brands', path: 'shopbrand'},
            {title: 'Параметры товаров', name: 'products-options', link: 'products-options', path: 'shopfeature'},
            {title: 'Платежные системы', name: 'pay-systems', link: 'pay-systems', path: 'shoppayment'},
            {title: 'Контакты', name: 'persons', link: 'persons', path: 'contacts'},
            {title: 'Разделы', name: 'sections', link: 'sections', path: 'sections'},
        ]

        self.menuSelect = (e) => {
            riot.route(`/images/${e.target.value}`)
        }

        self.on('mount', () => {
            riot.route.exec()
        })