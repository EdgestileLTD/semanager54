| import 'components/catalog.tag'

pending-orders-list

    catalog(
        object    = 'PendingOrder',
        search    = 'true',
        cols      = '{ cols }',
        allselect = 'true',
        reload    = 'true',
        handlers  = '{ handlers }',
        dblclick  = '{ permission(pendingOrderOpen, "orders", "1000") }',
        remove    = '{ permission(remove, "orders", "0001") }'
    )
        #{'yield'}(to="body")
            datatable-cell(name='createdAt') { row.createdAt }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='email') { row.email }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='data') { row.data }
            datatable-cell(name='countCart') { row.countCart }
            datatable-cell(name='countView') { row.countView }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'PendingOrder'

        self.sendMail = {
            colors: {
                0: 'bg-success', 1: 'bg-danger'
            }
        }

        self.handlers = {
            sendMail: self.sendMail,
        }

        self.cols = [
            { name: 'createdAt' , value: 'Дата заказа' },
            { name: 'name' , value: 'Заказчик' },
            { name: 'email' , value: 'Email заказчика' },
            { name: 'phone' , value: 'Телефон заказчика' },
            { name: 'data' , value: 'Доп. поля' },
            { name: 'countCart' , value: 'Поз. корз.' },
            { name: 'countView' , value: 'Поз. просм.' },
        ]

        self.pendingOrderOpen = function (e) {
            riot.route(`/orders/pending-orders/${e.item.row.idSession}`)
        }

        observable.on('orders-reload', function () {
            self.tags.catalog.reload()
        })



