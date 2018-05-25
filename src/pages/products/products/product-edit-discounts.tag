| import 'pages/products/discounts/discounts-list-modal-select.tag'

product-edit-discounts
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', add='{ add }',
            cols='{ cols }', rows='{ value }', handlers='{ handlers }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='dateFrom') { row.dateFrom }
                    datatable-cell(name='dateTo') { row.dateTo }
                    datatable-cell(name='stepTime') { row.stepTime }ч.
                    datatable-cell(name='stepDiscount') { row.stepDiscount }
                    datatable-cell(name='sumFrom') { row.sumFrom }
                    datatable-cell(name='sumTo') { row.sumTo }
                    datatable-cell(name='countFrom') { row.countFrom }
                    datatable-cell(name='countTo') { row.countTo }
                    datatable-cell(name='week') { handlers.getListOfDays(row.week) }

    script(type='text/babel').
        var self = this

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value || []
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'dateFrom', value: 'Старт'},
            {name: 'dateTo', value: 'Завершение'},
            {name: 'stepTime', value: 'Шаг времени'},
            {name: 'stepDiscount', value: 'Шаг скидки'},
            {name: 'sumFrom', value: 'От суммы'},
            {name: 'sumTo', value: 'До суммы'},
            {name: 'countFrom', value: 'От кол-ва'},
            {name: 'countTo', value: 'До кол-ва'},
            {name: 'week', value: 'Дни недели'},
        ]

        self.add = () => {
            modals.create('discounts-list-modal-select', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.value = self.value || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.value.map(item => {
                        return item.id
                    })

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1)
                            self.value.push(item)
                    })

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }

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

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })