| import debounce from 'lodash/debounce'

| import './settings-main-preferences.tag'
| import moment from 'moment'

settings-main
    .restore-layout(if='{ restoreDBlayout }')
        loader(text='Восстановление БД', indeterminate='true', size='large', inverted='true')
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#settings-main-home') Настройка магазина]
            li #[a(data-toggle='tab', href='#settings-main-company') Компания]
            li #[a(data-toggle='tab', href='#settings-values') Параметры магазина]
            li #[a(data-toggle='tab', href='#settings-main-preferences') Настройки Яндекс.Маркет]


        .tab-content
            #settings-main-home.tab-pane.fade.in.active
                form(action='', onchange='{ changeSettings }', onkeyup='{ changeSettings }', method='POST')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label  Имя магазина
                                input.form-control(type='text', name='shopname' value='{ item.shopname }')
                        .col-md-6
                            .form-group
                                label.control-label  Подзаголовок
                                input.form-control(type='text', name='subname', value='{ item.subname }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label  Имя сайта
                                input.form-control(type='text', name='domain', value='{ item.domain }')
                        .col-md-6
                            .form-group
                                label.control-label  Папка магазина
                                input.form-control(type='text', name='folder', value='{ item.folder }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label  URL логотипа
                                input.form-control(type='text', name='logo', value='{ item.logo }')
                        .col-md-6
                            .form-group
                                label.control-label  Базовая валюта
                                select.form-control(name='basecurr')
                                    option(
                                        each='{ c, i in item.listCurrency }',
                                        value='{ c.name }',
                                        selected='{ c.name == parent.item.basecurr }',
                                        no-reorder
                                    ) { c.title }
                    .row
                        .col-md-6
                            .form-group
                                label.control-label  E-mail продажи
                                input.form-control(type='text', name='esales', value='{ item.esales }')
                        .col-md-6
                            .form-group
                                label.control-label  E-mail поддержки
                                input.form-control(type='text', name='esupport', value='{ item.esupport }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Телефоны для СМС информирования
                                input.form-control(type='text', name='smsPhone', value='{ item.smsPhone }')
                        .col-md-6
                            .form-group
                                label.control-label Отправитель СМС по умолчанию
                                input.form-control(type='text', name='smsSender', value='{ item.smsSender }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Доставка (город отправления)
                                input.form-control(name='cityFromDelivery', type='text', value='{ item.cityFromDelivery }')
                .row(if='{ app.config.isAdmin }')
                    .col-md-12
                        .form-group
                            .form-inline
                                .form-group
                                    button(type='button', onclick='{ dumpDB }').btn.btn-primary Создать резервную копию БД
                                .form-group
                                    .btn.btn-file.btn-primary Восстановить БД из резервной копии
                                        input(name='file', type='file', accept='.gz', onchange='{ restoreDB }')

            #settings-values.tab-pane.fade
                form(action='', onchange='{ changeSettings }', method='POST')
                    ul.nav.nav-tabs.m-b-2
                        li(each='{ group,i in values.groups }', class='{ active: i==0 }') #[a(data-toggle='tab', href='#settings-values-num{group.id}', title='{ group.description }') { group.name }]

                    .tab-content
                        div(each='{ group, g in values.groups }', id='settings-values-num{group.id}', class='tab-pane fade { active:g==0 } { in:g==0 }')
                            .col-md-6(each='{ setting, s in values.settings }', if='{ values.settings[s].idGroup == group.id }')
                                .form-group
                                    label.control-label
                                        | { setting.name + ' ' }
                                        i.icon-append.fa.fa-question-circle.text-muted(if='{ values.settings[s].description }', data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='{ values.settings[s].description }')
                                    .input-group
                                        span.input-group-addon
                                            input(type="checkbox", name='settings_checked_{ s }', checked='{ values.settings[s].enabled == 1 }', style='width:13px;')
                                        // String
                                        input.form-control(if="{ values.settings[s].type == 'string' }", type='text', name='settings_{ s }', value='{ values.settings[s].value }', placeholder='{ setting.default }')
                                        // Bool
                                        select.form-control.text-white(if="{ values.settings[s].type == 'bool' }",
                                        style="background-color: { values.settings[s].value == 0 ? '#d9534f' : '#5cb85c' }; color:white;", name='settings_{ s }')
                                            option(value='0', style='color:black;background-color:white;',  selected='{ values.settings[s].value == 0 }') Выключено
                                            option(value='1', style='color:black;background-color:white;', selected='{ values.settings[s].value == 1 }') Включено
                                        // Select
                                        select.form-control(if="{ values.settings[s].type == 'select' }", name='settings_{ s }')
                                            option(each='{ value, name in values.settings[s].listValues }', value='{ value }',  selected='{ values.settings[s].value == value }') { name }
                                        // Password
                                        input.form-control(if="{ values.settings[s].type == 'password' }", type='password', name='settings_{ s }', value='{ values.settings[s].value }', placeholder='{ setting.default }')
                                    //.help-block(if='{ values.settings[s].description }')
                                        i.icon-append.fa.fa-info-circle
                                        |


            #settings-main-company.tab-pane.fade
                form(action='', onchange='{ changeSettings }', onkeyup='{ changeSettings }', method='POST')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label  Компания
                                input.form-control(type='text', name='company', value='{ item.company }')
                        .col-md-6
                            .form-group
                                label.control-label  Руководитель (Ф.И.О)
                                input.form-control(type='text', name='director', value='{ item.director }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label  Руководитель (должность)
                                input.form-control(type='text', name='posthead', value='{ item.posthead }')
                        .col-md-6
                            .form-group
                                label.control-label  Гл. бухгалтер (Ф.И.О)
                                input.form-control(type='text', name='bookkeeper', value='{ item.bookkeeper }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label  Физический адрес
                                input.form-control(type='text', name='addrF', value='{ item.addrF }')
                        .col-md-6
                            .form-group
                                label.control-label  Юридический адрес
                                input.form-control(type='text', name='addrU', value='{ item.addrU }')
                    .row
                        .col-md-4
                            .form-group
                                label.control-label  Телефон
                                input.form-control(type='text', name='phone', value='{ item.phone }')
                        .col-md-4
                            .form-group
                                label.control-label  Факс
                                input.form-control(type='text', name='fax', value='{ item.fax }')
                        .col-md-4
                            .form-group
                                label.control-label  НДС
                                input.form-control(type='number', step='0.10', name='nds', value='{ parseFloat(item.nds) }')

            #settings-main-preferences.tab-pane.fade
                settings-main-preferences

    style(scoped).
        .restore-layout {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #000;
            opacity: 0.7;
            z-index: 1100;
        }


    script(type='text/babel').
        var self = this,
        route = riot.route.create()

        self.item = {}
        self.values = {}
        self.mixin('permissions')
        self.mixin('change')
        self.app = app

        var save = debounce(e => {
            observable.trigger('settings-save')
            API.request({
                object: 'Main',
                method: 'Save',
                data: self.item,
                complete: () => self.update()
            })
        }, 600)


        self.changeSettings = e => {
            self.debuger({ ...self.debugParam, method:"changeSettings" })
            if (self.checkPermission('settings', '0010')) {
                if(e.target.localName == "select"){
                    var index = e.target.selectedIndex
                    self.item[e.target.name] =  e.target.children[index].value
                }
                self.change(e)
                save()
            } else {
                e.target.value = self.item[e.target.getAttribute('name')]
            }
        }

        observable.on('settings-add', settings => {
            self.debuger({ ...self.debugParam, method:"settings-add" })
            self.startbasecurr = self.item.basecurr
            self.values = settings
        })

        observable.on('settings-save', () => {
            self.debuger({ ...self.debugParam, method:"settings-save" })
            for (var prop in self.values.settings) {
                if(self.item['settings_' + prop]){
                    self.values.settings[prop].value = self.item[ 'settings_' + prop]
                }
                if( 'settings_checked_' + prop in self.item){
                    self.values.settings[prop].enabled = Number(self.item[ 'settings_checked_' + prop])
                }
            }

            API.request({
                object: 'Settings',
                method: 'Save',
                data: self.values,
                complete: () => self.update()
            })
            if (self.item.basecurr != self.startbasecurr) window.location.reload(true) // после смены баз валюты - перезагрузить ВЕСЬ сайт
        })

        self.reload = () => {
            self.debuger({ ...self.debugParam, method:"reload" })
            self.loader = true
            self.update()

            API.request({
                object: 'Main',
                method: 'Info',
                data: {},
                success(response) {
                    self.item = response
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })

            API.request({
                object: 'Settings',
                method: 'Fetch',
                data: {},
                success(response) {
                    observable.trigger('settings-add', response)
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        self.dumpDB = () => {
            self.debuger({ ...self.debugParam, method:"dumpDB" })
            API.request({
                object: 'Dump',
                method: 'Info',
                success(response, xhr) {
                    let a = document.createElement('a')
                    a.href = response.url
                    a.download = response.name
                    document.body.appendChild(a)
                    a.click()
                    a.remove()
                }
            })
        }

        self.restoreDB = e => {
            self.debuger({ ...self.debugParam, method:"restoreDB" })
            let target = e.target
            let formData = new FormData()

            if (target.files && target.files.length) {
                formData.append('file', target.files[0], target.files[0].name)
                self.restoreDBlayout = true

                API.upload({
                    object: 'Dump',
                    data: formData,
                    success(response) {
                        window.location.reload(true)
                    },
                    error() {
                        self.restoreDBlayout = true
                        self.update()
                    }
                })
            }
        }

        route('/settings', () => {
            self.debuger({ ...self.debugParam, method:"/settings" })
            self.reload()
        })

        self.on('updated', () => {
            self.debuger({ ...self.debugParam, method:"updated" })
            $('[data-toggle="tooltip"]').tooltip()
        })

        self.on('mount', () => {
            self.debuger({ ...self.debugParam, method:"mount" })
            riot.route.exec()
        })

        self.debugParam = {
            module   : "settings-main.tag",
            dClass   : "settings-main",
            method   : "",
            dComment : "",
            groupLog : "norm",
            dArray   : undefined
        }
        self.debuger = (dp = self.debugParam) => {

            /** ДЕБАГЕР
             * 1 Запуск логов
             * 2 Настройки
             * 3 Формирование строки
             * 4 Отступ
             * 5 Очередность и отображение
             *
             * self.debuger({ ...self.debugParam, method:"allParams" })
             *
             * self.debuger({ ...self.debugParam, method:"reload",
                     *                groupLog: "reload", dComment:"response", dArray: response })
             */

            // 1
            let startList = {
                norm        : true,
            }

            if (startList[dp.groupLog]==true && document.domain=="localhost") {

                // 2
                let ind=30;  let ind2=12;   let sy=" ";    let col=" |";
                let gr=true; let com=true;  let met=true;  let cl=true;  let mod=true;

                // 3
                let groupLog = "gr: " + dp.groupLog
                let comment  = "com: " + dp.dComment
                let method   = "met: " + dp.method
                let clas     = "cl: " + dp.dClass
                let module   = "mod: " + dp.module

                // 4
                let groupLogLen = sy.repeat( ind2-groupLog.length >=0 ? ind2-groupLog.length : 0 ) +col
                let commentLen  = sy.repeat(  ind-comment.length  >=0 ?  ind-comment.length  : 0 ) +col
                let methodLen   = sy.repeat(  ind-method.length   >=0 ?  ind-method.length   : 0 ) +col
                let clasLen     = sy.repeat(  ind-clas.length     >=0 ?  ind-clas.length     : 0 ) +col
                let modLen      = sy.repeat(  ind-module.length   >=0 ?  ind-module.length   : 0 ) +col

                // 5
                let consoleLog = "|"
                if (gr==true)  consoleLog += groupLog + groupLogLen
                if (com==true) consoleLog += comment + commentLen
                if (met==true) consoleLog += method + methodLen
                if (cl==true)  consoleLog += clas + clasLen
                if (mod==true) consoleLog += module + modLen

                console.warn(consoleLog)
                if (dp.dArray != undefined) console.log(dp.dArray)
            }
        }