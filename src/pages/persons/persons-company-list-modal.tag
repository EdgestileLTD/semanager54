persons-company-list-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Контакты
        #{'yield'}(to="body")
            ul.nav.nav-tabs.m-b-2
                li(each='{ tabs }', class='{ active: name == tab }')
                    a(href='#', onclick='{ tabClick }')
                        span { title }

            catalog(if='{ tab == "contacts" }', name='contacts', object='Contact', cols='{ contactCols }',
            dblclick='{ submit }', search='true', reload='false', disable-col-select='1', add='{ add}')
                datatable-cell(name='id') { row.id }
                datatable-cell(name='displayName') { row.displayName }
                datatable-cell(name='username') { row.username }

            catalog(if='{ tab == "companies" }', name='companies', object='Company', cols='{ companyCols }',
            dblclick='{ submit }', search='true', reload='false', disable-col-select='1')
                datatable-cell(name='id') { row.id }
                datatable-cell(name='displayName') { row.name }

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ submit }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.item = {}
            modal.tab = 'contacts'

            modal.tabClick = e => {
                modal.tab = e.item.name
            }

            modal.submit = e => {
                parent.opts.submit.bind(modal)()
            }

            modal.tabs = [
                {name: 'contacts', title: 'Контакты'},
                {name: 'companies', title: 'Компании'},
            ]

            modal.contactCols = [
                {name: 'id', value: '#'},
                {name: 'displayName', value: 'Ф.И.О'},
                {name: 'username', value: 'Логин'}
            ]

            modal.companyCols = [
                {name: 'id', value: '#'},
                {name: 'name', value: 'Наименование'},
            ]

            modal.add = () => {
                modals.create('person-new-modal', {
                    type: 'modal-primary',
                    submit() {
                        var _this = this
                        var params = { firstName: _this.name.value, email: _this.email.value }
                        API.request({
                            object: 'Contact',
                            method: 'Save',
                            data: params,
                            success(response, xhr) {
                               // modals.update()
                                modal.tags[modal.tab].reload()
                                popups.create({title: 'Успех!', text: 'Контакт добавлен!', style: 'popup-success'})
                                modal.update()
                                _this.modalHide()
                                //let e = { item: { id: response.id, }}
                                //opts.submit.bind(this)
                                //self.update()
                                //this.modalHide()
                                //if (response && response.id)
                                //self.personOpenItem(response.id)
                            }
                        })
                    }
                })
            }

            modal.submit = () => {
                let items = modal.tags[modal.tab].tags.datatable.getSelectedRows()
                if (!items.length) return

                if (modal.tab == 'contacts') {
                    modal.item.idAuthor = items[0].id
                    modal.item.customer = items[0].displayName
                    modal.item.idCompany = null
                } else {
                    modal.item.idCompany = items[0].id
                    modal.item.customer = items[0].name
                    modal.item.idAuthor = null
                }
                opts.submit.bind(this)()
            }

        })