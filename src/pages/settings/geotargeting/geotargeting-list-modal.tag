geotargeting-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Список городов
        #{'yield'}(to="body")
            catalog(name='geotargeting', object='GeoTargeting', cols='{ geoCols }',
            search='true', reload='false', disable-col-select='1',
            dblclick='{ parent.opts.submit }', handlers='{ handlers }')
                datatable-cell(name='id') { row.id }
                datatable-cell(name='name', onclick='{ handlers.select }') { row.name }
                datatable-cell(name='url', onclick='{ handlers.select }') { row.url }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.tab = 'contacts'

            modal.tabClick = e => {
                modal.tab = e.item.name
            }

            modal.handlers = {

            }

            modal.geoCols = [
                {name: 'id', value: '#'},
                {name: 'name', value: 'Город'},
                {name: 'url', value: 'Домен'}
            ]

        })



