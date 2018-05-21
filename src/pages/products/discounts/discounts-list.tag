discounts-list
    catalog(
        object    = 'Discount',
        cols      = '{ cols }',
        allselect = 'true',
        reload    = 'true',
        handlers  = '{ handlers }',
        store     = 'discounts-list',
        reorder   = 'true',
        add       = '{ permission(add, "products", "0100") }',
        remove    = '{ permission(remove, "products", "0001") }',
        dblclick  = '{ permission(open, "products", "1000") }'
    )
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='title') { row.title }
            datatable-cell.text-right(name='dateFrom') { row.dateFrom }
            datatable-cell.text-right(name='dateTo') { row.dateTo }
            datatable-cell.text-right(name='stepTime')
                span  { row.stepTime }
                span(style='color: #ccc')  ч.
            datatable-cell.text-right(name='stepDiscount') { row.stepDiscount }
            datatable-cell.text-right(name='summFrom')
                span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                span  { row.summFrom.toFixed(2) }
                span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
            datatable-cell.text-right(name='summTo')
                span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                span  { row.summTo.toFixed(2) }
                span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
            datatable-cell.text-right(name='countFrom') { row.countFrom }
            datatable-cell.text-right(name='countTo') { row.countTo }
            datatable-cell(name='week') { handlers.getListOfDays(row.week) }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Discount'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'title', value: 'Наименование'},
            {name: 'dateFrom', value: 'Старт'},
            {name: 'dateTo', value: 'Завершение'},
            {name: 'stepTime', value: 'Шаг времени'},
            {name: 'stepDiscount', value: 'Шаг скидки'},
            {name: 'summFrom', value: 'От суммы'},
            {name: 'summTo', value: 'До суммы'},
            {name: 'countFrom', value: 'От кол-ва'},
            {name: 'countTo', value: 'До кол-ва'},
            {name: 'week', value: 'Дни недели'},
        ]

        self.handlers = {
            daysOfWeek: ['Пн.', 'Вт.', 'Ср.', 'Чт.', 'Пт.', 'Сб.', 'Вс.'],
            getListOfDays(days) {
                let items = days.split('')

                let result = items
                    .map((item, i) => (item == 1 ? this.daysOfWeek[i] : undefined))
                    .filter(item => item)
                    .join(',')

                return result
            }
        }

        observable.on('discount-reload', () => self.tags.catalog.reload())

        self.add= () => {
            riot.route(`products/discounts/new`)
        }

        self.open = e => {
            riot.route(`products/discounts/${e.item.row.id}`)
        }

        self.one('updated', () => {
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: self.collection,
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })
                self.update()
            })
        })