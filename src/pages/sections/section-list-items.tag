section-list-items
    catalog(name='section-item', sortable='true', object='SectionItem', cols='{ cols }', combine-filters='true'
    disable-limit='true', handlers="{ itemsHandlers }" , disable-col-select='true',
    add='{ add }', remove='{ remove }',
    dblclick='{ objectOpen }', filters='{ opts.filters }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='enabled')
                button.btn.btn-default.btn-sm(type='button',
                onclick='{ handlers.boolChange }',
                ontouchend='{ handlers.boolChange }',
                ontouchstart='{ stopPropagation }')
                    i(class='fa { row.enabled ? "fa-eye text-active" : "fa-eye-slash text-noactive" } ')
            datatable-cell(name='imageUrlPreview')
                img(src='{ row.imageUrlPreview }', alt='', width='60')
            datatable-cell(name='name') { row.name }
            datatable-cell(name='type') { handlers.types[row.type] }
            datatable-cell(name='note') { row.note }
            datatable-cell(name='sort', style='width: 10px;') { row.sort }



    script(type='text/babel').
        var self = this

        self.collection = 'SectionItem'
        self.idSection = 0;

        self.mixin('remove')

        var route = riot.route.create()

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'enabled', value: 'Вид'},
            { name: 'imageUrlPreview', value: ''},
            { name: 'name', value: 'Наименование'},
            { name: 'type', value: 'Тип элемента'},
            { name: 'note', value: 'Примечание'},
            { name: 'sort', value: 'Поряок'},
        ]

        self.itemsHandlers = {
            types: {
                idPrice : 'Товар',
                idGroup : 'Категория товара',
                idBrand : 'Бренд',
                idNew   : 'Новость',
                url     : 'Ссылка'
            },
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
                    object: 'SectionItem',
                    method: 'Save',
                    data: params,
                    error(response) {
                        rows.forEach(item => {
                            item[field] = oldValues[item.id][field]
                        })
                        self.update()
                    }
                })
            }
        }


        observable.on('section-reload', () => {
            self.tags['section-item'].reload()
        })


        self.add = e => {
            if (opts.section)
                riot.route(`/sections/new?section=${opts.section}`)
            else
                popups.create({title: 'Внимание!', text: 'Для добавления записи необходимо выбрать раздел!', style: 'popup-warning'})

        }

        self.objectOpen = e => riot.route(`/sections/${e.item.row.id}`)


        self.on('mount', () => {
            riot.route.exec()
        })