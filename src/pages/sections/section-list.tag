section-list
    .row
        .col-md-4.col-xs-12
            catalog(name='section-page', object='SectionPage', cols='{ pageCols }' reload='true', onclick='{ pageclick}',
                disable-limit='true', disable-col-select='true', remove='{ remove }', handlers='{ handlers }',
            )
                #{'yield'}(to='body')
                    datatable-cell(name='enabled')
                        button.btn.btn-default.btn-sm(type='button',
                        onclick='{ handlers.boolChange }',
                        ontouchend='{ handlers.boolChange }',
                        ontouchstart='{ stopPropagation }')
                            i(class='fa { row.enabled ? "fa-eye text-active" : "fa-eye-slash text-noactive" } ')
                    datatable-cell(name='title') { row.title }
                    datatable-cell(name='code') { row.code }
                    datatable-cell(name='page') { row.page }
                    //datatable-cell(name='section') { row.section }


        .col-md-8.col-xs-12
            section-list-items(name='section-item', filters='{ categoryFilters }', section='{ idSection }')

    script(type='text/babel').
        var self = this

        self.collection = 'SectionPage'
        self.idSection = 0;
        self.categoryFilters = [{field: 'idSection', sign: 'IN', value: self.idSection }]

        self.mixin('remove')

        var route = riot.route.create()

        self.handlers = {
            checkPermission: self.checkPermission,
            permission: self.permission,
            boolChange(e) {
                var _this = this
                e.stopPropagation()
                e.stopImmediatePropagation()
                _this.row[_this.opts.name] = _this.row[_this.opts.name] ? 0 : 1
                self.update()

                var params = {}
                params.id = _this.row.id
                params[_this.opts.name] = _this.row[_this.opts.name]
                API.request({
                    object: 'SectionPage',
                    method: 'Save',
                    data: params,
                    error(response) {
                        rows.forEach(item => {
                            item[field] = oldValues[item.id][field]
                        })
                        self.update()
                    }
                })
            },
        }

        self.pageCols = [
            { name: 'enabled', value: 'Вид'},
            { name: 'code', value: 'Код'},
            { name: 'title', value: 'Наименование'},
            { name: 'page', value: 'Страница'},
            /*{ name: 'section', value: 'Раздел'},*/
        ]

        self.one('updated', () => {

        })

        self.pageclick = e => {
            let rows = self.tags['section-page'].tags.datatable.getSelectedRows()
            self.idSection = rows[0].idSection;
            self.categoryFilters = [{field: 'idSection', sign: 'IN', value: self.idSection }]
            self.update()
            observable.trigger('section-reload')
        }

        self.on('mount', () => {
        })