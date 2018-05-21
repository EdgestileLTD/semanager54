| import 'pages/comments/comments-list.tag'
| import 'pages/comments/comment-edit.tag'

comments
    .column(if='{ !notFound }')
        comments-list(if='{ !edit }')
        comment-edit(if='{ edit }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.edit = false

        route('/reviews/comments', function () {
            self.notFound = false
            self.edit = false
            self.update()
        })

        route('/reviews/comments/([0-9]+)', function (id) {
            observable.trigger('comment-edit', id)
            self.notFound = false
            self.edit = true
            self.update()
        })

        route('/reviews/comments/new', function () {
            self.notFound = false
            self.edit = true
            observable.trigger('comment-new')
            self.update()
        })

        route('/reviews/comments..', () => {
            self.notFound = true
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })