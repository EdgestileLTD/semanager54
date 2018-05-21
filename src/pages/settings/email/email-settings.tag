email-settings
    loader(if='{ loader }')
    form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
        .row
            .col-md-12
                .form-group
                    .btn-group
                        button.btn.btn-default(type='button', onclick='{ save }')
                            i.fa.fa-save
                            |  Сохранить
                        button.btn.btn-default(type='button', onclick='{ reload }')
                            i.fa.fa-refresh
        .row
            .col-md-12
                .form-group
                    label.control-label Провайдер
                    .input-group
                        select.form-control(name='id', value='{ item.id }')
                            option(each='{ p, i in providers }',
                            selected='{ p.id == item.id }', value='{ p.id }', no-reorder) { p.name }
                        .input-group-btn(if='{ link }')
                            a.btn.btn-default(target='_blank', href='{ link }', title='Перейти на сайт')
                                i.fa.fa-link

        .row
            .col-md-12
                virtual(each='{ settings }')
                    .form-group(if='{ name == "password" }')
                        label.control-label { name }
                        input.form-control(name='{ name }', value='{ parent.item[name] }', type='password')
                    .form-group(if='{ type == "string" && name != "password" }')
                        label.control-label { name }
                        input.form-control(name='{ name }', value='{ parent.item[name] }', type='text')
        .row
            .col-md-12
                .form-group(if='{ balance !== undefined }')
                    label.control-label Баланс
                    p.form-control-static { balance || 0 }

    style(scoped).
        :scope {
            display: block;
            position: relative;
        }

    script(type='text/babel').
        var self = this


        self.loader = false
        self.item = {}
        self.mixin('change')
        self.link = ''

        self.providers = []
            self.settings = []

        self.afterChange = e => {
            let name = e.target.name
            let value = e.target.value

            if (name === 'id') {
                self.settings = []
                let active = self.providers.filter(item => item.id == self.item.id)

                if (active.length) {
                    self.link = /http(s)*:\/\//.test(active[0].url) ? active[0].url : `http://${active[0].url}`
                    self.item = {id: value}
                    self.balance = undefined

                    API.request({
                        object: 'EmailProvider',
                        method: 'info',
                        data: {id: value},
                        success(response) {
                            self.balance = response.balance
                            self.update()
                        }
                    })

                    try {
                        var settings = JSON.parse(active[0].settings)
                        for (var param in settings) {
                            let item = { name: param, ...settings[param] }
                            self.settings.push(item)
                            self.item[param] = settings[param].value || ''
                        }
                    } catch(e) {
                            self.settings = []
                    }
                }
            }
        }

        self.save = () => {
            let params = {
                id: self.item.id,
                settings: '',
                isActive: '1'
            }

            let active = self.providers.filter(item => item.id == self.item.id)[0]
            let activeSettings = JSON.parse(active.settings)
            let settings = {}

            for (var param in self.item) {
                if (param !== 'id') {
                    settings[param] = { ...activeSettings[param], value: self.item[param] }
                }
            }

            params.settings = JSON.stringify(settings)

            API.request({
                object: 'EmailProvider',
                method: 'Save',
                data: params,
                success(response) {
                    popups.create({title: 'Успех!', text: 'Сохраненно!', style: 'popup-success'})
                }
            })
        }

        self.reload = () => {
            self.settings = []
            self.loader = true
            self.update()

            API.request({
                object: 'EmailProvider',
                method: 'Fetch',
                success(response) {
                    self.providers = response.items
                    let active = self.providers.filter(item => item.isActive == 1)
                    self.balance = undefined
                    self.update()

                    if (active.length) {
                        self.link = /http(s)*:\/\//.test(active[0].url) ? active[0].url : `http://${active[0].url}`
                        API.request({
                            object: 'EmailProvider',
                            method: 'info',
                            data: {id: active[0].id},
                            success(response) {
                                self.balance = response.balance
                                self.update()
                            }
                        })

                        self.item = { id: active[0].id }

                        try {
                            var settings = JSON.parse(active[0].settings)
                            for (var param in settings) {
                                let item = { name: param, ...settings[param] }
                                self.settings.push(item)
                                self.item[param] = settings[param].value || ''
                            }
                        } catch(e) {
                            self.settings = []
                        }
                    }
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        self.on('mount', () => {
            self.reload()
        })