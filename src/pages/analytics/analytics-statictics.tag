analytics-statictics
    .row.m-b-3
        .col-md-12
            .checkbox-inline
                label
                    input(type='checkbox', checked='{ editMode }', onclick='{ toggleEditMode }')
                    | Режим прогнозирования
    form(onchange='{ change }', onsubmit='{ submit }', method='POST')
        .row
            .col-md-4
                .analytic-calc
                    .analytic-calc__title Сайт
                    .analytic-calc__body(style='border-left: 2px solid #E54A4F;')
                        .row
                            .col-xs-4
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Посетители&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Количество уникальных посетителей сайта')
                                    p.form-control-static(if='{ !editMode }') { item.countVisitors }
                                    input.form-control(name='countVisitors', if='{ editMode }', value='{ item.countVisitors }')
                            .col-xs-4
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Конверсия&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Сколько процентов от всех посетителей за период сделали заказы')
                                    p.form-control-static(if='{ !editMode }') { item.siteConversion }%
                                    .input-group(if='{ editMode }')
                                        input.form-control(name='siteConversion', value='{ item.siteConversion }')
                                        .input-group-addon
                                            | %
                            .col-xs-4
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Заказы&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Количество клиентов, которые сделали заказ')
                                    p.form-control-static(if='{ !editMode }') { item.countAllCustomers }
                                    input.form-control(name='countAllCustomers', if='{ editMode }', value='{ item.countAllCustomers }')
                        .row
                            .col-xs-12
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Рекламный бюджет&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Сумма потраченного рекламного бюджета для расчета ROI')
                                    input.form-control(name='advertisingBudget', value='{ item.advertisingBudget }')

            .col-md-4
                .analytic-calc
                    .analytic-calc__title Отдел продаж
                    .analytic-calc__body(style='border-left: 2px solid #A086D3;')
                        .row
                            .col-xs-4
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Конверс.&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Сколько процентов от всех заказов за период станут в итоге вашими клиентами')
                                    p.form-control-static(if='{ !editMode }') { item.ordersConversion }%
                                    .input-group(if='{ editMode }')
                                        input.form-control(name='ordersConversion', value='{ item.ordersConversion }')
                                        .input-group-addon
                                            | %
                            .col-xs-4
                                .analytic-calc__form-group
                                    label.analytic-calc__label Клиенты
                                    p.form-control-static(if='{ !editMode }') { item.countPaidCustomers }
                                    input.form-control(name='countPaidCustomers', if='{ editMode }', value='{ item.countPaidCustomers }')
                            .col-xs-4
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Ср.чек&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Как посчитать средний чек, если у вас несколько товаров по разным ценам? ' +
                                        'Возьмите всю выручку за день/неделю/месяц и поделите на количество клиентов за этот же период.')
                                    p.form-control-static(if='{ !editMode }') { item.averageCheck }
                                    input.form-control(name='averageCheck', if='{ editMode }', value='{ item.averageCheck }')
                        .row
                            .col-xs-12
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Цена клиента&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Сколько вам стоит получить одного клиента')
                                    p(if='{ item.clientPrice != Infinity }').form-control-static
                                        | { item.clientPrice }
                                        i.fa.fa-rub
                                    p(if='{ item.clientPrice == Infinity }').form-control-static
                                        | ∞

            .col-md-4
                .analytic-calc
                    .analytic-calc__title Доход
                    .analytic-calc__body(style='border-left: 2px solid #A4C639;')
                        .row
                            .col-xs-6
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Рентабельность
                                        br
                                        | (без рекламы)&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Рентабельность считается по формуле R=(операц.прибыль / выручку)*100%. ' +
                                        'Как посчитать здесь операционную пибыль? Вычтите из выручки все расходы, ' +
                                        'кроме расходов на рекламу (они учитываются позже в формуле)')
                                    p.form-control-static(if='{ !editMode }') { item.rentability }%
                                    .input-group(if='{ editMode }')
                                        input.form-control(name='rentability', value='{ item.rentability }')
                                        .input-group-addon
                                            | %
                            .col-xs-6
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | Чистая прибыль&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='Ожидаемая чистая прибыль за период. ' +
                                        'Здесь уже учтены все расходы, включая расходы на рекламу')
                                    p.form-control-static(if='{ !editMode }') { item.profit }
                                    input.form-control(name='profit', if='{ editMode }', value='{ item.profit }')
                        .row
                            .col-xs-12
                                .analytic-calc__form-group
                                    label.analytic-calc__label
                                        | ROI&nbsp;
                                        i.icon-append.fa.fa-question-circle.text-muted(data-toggle='tooltip',
                                        data-placement='auto', title='',
                                        data-original-title='ROI - коэффициент, показывающий окупаемость инвестиций. ' +
                                        'ROI = (Средний чек * К-во клиентов * Рентабельность(без рекламы)/Расходы на рекламу)*100% ')
                                    p(if='{ item.ROI != Infinity }').form-control-static { item.ROI }%
                                    p(if='{ item.ROI == Infinity }').form-control-static ∞

    style(scoped).
        .analytic-calc {
            position: relative;
            margin-bottom: 15px;
        }

        .analytic-calc__body {
            padding: 0 0 0 20px;
        }

        .analytic-calc__title {
            font-size: 18px;
            text-align: center;
            padding-bottom: 10px;
        }

        .analytic-calc__label {
            font-size: 11px;
            line-height: 1;
            width: 100%;
            height: 14px;
            display: inline-block;
            text-align: center;
        }

        .analytic-calc__form-group {
            margin-bottom: 0;
            vertical-align: middle;
            text-align: center;
            padding-bottom: 10px;
        }

        .analytic-calc__body > .row:not(:last-child) {
            border-bottom: 1px solid #ccc;
        }

    script(type='text/babel').
        var self = this

        self.editMode = false
        self.mixin('change')
        self.item = {
            averageCheck: 0,
            siteConversion: 0,
            ordersConversion: 0,
            rentability: 0,
            clientPrice: 0,
            profit: 0,
            ROI: 0,
        }
        var advertisingBudget = 10000

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.item
            },
            set(value) {
                if (!self.editMode && typeof value === 'object') {
                    self.item = { ...value }
                    self.item.advertisingBudget = advertisingBudget
                } if (self.editMode) {
                    self.newValue = value
                    self.newValue.advertisingBudget = advertisingBudget
                }
            }
        })

        self.afterChange = e => {
            let name = e.target.name

            switch (name) {
                case 'advertisingBudget':
                    advertisingBudget = e.target.value
                    self.calc()
                    break
                case 'countVisitors':
                case 'siteConversion':
                    self.item.countAllCustomers = (self.item.countVisitors * self.item.siteConversion / 100).toFixed(0)
                    self.item.countPaidCustomers = (self.item.countAllCustomers * self.item.ordersConversion / 100).toFixed(0)
                    self.calc()
                    break
                case 'countAllCustomers':
                    self.item.countVisitors = (self.item.countAllCustomers / self.item.siteConversion * 100).toFixed(0)
                    self.item.countPaidCustomers = (self.item.countAllCustomers * self.item.ordersConversion / 100).toFixed(0)
                    self.calc()
                    break
                case 'ordersConversion':
                    self.item.countPaidCustomers = (self.item.countAllCustomers * self.item.ordersConversion / 100).toFixed(0)
                    self.calc()
                    break
                case 'countPaidCustomers':
                    self.item.countAllCustomers = (self.item.countPaidCustomers / self.item.ordersConversion * 100).toFixed(0)
                    self.item.countVisitors = (self.item.countAllCustomers / self.item.siteConversion * 100).toFixed(0)
                    self.calc()
                    break
                case 'averageCheck':
                case 'rentability':
                    self.calc()
                    break
            case 'profit':
                    self.item.sumPaidOrders = (+self.item.profit + +self.item.advertisingBudget) / (self.item.rentability / 100)
                    self.item.countPaidCustomers = (self.item.sumPaidOrders / self.item.averageCheck).toFixed(0)
                    self.item.countAllCustomers = (self.item.countPaidCustomers / self.item.ordersConversion * 100).toFixed(0)
                    self.item.countVisitors = (self.item.countAllCustomers / self.item.siteConversion * 100).toFixed(0)
                    self.calc()
                    break
            }
        }

        self.calc = () => {
            let sumPaidOrders = (self.item.averageCheck * self.item.countPaidCustomers) || 0
            let clientPrice = (self.item.advertisingBudget / self.item.countPaidCustomers) || 0
            let profit = ((sumPaidOrders * self.item.rentability / 100) - self.item.advertisingBudget) || 0
            let ROI = ((self.item.averageCheck * self.item.countPaidCustomers * self.item.rentability / 100) / self.item.advertisingBudget * 100) || 0

            self.item.sumPaidOrders = sumPaidOrders
            self.item.clientPrice = clientPrice.toFixed(0)
            self.item.profit = profit.toFixed(0)
            self.item.ROI = ROI.toFixed(2)
        }


        self.toggleEditMode = e => {
            self.editMode = !self.editMode
            if (self.editMode)
                self.newValue = { ...self.item }
            else
                self.item = self.newValue
        }

        self.on('update', () => {
            if (!self.editMode) {
                let averageCheck = (self.item.sumPaidOrders / self.item.countPaidCustomers) || 0
                let siteConversion = (self.item.countAllCustomers / self.item.countVisitors * 100) || 0
                let ordersConversion = (self.item.countPaidCustomers / self.item.countAllCustomers * 100) || 0
                let rentability = ((self.item.sumPaidOrders - self.item.sumPurchase) / self.item.sumPaidOrders * 100) || 0
                let clientPrice = (self.item.advertisingBudget / self.item.countPaidCustomers) || 0
                let profit = (self.item.sumPaidOrders * rentability / 100 - self.item.advertisingBudget) || 0
                let ROI = ((averageCheck * self.item.countPaidCustomers * rentability / 100) / self.item.advertisingBudget * 100) || 0

                self.item.averageCheck = averageCheck.toFixed(2)
                self.item.siteConversion = siteConversion.toFixed(4)
                self.item.ordersConversion = ordersConversion.toFixed(2)
                self.item.rentability = rentability.toFixed(2)
                self.item.clientPrice = clientPrice.toFixed(0)
                self.item.profit = profit.toFixed(0)
                self.item.ROI = ROI.toFixed(2)
            }
        })

        self.submit = () => {}

        self.on('mount', () => {
            $(self.root).find('[data-toggle="tooltip"]').tooltip()
        })
