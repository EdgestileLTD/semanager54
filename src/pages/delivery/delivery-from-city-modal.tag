| import parallel from 'async/parallel'

delivery-from-city-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Регион отправки
        #{'yield'}(to="body")
            form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
                select.form-control(name='paymentTarget')
                    option(each='{ items }', value='{ city }', no-reorder) { city }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this



        self.cols = [
            {name: 'id', value: '#'},
            {name: 'city', value: 'Город'},
        ]
        self.items = {}

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            API.request({
                object: 'DeliveryCity',
                method: 'Fetch',
                success(response) {
                    modal.items = response.items
                    self.update()
                }
            })
        })

