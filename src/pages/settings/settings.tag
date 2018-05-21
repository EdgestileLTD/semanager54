| import 'pages/settings/settings-main.tag'
| import 'pages/settings/currencies/currencies.tag'
| import 'pages/settings/measurements/measurements.tag'
| import 'pages/settings/measurements/measure-edit.tag'
| import 'pages/settings/paysystems/pay-systems.tag'
| import 'pages/settings/paysystems/pay-system-edit.tag'
| import 'pages/settings/email/email.tag'
| import 'pages/settings/email/email-template-edit.tag'
//| import 'pages/settings/delivery/delivery.tag'
//| import 'pages/settings/delivery/delivery-edit.tag'
| import 'pages/settings/seo-vars/seo-vars.tag'
| import 'pages/settings/add-fields/add-fields.tag'
| import 'pages/settings/permissions/permissions.tag'
| import 'pages/settings/permissions/permission-rights-edit.tag'
| import 'pages/settings/synhro-1c/settings-synhro-1c.tag'
| import 'pages/settings/sms/sms.tag'
| import 'pages/settings/sms/sms-template-edit.tag'
| import 'pages/settings/geotargeting/geotargeting.tag'
| import 'pages/settings/geotargeting/geotargeting-edit.tag'

settings
    .row
        .col-sm-2.hidden-xs(if='{ !edit }')
            ul.nav.nav-pills.nav-stacked(style='height: calc(100vh - 65px); position: fixed; overflow-y: auto; padding-right: 20px; width: 15%;')
                li(each='{ tabs }', if='{ admin ? isAdmin() : checkPermission(permission, 1000) }', class='{ active: name == tab }')
                    a(href='#settings/{ link }') { title }

        .col-xs-12.hidden-sm.hidden-lg.hidden-md.form-group(if='{ !edit }')
            select.form-control(onchange='{ menuSelect }')
                option(each='{ tabs }', if='{ admin ? isAdmin() : checkPermission(permission, 1000) }',
                value='{ name }', selected='{ name == tab }', no-reorder) { title }

        .col-sm-10.col-xs-12
            settings-main(if='{ tab == "" }')
            //delivery(if='{ tab == "delivery" && !edit}')
            pay-systems(if='{ tab == "pay-systems" && !edit }')
            email(if='{ tab == "email" && !edit }')
            currencies(if='{ tab == "currencies" }')
            measurements(if='{ tab == "measurements" && !edit }')
            permissions(if='{ tab == "permissions" && !edit }')
            seo-vars(if='{ tab == "seo-variables" }')
            add-fields(if='{ tab == "fields" }')
            settings-yandex-photos(if='{ tab == "yandex-photos" }')
                h4 Яндекс.Фотки - в разработке
            settings-synhro-1c(if='{ tab == "settings-synhro-1c" && !edit }')
            sms(if='{ tab == "sms" && !edit }')
            geotargeting(if='{ tab == "geotargeting" && !edit }')

        .col-md-12
            //delivery-edit(if='{ tab == "delivery" && edit }')
            pay-system-edit(if='{ tab == "pay-systems" && edit }')
            email-template-edit(if='{ tab == "email" && edit }')
            permission-rights-edit(if='{ tab == "permissions" && edit }')
            sms-template-edit(if='{ tab == "sms" && edit }')
            measure-edit(if='{ tab == "measurements" && edit }')
            geotargeting-edit(if='{ tab == "geotargeting" && edit }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.mixin('permissions')
        self.tab = ''

        route('/settings', () => {
            self.edit = false
            self.tab = ''
            self.update()
        })

        route('/settings/*', tab => {
            let idx = self.tabs.map(item => item.name).indexOf(tab)
            let value
            if (idx !== -1 )
                value = self.tabs[idx].admin ? self.isAdmin() : self.checkPermission(self.tabs[idx].permission, 1000)
            if (idx !== -1 && value) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/settings/measurements/*/([0-9]+)', (section, id) => {
            self.update({edit: true, tab: 'measurements'})
            observable.trigger('measure-edit', id, section)
        })

        route('/settings/*/([0-9]+)', (tab, id) => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/settings/pay-systems/new', tab => {
            self.update({edit: true, tab: 'pay-systems'})
            observable.trigger('pay-systems-new')
        })

        //route('/settings/delivery/new', tab => {
        //    self.update({edit: true, tab: 'delivery'})
        //    observable.trigger('delivery-new')
        //})

        route('/settings/email/new', tab => {
            self.update({edit: true, tab: 'email'})
            observable.trigger('email-new')
        })

        route('/settings/sms/new', tab => {
            self.update({edit: true, tab: 'sms'})
            observable.trigger('sms-new')
        })

        route('/settings/geotargeting/new', tab => {
            self.update({edit: true, tab: 'geotargeting'})
            observable.trigger('geotargeting-new')
        })

        route('/settings..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.tab = ''
        self.tabs = [
            {title: 'Основные настройки', name: '', link: '', permission: 'settings'},
            //{title: 'Доставки', name: 'delivery', link: 'delivery', permission: 'deliveries'},
            {title: 'Платежные системы', name: 'pay-systems', link: 'pay-systems', permission: 'paysystems'},
            {title: 'Валюты', name: 'currencies', link: 'currencies', permission: 'currencies'},
            {title: 'Меры', name: 'measurements', link: 'measurements', permission: 'settings'},
            {title: 'Права доступа', name: 'permissions', link: 'permissions', permission: 'settings', admin: true},
            {title: 'SEO переменные', name: 'seo-variables', link: 'seo-variables', permission: 'settings'},
            {title: 'Поля', name: 'fields', link: 'fields', permission: 'settings'},
            {title: 'Геотаргетинг', name: 'geotargeting', link: 'geotargeting', permission: 'settings'},
            {title: 'E-mail уведомления', name: 'email', link: 'email', permission: 'mails'},
            {title: 'SMS уведомления', name: 'sms', link: 'sms', permission: 'settings'},
            //{title: 'Яндекс.Фотки', name: 'yandex-photos', link: 'yandex-photos', permission: 'settings'},
            {title: 'Интеграция с 1С', name: 'settings-synhro-1c', link: 'settings-synhro-1c', permission: 'settings'},
        ]

        self.menuSelect = e => riot.route(`/settings/${e.target.value}`)

        self.on('mount', () => {
            riot.route.exec()
        })