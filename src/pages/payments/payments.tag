| import 'pages/payments/payments-list.tag'
| import 'pages/payments/payments-edit.tag'

payments
    .column(if='{ !notFound }')
        payments-list(if='{ !edit }')
        payments-edit(if='{ edit }')

    script(type='text/babel').
        var self = this,
        route = riot.route.create()

        self.edit = false

        route('/payments', function () {
            self.notFound = false
            self.edit = false
            self.update()
        })

        route('/payments/new', function () {
            observable.trigger('payments-new')
            self.notFound = false
            self.edit = true
            self.update()
        })

        route('/payments/([0-9]+)', id => {
            observable.trigger('payments-edit', id)
            self.notFound = false
            self.edit = true
            self.update()
        })

        route('/payments..', () => {
            self.notFound = true
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })