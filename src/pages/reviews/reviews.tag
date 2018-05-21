| import 'pages/reviews/reviews-list.tag'
| import 'pages/reviews/review-edit.tag'

reviews
    .column(if='{ !notFound }')
        reviews-list(if='{ !edit }')
        review-edit(if='{ edit }')

    script(type='text/babel').
        var self = this,
        route = riot.route.create()

        self.edit = false

        route('/reviews', function () {
            self.notFound = false
            self.edit = false
            self.update()
        })

        route('/reviews/([0-9]+)', function (id) {
            observable.trigger('review-edit', id)
            self.notFound = false
            self.edit = true
            self.update()
        })

        route('/reviews/new', function () {
            self.update({edit: true, notFound: false})
            observable.trigger('review-new')
        })

        route('/reviews/comments', function () {
        observable.trigger('products-clone', id)
        }

        route('/reviews..', () => {
            self.notFound = true
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })