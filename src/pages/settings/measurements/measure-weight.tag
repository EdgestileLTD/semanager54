measure-weight
    catalog(object='MeasureWeight', cols='{ cols }', reload='true',
    add='{ add }',
    remove='{ remove}',
    dblclick='{ measureOpen }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='code') { row.code }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='designation') { row.designation }
            datatable-cell(name='precision') { row.precision }
            datatable-cell(name='value') { row.value }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'MeasureWeight'

        self.cols = [
        { name: 'id', value: '#'},
        { name: 'code', value: 'Код ОКЕИ' },
        { name: 'name', value: 'Наименование'},
        { name: 'designation', value: 'Обозначение'},
        { name: 'precision', value: 'Точность'},
        { name: 'value', value: 'Мера'},
        ]


        observable.on('measurement-reload', () => {
             self.tags.catalog.reload()
        })