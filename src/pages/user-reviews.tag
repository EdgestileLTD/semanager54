| import 'pages/reviews/reviews-list.tag'
| import 'pages/reviews/review-edit.tag'
| import 'pages/comments/comments-list.tag'
| import 'pages/comments/comment-edit.tag'

user-reviews
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }', title='{ title }')
            a(href='#reviews/{ link }')
                i(class='{ icon }')
                span.hidden-xs &nbsp;{ title }
    .column
        reviews-list(if='{ tab == "reviews" && !edit }')
        review-edit(if='{ tab == "reviews" && edit }')
        comments-list(if='{ tab == "comments" && !edit }')
        comment-edit(if='{ tab == "comments" && edit }')

    script(type='text/babel').
        var self = this
        self.tab = ''
        self.edit = false

        self.tabs = [
            {title: 'Отзывы', name: 'reviews', link: '', permission: 'reviews', icon: 'fa fa-comment-o'},
            {title: 'Комментарии', name: 'comments', link: 'comments', permission: 'comments', icon: 'fa fa-comments-o'},
        ]

        var route = riot.route.create()
        route('/reviews', () => {
            self.edit = false
            self.tab = 'reviews'
            self.update()
        })

        route('/reviews/([0-9]+)', function (id) {
            observable.trigger('review-edit', id)
            self.notFound = false
            self.tab= 'reviews'
            self.edit = true
            self.update()
        })

        route('/reviews/new', function () {
            self.update({edit: true, notFound: false})
            observable.trigger('review-new')
        })

        route('/reviews/comments', function () {
            self.notFound = false
            self.edit = false
            self.tab= 'comments'
            self.update()
        })

        route('/reviews/comments/([0-9]+)', function (id) {
            observable.trigger('comment-edit', id)
            self.notFound = false
            self.tab= 'comments'
            self.edit = true
            self.update()
        })

        route('/reviews/comments/new', function () {
            self.notFound = false
            self.edit = true
            self.tab= 'comments'

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
