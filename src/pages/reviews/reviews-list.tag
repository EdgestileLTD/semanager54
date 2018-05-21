| import 'components/catalog.tag'

| import 'components/star-rating.tag'

reviews-list

    catalog(object='Review', cols='{ cols }', reload='true', search='true', sortable='true',
    add='{ permission(add, "reviews", "0100") }',
    remove='{ permission(remove, "reviews", "0001") }',
    dblclick='{ permission(open, "reviews", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='dateTime') { row.dateTimeTitle }
            datatable-cell(name='nameProduct') { row.nameProduct }
            datatable-cell(name='nameUser') { row.nameUser }
            datatable-cell(name='mark')
                star-rating(count='5', value='{ row.mark }')
            datatable-cell.text-right(name='likes') { row.likes }
            datatable-cell.text-right(name='dislikes') { row.dislikes }
            datatable-cell(name='comment') { row.comment }
            datatable-cell(name='merits') { row.merits }
            datatable-cell(name='demerits') { row.demerits }


    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Review'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'dateTime', value: 'Дата'},
            {name: 'nameProduct', value: 'Наименование товара'},
            {name: 'nameUser', value: 'Пользователь'},
            {name: 'mark', value: 'Звёзд'},
            {name: 'likes', value: 'Лайков'},
            {name: 'dislikes', value: 'Дислайков'},
            {name: 'comment', value: 'Отзыв'},
            {name: 'merits', value: 'Достоинства'},
            {name: 'demerits', value: 'Недостатки'}
        ]

        self.add = e => riot.route(`/reviews/new`)

        self.open = e => riot.route(`/reviews/${e.item.row.id}`)

        observable.on('reviews-reload', () => self.tags.catalog.reload())


