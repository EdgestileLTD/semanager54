| import 'pages/orders/orders-list.tag'
| import 'pages/orders/order-edit.tag'
| import 'pages/orders/pre-orders-list.tag'
| import 'pages/orders/pending-orders-list.tag'
| import 'pages/orders/pending-order-info.tag'
| import 'pages/orders/pre-order-edit.tag'

orders
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }')
            a(href='#orders/{ link }')
                span { title }

    .column(if='{ !notFound }')
        orders-list(if='{ tab == "orders" && !edit }')
        order-edit(if='{ tab == "orders" && edit }')

        pre-orders-list(if='{ tab == "pre-orders" && !edit }')
        pre-order-edit(if='{ tab == "pre-orders" && edit }')

        pending-orders-list(if='{ tab == "pending-orders" && !edit }')
        pending-order-info(if='{ tab == "pending-orders" && edit }')

    script(type='text/babel').
        var self = this


        self.tab = ''

        self.tabs = [
            {title: 'Заказы', name: 'orders', link: ''},
            {title: 'Предзаказы', name: 'pre-orders', link: 'pre-orders'},
            {title: 'Незавершенные', name: 'pending-orders', link: 'pending-orders'},
        ]

        self.edit = false
        self.notFound = false

        var route = riot.route.create()

        route('/orders', () => {
            self.edit = false
            self.tab = 'orders'
            self.notFound = false
            self.update()
        })

        route('/orders/([0-9]+)', id => {
            observable.trigger('orders-edit', id)
            self.edit = true
            self.notFound = false
            self.tab = 'orders'
            self.update()
        })

        route('/orders/pending-orders/([0-9]+)', id => {
            observable.trigger('pending-order-info', id)
            self.edit = true
            self.notFound = false
            self.tab = 'pending-orders'
            self.update()
        })

        route('/orders/pre-orders/([0-9]+)', id => {
            observable.trigger('pre-order-edit', id)
            self.edit = true
            self.notFound = false
            self.tab = 'pre-orders'
            self.update()
        })

        route('/orders/pre-orders/new', function () {
            self.edit = true
            self.notFound = false
            self.tab = 'pre-orders'
            observable.trigger('pre-order-new')
            self.update()
        })


        route('/orders/new', function () {
            self.edit = true
            self.notFound = false
            self.tab = 'orders'
            observable.trigger('order-new')
            self.update()
        })

        route('/orders/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/orders..', () => {
            self.notFound = true
            self.tab = 'orders'
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', function () {
            riot.route.exec()
        })
