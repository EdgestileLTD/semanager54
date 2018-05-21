| import 'pages/products/products/products-list.tag'
| import 'pages/products/products/product-edit.tag'
| import 'pages/products/groups/groups-list.tag'
| import 'pages/products/groups/group-edit.tag'
| import 'pages/products/brands/brands-list.tag'
| import 'pages/products/brands/brand-edit.tag'
| import 'pages/products/parameters/parameters.tag'
| import 'pages/products/modifications/modifications-list.tag'
| import 'pages/products/modifications/modification-edit.tag'
| import 'pages/products/discounts/discounts-list.tag'
| import 'pages/products/discounts/discount-edit.tag'
| import 'pages/products/coupons/coupons-list.tag'
| import 'pages/products/coupons/coupon-edit.tag'
| import 'pages/products/products-types/products-types-list.tag'
| import 'pages/products/parameters/parameter-edit.tag'
| import 'pages/products/options/options.tag'
| import 'pages/delivery/delivery.tag'
| import 'pages/delivery/delivery-edit.tag'
| import 'pages/products/labels/labels-list.tag'
| import 'pages/products/labels/label-edit.tag'



products
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }', title='{ title }', if='{ access }')
            a(href='#products/{ link }')
                i(class='{ icon }')
                span.hidden-xs &nbsp;{ title }


    .column
        products-list(if='{ tab == "products" && !edit }')
        product-edit(if='{ tab == "products" && edit }')

        groups-list(if='{ tab == "categories" && !edit }')
        group-edit(if='{ tab == "categories" && edit }')

        labels-list(if='{ tab == "labels" && !edit }')
        label-edit(if='{ tab == "labels" && edit }')

        products-types-list(if='{ tab == "types" && !edit }')

        brands-list(if='{ tab == "brands" && !edit }')
        brand-edit(if='{ tab == "brands" && edit }')

        options(if='{ tab == "options"  }')

        parameters(if='{ tab == "parameters" && !edit }')
        parameter-edit(if='{ tab == "parameters" && edit }')

        modifications-list(if='{ tab == "modifications" && !edit }')
        modification-edit(if='{ tab == "modifications" && edit }')


        discounts-list(if='{ tab == "discounts" && !edit }')
        discount-edit(if='{ tab == "discounts" && edit }')

        delivery(if='{ tab == "delivery" && !edit }')
        delivery-edit(if='{ tab == "delivery" && edit }')

        coupons-list(if='{ tab == "coupons" && !edit }')
        coupon-edit(if='{ tab == "coupons" && edit }')

    script(type='text/babel').
        var self = this

        self.edit = false
        self.tab = ''
        self.app = app
        self.bigaccess = (self.app.config.version > 530)

        self.tabs = [
            {title: 'Список товаров', name: 'products', link: '', icon: 'fa fa-shopping-bag', access: true },
            {title: 'Категории', name: 'categories', link: 'categories', icon: 'fa fa-folder-open', access: true},
            {title: 'Бренды', name: 'brands', link: 'brands', icon: 'fa fa-adn', access: true},
            {title: 'Ярлыки', name: 'labels', link: 'labels', icon: 'fa fa-tags', access: true},
            {title: 'Опции', name: 'options', link: 'options', icon: 'fa fa-list', access: self.bigaccess },
            {title: 'Параметры', name: 'parameters', link: 'parameters', icon: 'fa fa-cog', access: true},
            {title: 'Характеристики', name: 'types', link: 'types', icon: 'fa fa-check-square', access: true},
            {title: 'Модификации', name: 'modifications', link: 'modifications', icon: 'fa fa-sliders', access: true},
            {title: 'Доставка', name: 'delivery', link: 'delivery', icon: 'fa fa-truck', access: true},
            {title: 'Скидки', name: 'discounts', link: 'discounts', icon: 'fa fa-percent', access: true },
            {title: 'Купоны', name: 'coupons', link: 'coupons', icon: 'fa fa-money', access: true },
        ]

        var route = riot.route.create()

        route('/products/([0-9]+)', id => {
            self.tab = 'products'
            observable.trigger('products-edit', id)
            self.edit = true
            self.update()
        })

        route('/products/*/([0-9]+)', (tab, id) => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/products/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'products'
            observable.trigger('products-multi-edit', ids)
            self.edit = true
            self.update()
        })

        route('/products/clone..', () => {
            let q = riot.route.query()
            let id = q.id
            self.tab = 'products'
            observable.trigger('products-clone', id)
            self.edit = true
            self.update()
        })

        route('/products/categories/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'categories'
            observable.trigger('categories-multi-edit', ids)
            self.edit = true
            self.update()
        })

        route('/products/labels/new', tab => {
            self.update({edit: true, tab: 'labels'})
            observable.trigger('label-new')
        })


        route('/products/modifications/new', tab => {
            self.update({edit: true, tab: 'modifications'})
            observable.trigger('modifications-new')
        })

        route('/products/discounts/new', tab => {
            self.update({edit: true, tab: 'discounts'})
            observable.trigger('discounts-new')
        })

        route('/products/coupons/new', tab => {
            self.update({edit: true, tab: 'coupons'})
            observable.trigger('coupons-new')
        })

        route('/products', () => {
            self.edit = false
            self.tab = 'products'
            self.update()
        })

        route('/products/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/products..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })