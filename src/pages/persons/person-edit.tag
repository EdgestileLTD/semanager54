| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'pages/persons/persons-category-select-modal.tag'
| import 'pages/persons/person-balance-modal.tag'
| import 'pages/persons/persons-list-select-modal.tag'
| import 'pages/settings/permissions/permission-user-list-modal.tag'
| import 'pages/settings/add-fields/add-fields-edit-block.tag'
| import md5 from 'blueimp-md5/js/md5.min.js'
| import 'components/catalog.tag'

person-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#persons') #[i.fa.fa-chevron-left]
            button.btn(if='{ checkPermission("contacts", "0010") }', onclick='{ submit }',
            class='{ item._edit_ ? "btn-success" : "btn-default" }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reloadButton }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { ['Редактирование контакта:', "[#" + item.id + "]", item.lastName, item.firstName, item.secondName].join(" ") }

        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#person-edit-home') Информация]
            li #[a(data-toggle='tab', href='#person-edit-documents') Паспортные данные]
            //li #[a(data-toggle='tab', href='#person-edit-requisites') Реквизиты компании]
            li(if='{ checkPermission("orders", "1000") }') #[a(data-toggle='tab', href='#person-edit-orders') Заказы]
            li(if='{ checkPermission("products", "1000") }') #[a(data-toggle='tab', href='#person-edit-groups') Группы]
            li #[a(data-toggle='tab', href='#person-edit-balance') Лицевой счёт]
            li
                a(data-toggle='tab', href='#person-edit-referals') Приглашенные


        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #person-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-2
                            .form-group
                                .well.well-sm
                                    image-select(name='imageFile', section='contacts', alt='0', size='256', value='{ item.imageFile }')
                        .col-md-10
                            .row
                                .col-md-4
                                    .form-group
                                        label.control-label Фамилия
                                        input.form-control(name='lastName', type='text', value='{ item.lastName }')
                                .col-md-4
                                    .form-group(class='{ has-error: error.firstName }')
                                        label.control-label Имя*
                                        input.form-control(name='firstName', type='text', value='{ item.firstName }')
                                        .help-block { error.firstName }
                                .col-md-4
                                    .form-group
                                        label.control-label Отчество
                                        input.form-control(name='secName', type='text', value='{ item.secName }')
                            .row
                                .col-md-2
                                    .form-group
                                        label.control-label Дата рождения
                                        datetime-picker.form-control(name='birthDate', format='DD.MM.YYYY', value='{ item.birthDate }')
                                .col-md-2
                                    .form-group
                                        label.control-label Пол
                                        select.form-control(name='sex', value='{ item.sex }')
                                            option(value='N') Не указан
                                            option(value='M') Мужской
                                            option(value='F') Женский
                                .col-md-4
                                    .form-group(class='{ has-error: error.phone }')
                                        label.control-label Телефон
                                        input.form-control(name='phone', type='text', value='{ item.phone }')
                                        .help-block { error.phone }
                                .col-md-4
                                    .form-group(class='{ has-error: error.email }')
                                        label.control-label Email
                                        input.form-control(name='email', type='text', value='{ item.email }')
                                        .help-block { error.email }
                            .row
                                .col-md-12
                                    .form-group
                                        label.control-label Адрес
                                        input.form-control(name='addr', type='text', value='{ item.addr }')
                            .row
                                .col-md-6
                                    .form-group
                                        label.control-label Логин
                                        input.form-control(name='login', type='text', value='{ item.login }')
                                .col-md-6
                                    .form-group
                                        label.control-label Пароль
                                        input.form-control(name='password', type='password', value='{ item.password }')
                            .row
                                .col-md-6
                                    .form-group(class='{ has-error: (error.idUp) }')
                                            label.control-label Рекомендатель
                                            .input-group
                                                input.form-control(name='idUp', value='{ item.referName }', readonly)
                                                .input-group-btn
                                                    .btn.btn-default(onclick='{ changeReferContact }')
                                                        i.fa.fa-list.text-primary
                                                    .btn.btn-default(onclick='{ removeReferContact }')
                                                        i.fa.fa-times.text-danger
                                            .help-block { (error.idUp) }
                                .col-md-6
                                    .form-group
                                        label.control-label Тип цены:
                                        select.form-control(name="priceType", value="{ item.priceType }")
                                            option(each='{priceTypeTitle}', value='{ id }', selected='{ item.priceType == id }') { name }
                            .row
                                .col-md-6
                                    .form-group(class='{ has-error: (error.idUp) }')
                                        label.control-label Менеджер
                                        .input-group
                                            input.form-control(name='managerId', value='{ item.managerName }', readonly)
                                            .input-group-btn
                                                .btn.btn-default(onclick='{ changeManager }')
                                                    i.fa.fa-list.text-primary
                                                .btn.btn-default(onclick='{ removeManager }')
                                                    i.fa.fa-times.text-danger
                                        .help-block { (error.managerId) }


                            div(if='{ item.customFields }')
                                h4 Дополнительная информация
                                add-fields-edit-block(name='customFields', value='{ item.customFields }')


                    .row
                        .col-md-12
                            .form-group
                                label.control-label Примечание по контакту
                                textarea.form-control(rows='5', name='note',
                                style='min-width: 100%; max-width: 100%;', value='{ item.note }')
                    .row
                        .col-md-12
                            .checkbox
                                label
                                    input(type='checkbox', name='isActive', checked='{ item.isActive == 1 }')
                                    | Активен
                    .row
                        .col-md-6
                            .form-group
                                label Зарегистрирован:
                                    nbsp
                                    b { item.regDate }

                #person-edit-documents.tab-pane.fade
                    .row
                        .col-md-4
                            .form-group
                                label.control-label Серия
                                input.form-control(name='docSer', type='text', value='{ item.docSer }')
                        .col-md-6
                            .form-group
                                label.control-label Номер
                                input.form-control(name='docNum', type='text', value='{ item.docNum }')
                    .row
                        .col-md-12
                            .form-group
                                label.control-label Регистрационные данные
                                textarea.form-control(rows='5', name='docRegistr',
                                style='min-width: 100%; max-width: 100%;', value='{ item.docRegistr }')


                //#person-edit-requisites.tab-pane.fade
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Наименование компании
                                input.form-control(name='company', type='text', value='{ item.company }')
                        .col-md-6
                            .form-group
                                label.control-label Директор
                                input.form-control(name='director', type='text', value='{ item.director }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Телефон
                                input.form-control(name='tel', type='text', value='{ item.tel }')
                        .col-md-6
                            .form-group
                                label.control-label Факс
                                input.form-control(name='fax', type='text', value='{ item.fax }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Юридический адрес
                                input.form-control(name='uradres', type='text', value='{ item.uradres }')
                        .col-md-6
                            .form-group
                                label.control-label Почтовый адрес
                                input.form-control(name='fizadres', type='text', value='{ item.fizadres }')
                    .row
                        .col-md-6
                            h4 Регистрационные и банковские реквизиты
                            datatable(rows="{ item.companyRequisites }", handlers='{ companyRequisitesHandlers }')
                                datatable-cell(name='name') { row.title }
                                datatable-cell(name='value')
                                    input(type='text', value='{ row.value }', oninput='{ handlers.valueChange }')

                #person-edit-orders.tab-pane.fade(if='{ checkPermission("orders", "1000") }')
                    .row
                        .col-md-12
                            datatable(cols='{ cols }', rows='{ orders }', handlers='{ handlersOrders }', dblclick='{ dblclickOrder }')
                                datatable-cell(name='id') {row.id}
                                datatable-cell(name='dateOrder') {row.dateOrder}
                                datatable-cell.text-right(name='amount')
                                    span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                                    span  {row.amount.toFixed(2)}
                                    span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.curr !== null && row.curr !== "" ? row.curr : row.titleCurr }
                                datatable-cell(name='status', class='{ handlers.orderText.colors[row.status] }')
                                    | { handlers.orderText.text[row.status] }
                                datatable-cell(name='deliveryStatus', class='{ handlers.deliveryText.colors[row.deliveryStatus] }')
                                    | { handlers.deliveryText.text[row.deliveryStatus] }
                                datatable-cell(name='note') { row.note }

                #person-edit-groups.tab-pane.fade(if='{ checkPermission("products", "1000") }')
                    catalog(
                        if             = '{ item.id }',
                        object         = 'Contact',
                        id             = '{ item.id }',
                        method         = 'Info',
                        items          = 'groups',
                        count          = 'groupsCount',
                        cols           = '{ groupsCols }',
                        allselect      = 'true',
                        store          = 'person-edit',
                        add            = '{ permission(addGroup, "persons-category-select-modal", "0100") }',
                        remove         = '{ permission(removeGroups, "persons-category-select-modal", "0001") }',
                        getDC          = 'Contact',
                        sortable       = 'true',
                        disablePagination = 'true',
                    )
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }

                #person-edit-balance.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='personalAccount', add='{ addBalance }', dblclick='{ editBalance }',
                                after-remove='{ recalcBalance }', cols='{ balanceCols }', rows='{ item.personalAccount }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='datePayee') { row.datePayee }
                                    datatable-cell.text-right(name='inPayee')
                                        span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                                        span  { (row.inPayee / 1).toFixed(2) }
                                        span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.curr !== null && row.curr !== "" ? row.curr : row.titleCurr }
                                    datatable-cell.text-right(name='outPayee')
                                        span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                                        span  { (row.outPayee / 1).toFixed(2) }
                                        span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.curr !== null && row.curr !== "" ? row.curr : row.titleCurr }
                                    datatable-cell.text-right(name='balance')
                                        span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                                        span  { (row.balance / 1).toFixed(2) }
                                        span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.curr !== null && row.curr !== "" ? row.curr : row.titleCurr }

                                    datatable-cell(name='docum') { row.docum }

                #person-edit-referals.tab-pane.fade
                    .row
                        .col-md-12
                            catalog-static(name='referals',
                                cols='{ referalCols }', rows='{ item.referals }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='id') {row.id}
                                    datatable-cell(name='username') {row.username }
                                    datatable-cell(name='refName') {row.refName }
                                    datatable-cell(name='email') {row.email }
                                    datatable-cell(name='phone') {row.phone }
                                    datatable-cell(name='refCount') {row.refCount }
                                    datatable-cell(name='regDate') {row.regDate }

    script(type='text/babel').
        var self = this

        self.item = {}
        self.orders = []
        self.groupsSelectedCount = 0
        self.accountOperations = []
        self.referalFields = []
        self.allMode = false

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.priceTypeTitle = [
            {id: 0, name: 'Розничная'},
            {id: 1, name: 'Корпоративная'},
            {id: 2, name: 'Оптовая'}
        ]

        self.rules = {
            firstName: 'empty',
            email: {
                rules:[{
                    type: 'email'
                }]
            },
            phone: {
                rules:[{
                    type: 'phone'
                }]
            }
        }
        //email: {rules: [{type: 'email'}]}

        self.afterChange = e => {
            self.debuger({ ...self.debugParam, method:"afterChange" })
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'dateOrder' , value: 'Дата заказа' },
            { name: 'amount' , value: 'Сумма' },
            { name: 'status' , value: 'Статус заказа' },
            { name: 'deliveryStatus' , value: 'Статус доставки' },
            { name: 'note' , value: 'Примечание' }
        ]

        self.groupsCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'}
        ]

        self.balanceCols = [
            {name: 'datePayee', value: 'Дата'},
            {name: 'inPayee', value: 'Приход'},
            {name: 'outPayee', value: 'Расход'},
            {name: 'balance', value: 'Баланс'},
            {name: 'docum', value: 'Примечание'}
        ]

        self.referalCols = [
            {name: 'id', value: '#'},
            {name: 'username', value: 'Логин'},
            {name: 'refName', value: 'Имя контакта'},
            {name: 'email', value: 'E-mail'},
            {name: 'phone', value: 'Телефон'},
            {name: 'refCount', value: 'Пригл.'},
            {name: 'regDate', value: 'Дата регистр.'}
        ]

        self.companyRequisitesHandlers = {
            valueChange(e) {
                var selectionStart = e.target.selectionStart
                var selectionEnd = e.target.selectionEnd
                this.row.value = e.target.value

                this.update()
                e.target.selectionStart = selectionStart
                e.target.selectionEnd = selectionEnd
            }
        }

        self.addGroup = () => {
            self.debuger({ ...self.debugParam, method:"addGroup" })
            modals.create('persons-category-select-modal', {
                type: 'modal-primary',
                submit() {
                    self.item.groups = self.item.groups || []
                    let items = this.tags.catalog.getSelectedMode()

                    let ids = self.item.groups.map(item => {
                        return item.id
                    })

                    items.ids.forEach(item => {
                        if (ids.indexOf(item.id) === -1) {
                            self.item.groups.push({id : item,
                                                   name: "0"
                            })
                        }
                    })

                    if (self.datacatalog.ContactCategory &&
                        self.datacatalog.Contact
                    ) {                                                     // переносим id и name в таблицу групп
                        var iddatacatalog  = {}                               // получаем id

                        self.datacatalog.ContactCategory.forEach(item => {    // получаем id
                            iddatacatalog[item.id] = item
                        })

                        items.ids.forEach(item => {                           // по id составляем окончательный массив
                            var unit = {
                                id  : item,
                                name: iddatacatalog[item]["name"]
                            }
                            self.datacatalog.Contact.push(unit)
                        })

                        var uniq = {}
                        self.datacatalog.Contact.forEach(item => {            // фильтруем уникальные значения по id
                            uniq[item.id] = item
                        })
                        self.datacatalog.Contact = []                         // очистка исходного массива
                        for (var item in uniq) {                              // возвращаем уникальные значения
                            self.datacatalog.Contact.push(uniq[item])
                        }

                        observable.trigger('datacatalog', self.datacatalog)   // записываем в транс-табличные данные
                    }

                    self.update()
                    self.tags.catalog.reload()
                    this.modalHide()
                }
            })
        }

        self.recalcBalance = () => {
            self.debuger({ ...self.debugParam, method:"recalcBalance" })
            let balance = 0.0
            self.item.personalAccount.forEach(function(item) {
                balance += parseFloat(item.inPayee) - parseFloat(item.outPayee)
                item.balance = parseFloat(balance)
            })
        }

        self.addBalance = () => {
            self.debuger({ ...self.debugParam, method:"addBalance" })
            modals.create('person-balance-modal', {
                type: 'modal-primary',
                typeOperations: self.accountOperations,
                submit() {
                    self.item.personalAccount.push(this.item)
                    self.recalcBalance()
                    self.update()
                    this.modalHide()
                }
            })
        }

        self.editBalance = (e) => {
            self.debuger({ ...self.debugParam, method:"editBalance" })
            modals.create('person-balance-modal', {
                type: 'modal-primary',
                typeOperations: self.accountOperations,
                item: e.item.row,
                submit() {
                    self.recalcBalance()
                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeGroups = (e, itemsToRemove, self) => {

            /** удаление групп из временного списка
             *  (нужно, что бы все группы были на листе - нужны id для allDelete)
             *  @param {object} e MouseEvent - данные мыши
             *  @param {array or object}  itemsToRemove массив id's на удаление или объект с allMode and allModeLastParams
             *  @param {object} self данные по контакту
             *  @return {object} observable.trigger 'datacatalog'
             */

            self.debuger({ ...self.debugParam, method:"removeGroups" })

            self.groupsSelectedCount = 0
            //self.item.groups = self.tags.groups.getUnselectedRows()

            /** если "удалить все" - получаем список id групп для последующего удаления */
            if (itemsToRemove.allMode != undefined) {
                itemsToRemove = []
                self.items.forEach(item => {
                    itemsToRemove.push(item.id)
                })
            }

            var iddatacatalog  = {}
            self.datacatalog.Contact.forEach(item => {    // получаем id
                iddatacatalog[item.id] = item
            })
            self.datacatalog.Contact = []                 // чистим

            itemsToRemove.forEach(item => {
                delete iddatacatalog[item]                // удаляем по id
            })

            for (var item in iddatacatalog) {             // возвращаем
                self.datacatalog.Contact.push(iddatacatalog[item])
            }
            observable.trigger('datacatalog', self.datacatalog) // записываем в транс-табличные данные

            self.update()
        } // удаление групп из временного списка

        self.submit = e => {

            self.debuger({ ...self.debugParam, method:"submit" })

            self.item.groups = self.datacatalog.Contact // загрузка изменений в группы перед сохранением
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                if (self.item && self.item.password && self.item.password.trim() === '')
                    delete self.item.password
                else
                    self.item.password = md5(self.item.password)

                API.request({
                    object: 'Contact',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Контакт сохранен!', style: 'popup-success'})
                        self.item = response
                        self.item.password = new Array(8).join(' ')
                        self.update()
                        observable.trigger('persons-reload')
                    }
                })
            } else {
                popups.create({title: 'Ошибка!', text: 'Имеются незаполненые поля !', style: 'popup-warning'})
            }
        }

        self.reloadButton = () => {
            self.debuger({ ...self.debugParam, method:"reloadButton" })
            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: 'Будут потеряны не сохраненные данные. Вы точно хотите обновить эту страницу?',
                size: 'modal-sm',
                buttons: [
                    {action: 'yes', title: 'Обновить', style: 'btn-danger'},
                    {action: 'no', title: 'Отмена', style: 'btn-default'},
                ],
                callback: function (action) {
                    if (action === 'yes') {
                        self.reload()
                    }
                    this.modalHide()
                }
            })
        } // обновление страницы карточки контакта с всплывающим предупреждением

        self.reload = () => {
            self.debuger({ ...self.debugParam, method:"reload" })
            self.tags.catalog.reload() // перезагрузка каталога
            observable.trigger('persons-edit', self.item.id)
        }

        observable.on('persons-edit', id => {
            self.debuger({ ...self.debugParam, method:"persons-edit" })
            var params = {id: id}
            self.error = false
            self.loader = true
            API.request({
                object: 'Contact',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    self.item.password = new Array(8).join(' ')
                    self.accountOperations = response.accountOperations
                    self.loader = false
                    getOrders(self.item.id)
                    getReferals(self.item.id)
                    self.update()
                    if (self.tags.catalog) self.tags.catalog.reload({dcreset:true}) // перезагрузка каталога
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                    if (self.tags.catalog) self.tags.catalog.reload({dcreset:true}) // перезагрузка каталога
                }
             })

        })

        function getReferals(idCustomer) {
            self.debuger({ ...self.debugParam, method:"getReferals" })
            var params = {id: idCustomer}
            //self.referalFields = []
            API.request({
                object: 'Referals',
                method: 'Fetch',
                data: params,
                success: (response, xhr) => {
                    if (!(response.items instanceof Array))
                        response.items = []
                    self.item.referals = response.items
                    self.update()
                }
            })
        }

        function getOrders(idCustomer) {
            self.debuger({ ...self.debugParam, method:"getOrders" })
            var params = {filters: {field: "idAuthor", value: idCustomer}}

            API.request({
                object: 'Order',
                method: 'Fetch',
                data: params,
                success: (response, xhr) => {
                    if (!(response.items instanceof Array))
                        response.items = []
                    self.orders = response.items
                    self.update()
                }
            })
        }

        self.changeManager = () => {
            self.debuger({ ...self.debugParam, method:"changeManager" })
            modals.create('permission-user-list-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.item.managerName = ''
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    if (!items.length) return

                    self.item.managerId = items[0].id
                    if (items[0].lastName)
                        self.item.managerName = items[0].lastName + ' '
                    if (items[0].firstName)
                        self.item.managerName += items[0].firstName + ' '
                    if (items[0].secName)
                        self.item.managerName += items[0].secName

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeManager = () => {
            self.debuger({ ...self.debugParam, method:"removeManager" })
            self.item.managerId = null
            self.item.managerName = null
        }

        self.changeReferContact = () => {
            self.debuger({ ...self.debugParam, method:"changeReferContact" })
            let id = self.item.id
            modals.create('persons-list-select-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                id,
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    if (!items.length) return

                    self.item.idUp = items[0].id
                    self.item.referName = items[0].displayName

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeReferContact = () => {
            self.debuger({ ...self.debugParam, method:"removeReferContact" })
            self.item.idUp = null
            self.item.referName = null
        }

        self.one('updated', () => {
            self.debuger({ ...self.debugParam, method:"one" })
            observable.trigger('datacatalog', {})   // очищаем транс-табличные данные
            self.tags.groups.on('row-selected', count => {
                self.groupsSelectedCount = count
                self.update()
            })
        })

        self.orderText = {
             text: {
                Y: 'Оплачен', N: 'Не оплачен', K: 'Кредит', P: 'Подарок', W: 'В ожидании', C: 'Возврат', T: 'Тест'
             },
             colors: {
                Y: 'bg-success', N: 'bg-danger', K: 'bg-warning', P: null, W: null, C: null, T: null
             }
        }

        self.deliveryText = {
            text: {
                Y: 'Доставлен', N: 'Не доставлен', M: 'В работе', P: 'Отправлен'
            },
            colors: {
                Y: 'bg-success', N: 'bg-danger', M: null, P: null
            }
        }

        self.handlersOrders = {
            orderText: self.orderText,
            deliveryText: self.deliveryText
        }

        self.dblclickOrder = e => {
            self.debuger({ ...self.debugParam, method:"dblclickOrder" })
            riot.route(`/orders/${e.item.row.id}`)
        }

        self.on('update', () => {
            self.debuger({ ...self.debugParam, method:"update" })
            localStorage.setItem('SE_section', 'contacts')
        })

        self.on('mount', () => {
            self.debuger({ ...self.debugParam, method:"mount" })
            riot.route.exec()
        })

        observable.on('datacatalog', (e) => {
            /** получение транс-табличных данных
             *  @param {object} e именаТаблиц-массивыСтрок
             *  @return {object} observable.trigger 'datacatalog'
             */

            self.debuger({ ...self.debugParam, method:"datacatalog" })
            self.datacatalog = e
        })

        observable.on('tempdatacatalog', (e) => {
            /** получение транс-табличных временных данных
             *  и слияние массивов (данные таблицы + данные селектора)
             *  @param {object} e именаТаблиц-массивыСтрок
             *  @return {object} observable.trigger 'datacatalog'
             */

            self.debuger({ ...self.debugParam, method:"tempdatacatalog" })
            self.datacatalog = Object.assign(self.datacatalog, e)
            observable.trigger('datacatalog', self.datacatalog)
        })

        self.debugParam = {
            module   : "person-edit.tag",
            dClass   : "person-edit",
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
