| import 'components/catalog.tag'

comments-list
    catalog(search='true', sortable='true', object='Comment', cols='{ cols }', reload='true',
    add='{ permission(add, "comments", "0100") }',
    remove='{ permission(remove, "comments", "0001") }',
    dblclick='{ permission(commentOpen, "comments", "1000") }',
    store='comments-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='date') { row.date }
            datatable-cell(name='nameProduct') { row.nameProduct }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='email') { row.email }
            datatable-cell(name='commentary') { row.commentary }
            datatable-cell(name='response') { row.response }

    script(type='text/babel').
        var self = this

        self.collection = 'Comment'

        self.mixin('permissions')
        self.mixin('remove')

        self.add = () => {
            riot.route('/reviews/comments/new')
        }

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'date', value: 'Дата'},
            {name: 'nameProduct', value: 'Наименование товара'},
            {name: 'name', value: 'Пользователь'},
            {name: 'email', value: 'E-mail'},
            {name: 'commentary', value: 'Комментарий'},
            {name: 'response', value: 'Ответ'}
        ]

        self.commentOpen = e => {
            riot.route(`/reviews/comments/${e.item.row.id}`)
        }

        observable.on('comments-reload', () => {
            self.tags.catalog.reload()
        })


