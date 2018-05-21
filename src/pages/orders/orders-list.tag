| import debounce from 'lodash/debounce'
| import 'components/catalog.tag'
| import moment from 'moment'

orders-list

    catalog(object='Order', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
    add='{ permission(add, "orders", "0100") }',
    remove='{ permission(remove, "orders", "0001") }',
    dblclick='{ permission(orderOpen, "orders", "1000") }',
    before-success='{ getAggregation }',store='orders-list', new-filter='true', allselect = "true",)
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control.date-picker(data-name='dateOrder', data-sign='>=', format='DD.MM.YYYY', value='{ parent.startDate }')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control.date-picker(data-name='dateOrder', data-sign='<=', format='DD.MM.YYYY', value='{ parent.endDate }')
                    .form-group
                        label.control-label Статус
                        select.form-control(data-name='status')
                            option(value='') Все
                            option(value='Y') Оплачен
                            option(value='N') Не оплачен
                            option(value='A') Предоплата
                            option(value='K') Кредит
                            option(value='P') Подарок
                            option(value='W') В ожидании
                            option(value='C') Возврат
                            option(value='T') Тест
                    .form-group
                        label.control-label Доставка
                        select.form-control(data-name='deliveryStatus')
                            option(value='') Все
                            option(value='Y') Доставлен
                            option(value='N') Не доставлен
                            option(value='M') В работе
                            option(value='P') Отправлен
                    .form-group(if='{ parent.managers.length > 0 }')
                        label.control-label Менеджер
                        select.form-control(data-name='idAdmin')
                            option(value='') Все
                            option(each='{ manager, i in parent.managers }', value='{ manager.id }', no-reorder) { manager.title }

                    .form-group
                        .checkbox-inline
                            label
                                input(type='checkbox', data-name='isDelete', data-bool='Y,N', data-required='true')
                                | Отменённые

        #{'yield'}(to='head')
            divider
            button.btn.btn-primary(
            type='button', onclick='{ parent.exportOrder }', title='Экспорт заказа в XLS')
                i.fa.fa-file-excel-o
            button.btn.btn-primary(
            type='button', onclick='{ parent.exportOrders }', title='Экспорт')
                i.fa.fa-upload


        #{'yield'}(to="body")
            datatable-cell(name='id', onclick='{ handlers.copyText }') { row.id }
            datatable-cell.text-right(name='dateOrder', onclick='{ handlers.copyText }') { row.dateOrderDisplay }
            datatable-cell(name='customer', onclick='{ handlers.copyText }') { row.customer }
            datatable-cell(name='customerPhone', onclick='{ handlers.copyText }') { row.customerPhone }
            datatable-cell.text-right(name='amount', onclick='{ handlers.copyText }')
                span(style='color: #ccc') {row.nameFront !== null && row.nameFront !== "" ? row.nameFront : ""}
                span  { row.amount.toFixed(2) }
                span(style='color: #ccc')  { row.nameFront !== null && row.nameFront !== "" ? "" : row.nameFlang !== null && row.nameFlang !== "" ? row.nameFlang : row.titleCurr }
            datatable-cell(name='status', class='{ handlers.orderText.colors[row.status] }')
                | { handlers.orderText.text[row.status] }
            datatable-cell(name='deliveryStatus', class='{ handlers.deliveryText.colors[row.deliveryStatus] }')
                | { handlers.deliveryText.text[row.deliveryStatus] }
            datatable-cell(name='namePaymentPrimary', onclick='{ handlers.copyText }') { row.namePaymentPrimary }
            datatable-cell(name='commentary', onclick='{ handlers.copyText }') { row.commentary }
            datatable-cell(name='manager', onclick='{ handlers.copyText }') { row.manager }
        #{'yield'}(to='aggregation')
            strong  Суммма:
            strong  {parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? parent.currTotal.nameFront : ""}
            strong  { (parent.totalAmount || 0) }
            strong  { parent.currTotal.nameFront !== null && parent.currTotal.nameFront !== "" ? "" : parent.currTotal.nameFlang !== null && parent.currTotal.nameFlang !== "" ? parent.currTotal.nameFlang : parent.currTotal.titleCurr }
            br

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Order'
        self.idManager = app.config.idUser
        self.startDate = ''
        self.endDate = ''


        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'dateOrder' , value: 'Дата заказа' },
            { name: 'customer' , value: 'Заказчик' },
            { name: 'customerPhone' , value: 'Телефон' },
            { name: 'amount' , value: 'Сумма' },
            { name: 'status' , value: 'Статус заказа' },
            { name: 'deliveryStatus' , value: 'Статус доставки' },
            { name: 'namePaymentPrimary' , value: 'Способ оплаты' },
            { name: 'commentary' , value: 'Примечание' },
            { name: 'manager' , value: 'Менеджер' },
        ]

        self.orderText = {
            text: {
                Y: 'Оплачен', N: 'Не оплачен', A: 'Предоплата', D: 'Отказ', K: 'Кредит', P: 'Подарок', W: 'В ожидании', C: 'Возврат', T: 'Тест'
            },
            colors: {
                //Y: '#98FB98', N: '#FFC1C1', A: '#FFFF00', K: '#FFAAAA', P: null, W: null, C: null, T: null
                Y: 'bg-success', N: 'bg-danger', A: 'bg-warning', K: 'bg-info', D: 'bg-danger', P: null, W: null, C: null, T: null
            }
        }

        self.deliveryText = {
            text: {
                Y: 'Доставлен', N: 'Не доставлен', M: 'В работе', P: 'Отправлен'
            },
            colors: {
                //Y: '#98FB98', N: '#FFC1C1', M: null, P: null
                Y: 'bg-success', N: 'bg-danger', M: null, P: null
            }
        }

        self.handlers = {
            orderText: self.orderText,
            deliveryText: self.deliveryText,
            copyText: function(elem) {
                copyToClipboard(elem.target)
            }
        }

        self.orderOpen = function (e) {
            self.debuger({ ...self.debugParam, method:"orderOpen" })
            riot.route(`/orders/${e.item.row.id}`)
        }

        self.getAggregation = (response, xhr) => {
            self.debuger({ ...self.debugParam, method:"getAggregation" })
            self.totalAmount = parseFloat(
                                   response.totalAmount.replace(" ", "")
                               ).toFixed(2)
            self.currTotal   = response.currTotal
        }

        self.add = () => riot.route('/orders/new')

        observable.on('orders-reload', function () {
            self.debuger({ ...self.debugParam, method:"orders-reload" })
            self.tags.catalog.reload()
        })

        self.on('mount', () => {
            self.debuger({ ...self.debugParam, method:"mount" })
            self.idManager = app.config.idUser
            self.update()
        })

        self.exportOrder = () => {
            self.debuger({ ...self.debugParam, method:"exportOrder" })
            let items = self.tags.catalog.tags.datatable.getSelectedRows()
            if (!items.length)
                return

            let id = items[0]["id"]
            API.request({
                object: 'Order',
                method: 'Export',
                data: { id },
                success(response) {
                    let a = document.createElement('a')
                    a.href = response.url
                    a.download = response.name
                    document.body.appendChild(a)
                    a.click()
                    a.remove()
                    self.update()
                }
            })
        }

        self.exportOrders = () => {
            self.debuger({ ...self.debugParam, method:"exportOrders" })
            API.request({
                object: 'Order',
                method: 'Export',
                success(response) {
                    let a = document.createElement('a')
                    a.href = response.url
                    a.download = response.name
                    document.body.appendChild(a)
                    a.click()
                    a.remove()
                    self.update()
                }
            })
        }

        self.getManagers = () => {
            self.managers = []
            API.request({
                object: 'PermissionUser',
                method: 'Fetch',
                success(response) {
                   self.debuger({ ...self.debugParam, method:"getManagers" })
                   self.managers = response.items
                   self.update()
                }
            })
        }

        self.getManagers()

        function copyToClipboard(elem) {
            self.debuger({ ...self.debugParam, method:"copyToClipboard" })

            // create hidden text element, if it doesn't already exist
            var targetId = "_hiddenCopyText_";
            var isInput = elem.tagName === "INPUT" || elem.tagName === "TEXTAREA";
            var origSelectionStart, origSelectionEnd;
            if (isInput) {
                // can just use the original source element for the selection and copy
                target = elem;
                origSelectionStart = elem.selectionStart;
                origSelectionEnd = elem.selectionEnd;
            } else {
                // must use a temporary form element for the selection and copy
                target = document.getElementById(targetId);
                if (!target) {
                    var target = document.createElement("textarea");
                    target.style.position = "absolute";
                    target.style.left = "-9999px";
                    target.style.top = "0";
                    target.id = targetId;
                    document.body.appendChild(target);
                }
                target.textContent = elem.textContent.trim();
            }
            // select the content
            var currentFocus = document.activeElement;
            target.focus();
            target.setSelectionRange(0, target.value.length);

            // copy the selection
            var succeed;
            try {
                succeed = document.execCommand("copy");
            } catch(e) {
                succeed = false;
            }
            // restore original focus
            if (currentFocus && typeof currentFocus.focus === "function") {
                currentFocus.focus();
            }

            if (isInput) {
                // restore prior selection
                elem.setSelectionRange(origSelectionStart, origSelectionEnd);
            } else {
                // clear temporary content
                target.textContent = "";
            }
            return succeed;
        }

        self.debugParam = {
            module   : "orders-list.tag",
            dClass   : "orders-list",
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
