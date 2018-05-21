| import './currency-new-modal.tag'

currencies
    catalog(object='Currency', cols='{ cols }',
    add='{ permission(add, "currencies", "0100") }',
    remove='{ permission(remove, "currencies", "0001") }',
    dblclick='{ permission(currencyEdit, "currencies", "1010") }')
        #{'yield'}(to='body')
            datatable-cell(name='title') { row.title }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='dateReplace') { row.dateReplace }
            datatable-cell(name='rate') { row.rate }
            datatable-cell(name='rateDisplay') { row.rateDisplay }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Currency'

        self.cols = [
            {name: 'title', value: 'Наименование'},
            {name: 'name', value: 'Код'},
            {name: 'rateDate', value: 'Дата'},
            {name: 'rate', value: 'Курс'},
            {name: 'rateDisplay', value: 'Текст'},
        ]

        self.add = () => {
            modals.create('currency-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = _this.item
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Currency',
                            method: 'Save',
                            data: params,
                            success(response) {
                                popups.create({title: 'Успех!', text: 'Валюта добавлена!', style: 'popup-success'})
                                _this.modalHide()
                                self.tags.catalog.reload()
                            }
                        })
                    }
                }
            })
        }

        self.currencyEdit = e => {
            modals.create('currency-new-modal', {
                item: e.item.row,
                type: 'modal-primary',
                title: 'Редактор валюты',
                submit: function () {
                    var _this = this
                    var params = _this.item

                    API.request({
                        object: 'Currency',
                        method: 'Save',
                        data: params,
                        success(response) {
                            popups.create({title: 'Успех!', text: 'Валюта изменена!', style: 'popup-success'})
                            _this.modalHide()
                            self.tags.catalog.reload()
                        }
                    })
                }
            })
        }