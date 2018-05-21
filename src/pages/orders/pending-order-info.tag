| import 'components/datetime-picker.tag'
| import 'components/loader.tag'

pending-order-info
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#orders/pending-orders') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { 'Просмотр действия' }

        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#pending-order-info-home') Основная информация]
            li #[a(data-toggle='tab', href='#pending-order-info-events') События]
            li #[a(data-toggle='tab', href='#pending-order-info-views') Просмотрено]
            li #[a(data-toggle='tab', href='#pending-order-info-cart') Корзина]


        .tab-content
            #pending-order-info-home.tab-pane.fade.in.active
                .row
                    .col-md-2
                        .form-group
                            label.control-label Дата заказа
                            input.form-control(name='createdAt', value='{ item.createdAt }', readonly)
                    .col-md-4
                        .form-group
                            label.control-label Заказчик
                            input.form-control(name='name', value='{ item.name }', readonly)
                    .col-md-3
                        .form-group
                            label.control-label Email
                            input.form-control(name='email', value='{ item.email }', readonly)
                    .col-md-3
                        .form-group
                            label.control-label Телефон
                            input.form-control(name='phone', value='{ item.phone }', readonly)
                .row
                    .col-md-12
                        .form-group
                            label.control-label Дополнительные поля
                            input.form-control(name='data', value='{ item.data }', readonly)
            #pending-order-info-events.tab-pane.fade
                .row
                    .col-md-12
                        catalog-static(name='events', rows='{ item.events }', cols='{ eventsCols }', remove-toolbar = 1 )
                            #{'yield'}(to='body')
                                datatable-cell(name='createdAt') { row.createdAt }
                                datatable-cell(name='eventDisplay') { row.eventDisplay }
                                datatable-cell(name='number') { row.number }
                                datatable-cell(name='content') { row.content }
            #pending-order-info-views.tab-pane.fade
                .row
                    .col-md-12
                        catalog-static(name='viewGoods', rows='{ item.viewGoods }', cols='{ viewsCols }', remove-toolbar = 1  )
                            #{'yield'}(to='body')
                                datatable-cell(name='createdAt') { row.createdAt }
                                datatable-cell(name='idProduct') { row.idProduct }
                                datatable-cell(name='nameProduct') { row.nameProduct }
            #pending-order-info-cart.tab-pane.fade
                .row
                    .col-md-12
                        catalog-static(name='cartGoods', rows='{ item.cartGoods }', cols='{ viewsCols }', remove-toolbar = 1  )
                            #{'yield'}(to='body')
                                datatable-cell(name='createdAt') { row.createdAt }
                                datatable-cell(name='idProduct') { row.idProduct }
                                datatable-cell(name='nameProduct') { row.nameProduct }



    script(type='text/babel').
        var self = this,
        route = riot.route.create()

        self.item = {}
        self.loader = false

        self.eventsCols = [
            {name: 'createdAt', value: 'Дата'},
            {name: 'eventDisplay', value: 'Событие'},
            {name: 'number', value: 'Номер'},
            {name: 'content', value: 'Контент'},
        ]

        self.viewsCols = [
            {name: 'createdAt', value: 'Дата'},
            {name: 'idProduct', value: '#'},
            {name: 'nameProduct', value: 'Наименование товара'},
        ]


        self.reload = e => {
            observable.trigger('pending-order-info', self.item.idSession)
        }

        observable.on('pending-order-info', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'PendingOrder',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.loader = false
                    self.update()
                }
            })
        })

        self.on('mount', () => {
            riot.route.exec()
        })