| import 'components/catalog.tag'

pre-orders-list

    catalog(
        object    = 'PreOrder',
        search    = 'true',
        sortable  = 'true',
        cols      = '{ cols }',
        allselect = 'true',
        reload    = 'true',
        handlers  = '{ handlers }',
        add       = '{ permission(add, "orders", "0100") }',
        remove    = '{ permission(remove, "orders", "0001") }',
        dblclick  = '{ permission(orderOpen, "orders", "1000") }'
    )
        #{'yield'}(to="body")
            datatable-cell(name='id', class='{ handlers.sendMail.colors[row.sendMail] }') { row.id }
            datatable-cell.text-right(name='date') { row.date }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='email') { row.email }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='product') { row.product }
            datatable-cell.text-right(name='count') { row.count }
            datatable-cell(name='sendMail', class='{ handlers.sendMail.colors[row.sendMail] }')
                i(class='fa { row.sendMail ? "fa-check " : null } ')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'PreOrder'

        self.sendMail = {
            colors: {
                0: 'bg-danger', 1: 'bg-success'
            }
        }

        self.handlers = {
           sendMail: self.sendMail,
        }

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'date' , value: 'Дата заказа' },
            { name: 'name' , value: 'Заказчик' },
            { name: 'email' , value: 'Email заказчика' },
            { name: 'phone' , value: 'Телефон заказчика' },
            { name: 'product' , value: 'Наименование товара' },
            { name: 'count' , value: 'Кол-во' },
            { name: 'sendMail' , value: 'Отправлено письмо' },
        ]

        observable.on('orders-reload', function () {
            self.tags.catalog.reload()
        })

        self.orderOpen = function (e) {
            riot.route(`/orders/pre-orders/${e.item.row.id}`)
        }

        self.add = () => riot.route('/orders/pre-orders/new')



