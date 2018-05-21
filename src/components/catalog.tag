| import debounce from 'lodash/debounce'
| import 'components/datatable.tag'
| import 'components/bs-pagination.tag'

catalog
    .row
        .col-md-12
            form(name='filters', onchange='{ find }')
                #{'yield'}(from='filters')

    .row
        .col-lg-7.col-md-12.col-sm-12.col-xs-12
            .form-inline.m-b-2
                button.btn(if='{ opts.allselect && (totalCount > 0)  }', type='button', class='{ allMode ? "btn-primary" : "btn-default"  }',
                onclick='{ selectedAll }', title='{ allMode ? "Снять выделение" : "Выделить всё" }')
                    i.fa(class='{ allMode ? "fa-toggle-on" : "fa-toggle-off" }')
                button.btn.btn-primary(if='{ opts.add }', onclick='{ opts.add }', type='button', title='Добавить')
                    i.fa.fa-plus
                    span.hidden-sm.hidden-xs
                        |&nbsp;Добавить
                button.btn.btn-success(if='{ opts.reload }', onclick='{ reload }', title='Обновить (Ctrl+R)', type='button')
                    i.fa.fa-refresh
                button.btn.btn-danger(if='{ opts.remove && selectedCount}', onclick='{ remove }', title='Удалить', type='button')
                    i.fa.fa-trash { (selectedCount > 1) ? "&nbsp;" : "" }
                    span.badge(if='{ selectedCount > 1 }') { selectedCount }

                #{'yield'}(from='head')
        .col-lg-5.col-md-12.col-sm-12.col-xs-12
            form.form-inline.text-right.m-b-2
                .form-group(if='{ opts.search }')
                    .input-group
                        input.searchCatalog.form-control(name='search', type='text', title='Поиск (Ctrl+F)', placeholder='Поиск', onkeyup='{ find }')
                        span.input-group-btn
                            button.btn.btn-default(onclick='{ find }', type='submit')
                                i.fa.fa-search
                .form-group.hidden-xs(if='{ showSearchFields }')
                    .btn-group
                        datatable-search-select.dropdown(if='{ tags.datatable }', table='{ tags.datatable }',
                         fields='{ searchFields  }' store='{ storeSettings }' align='right')
                .form-group.hidden-xs(show='{ !opts.disablepagination }')
                    select.form-control(value='{ pages.limit }', onchange='{ limitChange }')
                        option 15
                        option 30
                        option 50
                        option 100
                        option 1000
                .form-group.hidden-xs(if='{ !opts.disableColSelect }')
                    .btn-group(if='{ opts.cols && opts.cols.length }')
                        datatable-columns-select.dropdown(if='{ tags.datatable }', table='{ tags.datatable }', align='right')
    .row
        .col-md-12
            .table-responsive
                datatable(
                    cols        = '{ opts.cols }',
                    rows        = '{ items }',
                    handlers    = '{ opts.handlers }',
                    dblclick    = '{ opts.dblclick }',
                    sortable    = '{ opts.sortable }',
                    contextMenu = '{ opts.contextMenu }',
                    reorder     = '{ opts.reorder }',
                    loader      = '{ loader }'
                )
                    #{'yield'}(from='body')
                    #{'yield'}

    .row(show='{ !opts.disablepagination } && { !opts.offtotal }')
        .col-md-12
            bs-pagination(show='{ !opts.disablepagination }', name='paginator', onselect='{ pages.change }', pages='{ pages.count }', page='{ pages.current }')
            .pull-right(show='{ !opts.offtotal }', style='margin: 20px 0; height: 34px; line-height: 34px;')
                #{'yield'}(from='aggregation')
                strong Всего: { totalCount }

    style(scoped).
        :scope {
            position: relative;
            display: block;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.totalCount = 0
        self.allMode = false;
        self.allIds = [];
        self.lastParams = {};
        self.isFirstRefresh = true
        self.searchFields = []
        self.showSearchFields = false

        /** 2018.04.10 закоментированно, тк не определено назначение метода ("выделить все" работает без него),
         *  метод вызывал ошибку при запуске всплывающего окна с каталогом (паралельный запуск 2 каталогов),
         *  при сворачивании всплывающего окна и клике на главный каталог - появлялась ошибка и не срабатывал первый клик
         */
        // observable.off('catalog-recount').on('catalog-recount', (allMode) => {
        //     allMode = (typeof allMode !== 'undefined') ?  allMode : false;
        //
        //     console.log(self.tags.datatable)
        //
        //     var sr = self.tags.datatable.getSelectedRows().length;
        //     var tc = self.totalCount;
        //
        //
        //     //console.log('self.allMode == ' + self.allMode);
        //     if(self.tags.datatable !== undefined){
        //
        //         console.log(sr + ' из ' + self.totalCount);
        //
        //         if(self.totalCount == sr && self.totalCount > 1){
        //             self.allMode = true;
        //         } else if(self.totalCount > sr){
        //             self.allMode = false;
        //         }
        //     }
        //
        //     if(allMode) {
        //         if(sr > 0){
        //             self.allMode = true;
        //         }
        //     }
        // });

        self.selectedAll = () => {

            self.debuger({ ...self.debugParam, method:"selectedAll" })

            self.allMode = self.tags.datatable.selectAllRows(self.allMode);
            if(self.allMode){
                self.selectedCount = self.totalCount
            }

            observable.trigger('catalog-recount',true);
        }

        self.getSelectedMode = function () {

            self.debuger({ ...self.debugParam, method:"getSelectedMode" })

            if (self.allMode)
                return { allMode: self.allMode, allModeLastParams: self.lastParams };
            else {
                let rows = self.tags.datatable.getSelectedRows()
                let ids = rows.map(item => item.id)
                return { ids, allMode: false }
            }
        }

        self.pages = {
            count: 0,
            current: 1,
            limit: 15,
            change: function (e) {
                self.pages.current = e.currentTarget.page
                self.reload()
            }
        }

        self.reload = (tempparam, e, relAPI) => {

            /** перезагрузить
             *
             *  @@@@@@ @@@@@@ @@     @@@@@@    @@    @@@@@@   |
             *  @@  @@ @@     @@     @@  @@   @@@@   @@   @@  |
             *  @@@@@@ @@@@@@ @@     @@  @@  @@  @@  @@   @@  |
             *  @@ @@  @@     @@     @@  @@ @@@@@@@@ @@   @@  |
             *  @@  @@ @@@@@@ @@@@@@ @@@@@@ @@    @@ @@@@@@   |
             *
             * @param {obj} tempparam  произвольные параметры из методов
             * @param {boll} tempparam['dcreset']  принудит. запускает обнов. из API (сбрас. данные из памяти catalog)
             */

            self.debuger({ ...self.debugParam, method:"reload" })

            self.debuger({ ...self.debugParam, method:"reload",
                groupLog: "reload", dComment:"opts", dArray: opts })

            self.trigger('reload')
            self.allMode = false;
            self.loader = true

            if (opts.disablepagination) {
                delete self.pages.limit // удалить лимит по кол-ву строк из параметров (в API)
            }

            if (tempparam && tempparam['dcreset']) self.datacatalog = undefined

            if (opts.limit)
                self.pages.limit = opts.limit
            self.update()

            var sort
            if (self.tags.datatable)
                sort = self.tags.datatable.getSortedColumn()

            var params = {}
            params.offset = (self.pages.current - 1) * self.pages.limit

            if (params.offset < 0) {
                params.offset = 0
            }

            params.limit = self.pages.limit

            if (sort) {
                params.sortBy = sort.name                 // name столбца сортировки
                params.sortOrder = sort.dir.toLowerCase()
            }

            if (opts.search && self.search) {
                params.searchText = self.search.value
            }

            if (opts.id) {
                params.id = opts.id
            }

            if (opts.curr) {
                params.curr = opts.curr
            }

            if (opts.filters && opts.filters instanceof Array)
                params.filters = opts.filters
            else
                params.filters = serializeFilters()

            if (opts.combineFilters && opts.filters && opts.filters instanceof Array) {
                params.filters = [...serializeFilters(), ...opts.filters]
            }


            if (opts.systemfilters && self.isFirstRefresh)
                params.filters = opts.systemfilters


            if(self.handlers){
                self.handlers['params'] = params
            }

            self.debuger({ ...self.debugParam, method:"reload",
                groupLog: "reload", dComment:"params", dArray: params })

            /** ПОЛУЧЕНИЕ ДАННЫХ ИЗ БД И ТРАНС-ТАБЛИЧНЫХ ДАННЫХ
             *  @param {object} params           именнованны массив
             *  @param {str}    opts.method      произвольный метод или поумолчанию 'Fetch'
             *  @param {int}    params.id        фильтрация результатов по id (пример: получение групп в которых состоит контакт)
             *  @param {str}    params.curr      вернуть значения в валюте отличной от базовой
             *  @param {array}  opts.items       указатель на раздел, где храниться список значений (по умолчанию items)
             *  @param {object} opts.response    передает результаты СОВЕРШЕННОГО запроса (exm: response = '{ item }', )
             *  @param {array}  opts.count       указатель на раздел, где храниться длина списка (по умолчанию count)
             *
             *  DataCatalog
             *  @param {bool}   opts.writeDC     записать значения из списка в транс-табличные данные (с привязкой по opts.object)
             *  @param {str}    opts.getDC       добавить в список значения из транс-табличных данных (указать opts.object таблицы-родителя, откуда данные)
             *
             *  @param {bool}   opts.offtotal    true - отключить отображение "Всего" в итогах таблицы
             *  @param {bool}   opts.disablePagination
             *                                   true - удаляет лимит из свойств в запросе,
             *                                   блок. панели перекл. страниц и выставления лимита
             *                                   (в общем отключение пролистывания)
             */

            if (opts.response) {
                self.reloadProcessingResult(opts,params, opts.response) // если данные уже есть - запрос не нужен
                self.update({
                    selectedCount: 0,
                    loader: false,
                    isFind: false
                })
            } else {
                API.request({
                    object: opts.object,
                    method: opts.method || 'Fetch',
                    cookie: opts.cookie || undefined,
                    data: params,
                    notFoundRedirect: false,
                    success(response, xhr) {
                        self.reloadProcessingResult(opts,params, response,xhr)
                    },
                    error(response, xhr) {
                        self.pages.count = 0
                        self.pages.current = 0
                        self.items = []
                        self.tags.paginator.update({pages: self.pages.count, page: self.pages.current})
                    },
                    complete(response, xhr) {

                        self.debuger({ ...self.debugParam, method:"reload",
                            groupLog: "reload", dComment:"complete", dArray: response })

                        self.update({
                            selectedCount: 0,
                            loader: false,
                            isFind: false
                        })
                    }
                })
            }
        }; // перезагрузить

        self.reloadProcessingResult = (opts, params, response, xhr) => {

            /** обработчик результатов запроса/входныхДанных
             *
             *  @@@@@@ @@@@@@ @@     @@@@@@    @@    @@@@@@     @@@@@@ @@@@@@  |
             *  @@  @@ @@     @@     @@  @@   @@@@   @@   @@    @@  @@ @@  @@  |
             *  @@@@@@ @@@@@@ @@     @@  @@  @@  @@  @@   @@    @@@@@@ @@@@@@  |
             *  @@ @@  @@     @@     @@  @@ @@@@@@@@ @@   @@    @@     @@ @@   |
             *  @@  @@ @@@@@@ @@@@@@ @@@@@@ @@    @@ @@@@@@     @@     @@  @@  |
             *
             * @param {obj} params    параметры запроса
             * @param {obj} response  ответ на запрос
             * @param {obj} xhr
             * @return {array} tempdatacatalog запись значений таблицы в транс-табличные данные
             *
             * 1 при наличии параметра в опциях - заменяем
             * 2 добавить из транс-табличных данных данные по ключу ...
             * 3 запись всех значений в транс-табличные данные
             *
             * fixme в последствии при необходимости прописать передачу xhr
             */

            self.debuger({ ...self.debugParam, method:"reloadProcessingResult" })
            self.debuger({ ...self.debugParam, method:"reloadProcessingResult",
                groupLog: "reload", dComment:"response", dArray: response })

            if (opts.items) response.items = response[opts.items] // 1
            if (opts.count) response.count = response[opts.count]

            if ( opts.getdc &&                                    // 2
                self.datacatalog &&
                self.pages.current == 1
            ) { self.readTranceData(response, params)
            } else if (opts.getdc ||
                opts.getdc
            ) { self.readTranceDataFirst(response, params) }

            self.lastParams = params;
            if (opts.exception) {
                self.tags.datatable.exceptionFilter(response.items, opts.exception)
            }
            if ('beforeSuccess' in opts && typeof(opts.beforeSuccess) === 'function')
                opts.beforeSuccess.call(this, response, xhr)

            self.pageCurr = response.pageCurr
            self.totalCount = response.count
            self.allIds = response.items.map(item => {
                return item.id
            })
            self.pages.count = Math.ceil(response.count / self.pages.limit)
            if (self.pages.current > self.pages.count) {
                self.pages.current = self.pages.count
            }
            self.items = response.items ? response.items : []

            if (opts.writedc) {self.writeTranceData()}           // 3

            self.searchFields = response.searchFields ? response.searchFields : []
            self.showSearchFields = self.searchFields.length > 0
            self.tags.paginator.update({pages: self.pages.count, page: self.pages.current})
            self.isFirstRefresh = false
            self.update()

        } // обработчик результатов запроса/входныхДанных

        self.readTranceData = (response, params) => {

            /** читать из транс-табличных данных по ключу
             *  (новосозданные строки определяются по отсутствию ключа!)
             *  @param {object} response данные по странице
             *  @param {object} params ид, сортировка...
             *  @return {object} observable.trigger 'datacatalog'
             */

            self.debuger({ ...self.debugParam, method:"readTranceData" })

            self.datacatalog[opts.getdc].forEach(item => {
                response.items.push(item)
            }) // добавляем к значениям из БД
            response.items = self.datacatalog[opts.getdc]

            var uniq = {}
            var withoutId = [] // только созданные значения
            response.items.forEach(item => {
                if (item.id) uniq[item.id] = item
                else withoutId.push(item)
            }) // фильтруем уникальные значения по id
            response.items = [] // очистка исходного массива
            for (var item in uniq) {
                response.items.push(uniq[item])
            } // возвращаем уникальные значения
            response.items = response.items.concat(withoutId); // возвращаем значения без id (только созданные)
            if (opts.disablepagination) {
                response.count = response.items.length
                response.groupsCount = response.count
            } // определяем длину списка НА СТРАНИЦЕ

            self.datacatalog[opts.getdc] = response.items
            observable.trigger('datacatalog', self.datacatalog) // запис. в транс-табл. данные объединенны данные
            self.sorting(response.items, params.sortBy, params.sortOrder)
        }

        self.readTranceDataFirst = (response, params) => {

            /** читать из транс-табличных данных по ключу (первый запуск)
             *  @param {object} response данные по странице
             *  @param {object} params ид, сортировка...
             *  @return {object} observable.trigger 'datacatalog'
             */

            self.debuger({ ...self.debugParam, method:"readTranceDataFirst" })

            self.datacatalog = {}
            self.datacatalog[opts.getdc] = []
            self.datacatalog[opts.getdc] = response.items
            observable.trigger('datacatalog', self.datacatalog) // запис. в транс-табл. данные объединенны данные
            self.sorting(response.items, params.sortBy, params.sortOrder)
        }

        self.writeTranceData = () => {

            /** запись в транс-табличные данные по ключу
             *  @param {array} self.items массив значений на запись
             *  @return {object} observable.trigger 'tempdatacatalog'
             */

            self.debuger({ ...self.debugParam, method:"writeTranceData" })

            if (self.datacatalog == undefined) {
                self.datacatalog = {}
            }
            self.datacatalog[opts.object] = self.items
            observable.trigger('tempdatacatalog', self.datacatalog) // записываем в транс-табличные временные данные
        }

        self.sorting = (items, sort, desc) => {

            /** сортировка объектов в массиве по свойству
             *  @param {array} items значения для обработки
             *  @param {str} sort имя столбца сортировки
             *  @param {str} desc порядок сортировки (по возростанию / по убыванию)
             *  @return {array} items
             */

            self.debuger({ ...self.debugParam, method:"sorting" })

            var result = items.sort(function(a,b) {
                if      (a[sort] < b[sort]) return -1
                else if (a[sort] > b[sort]) return 1
                else                        return 0
            })
            if (desc == "desc") result.reverse()
        }

        self.remove = e => {

            /** удалить */

            self.debuger({ ...self.debugParam, method:"remove" })

            var _this = this,
                itemsToRemove = [];

            if(self.allMode !== true){
                _this.items.forEach((item, i, arr) => {
                    if(item.__selected__ == true && item.id) {
                        delete _this.items[i]
                        itemsToRemove.push(item.id)
                    } else if (item.__selected__ == true ) {
                        delete _this.items[i]
                    }
                })
            } else {
                itemsToRemove = {}
                itemsToRemove.allMode = true;
                itemsToRemove.allModeLastParams = self.lastParams;
            }

            // упорядочивание номеров в массиве
            let tempItems = []
            _this.items.forEach((item) => {
                tempItems.push(item)
            })
            _this.items = tempItems
            tempItems = null

            if (opts.remove)
                opts.remove.bind(this, e, itemsToRemove, self)();
            self.reload();
        };

        self.find = debounce(e => {
            if(e.key !== 'Control' && (e.key !== 'f' || (self.lastEvent !== 1)) ){
                self.pages.current = 1;
                self.reload();
                self.lastEvent = 0
            }
        }, 400);

        self.storeSettings = () => {

            /** Настройки магазина */

            self.debuger({ ...self.debugParam, method:"storeSettings" })

            let params = {
                searchFields: self.searchFields
            }

            self.debuger({ ...self.debugParam, method:"storeSettings",
                groupLog: "storeSettings", dComment:"params", dArray: response })

            API.request({
                object: opts.object,
                method: 'Store',
                data: params,
                success(response, xhr) {

                }
            })
        }


        self.limitChange = e => {

            /** изменить ограничение */

            self.debuger({ ...self.debugParam, method:"limitChange" })

            if (opts.store && opts.store.trim() !== '') {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`) || '{}')
                store.offset = 0
                store.limit = e.target.value
                localStorage[`shop24_${opts.store}`] = JSON.stringify(store)
            }
            self.pages.current = 1
            self.pages.offset = 0
            self.pages.limit = e.target.value
            self.reload()
        }


        var serializeFilters = () => {

            /** Сериализовать фильтры
             * Сериализация — это процесс преобразования объекта в поток байтов для сохранения или передачи в память,
             * в базу данных или в файл. Эта операция предназначена для того,
             * чтобы сохранить состояния объекта для последующего воссоздания при необходимости
             */

            self.debuger({ ...self.debugParam, method:"serializeFilters" })

            if (!self.filters) return

            var result = []
            var items = self.filters.querySelectorAll('[data-name]')

            for (var i = 0; i < items.length; i++) {
                var item = {}
                var required = items[i].getAttribute('data-required')
                var type = items[i].type ? items[i].type.toLowerCase() : ''

                var bool = items[i].getAttribute('data-bool')

                if (bool && bool.split(',').length === 2)
                    bool = bool.split(',')
                else
                    bool = false

                if (type === 'checkbox') {
                    let value = items[i].checked

                    if (bool) {
                        let i = value ? 0 : 1
                        item.value = bool[i]
                    } else {
                        item.value = items[i].checked
                    }
                }

                if (type != 'checkbox') {
                    item.value = items[i].value
                }

                if (item) {
                    item.field = items[i].getAttribute('data-name')
                    if (items[i].getAttribute('data-sign'))
                        item.sign = items[i].getAttribute('data-sign')
                    else
                        item.sign = '='
                    if (items[i].getAttribute('data-type'))
                        item.type = items[i].getAttribute('data-type')
                }

                if (type === 'checkbox' && bool instanceof Array) {
                    if (required || item.value != bool[1])
                        result.push(item)
                } else {
                    if (required || item.value)
                        result.push(item)
                }
            }

            if (result.length)
                return result
            else
                return []
        }

        var parseFilters = (filters) => {

            /** анализировать фильтры */

            self.debuger({ ...self.debugParam, method:"parseFilters" })

            if (!filters && !(filters instanceof Array))
                return

            let result = filters.map(item => {
                let {field, sign, value, type} = item

                if (type == 'bool')
                    value = value === '1'
                else if (typeof(value) !== 'boolean')
                    value = `'${value}'`

                return `[${field}]${sign}${value}`
            })

            return result.join(` AND `)
        }

        self.on('mount', () => {
            if (opts.store && opts.store.trim() !== '') {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`))
                if (store) {
                    if (store.limit)
                        self.pages.limit = store.limit

                    if (opts.cols && store.cols && typeof store.cols === 'object') {
                        var columns = Object.keys(store.cols)
                        opts.cols.forEach(item => {
                            if (columns.indexOf(item.name) !== -1)
                                item.hidden = true
                        })
                    }

                    if (store.sort && typeof store.sort === 'object') {
                        var column = Object.keys(store.sort)
                        if (column.length > 0)
                            opts.cols.forEach(item => {
                                if (item.name === column[0])
                                    item.dir = store.sort[column[0]]
                            })
                    }
                }
            }
            self.reload()
        })

        self.on('update', () => {
            if (opts.handlers)
                self.handlers = opts.handlers
        })

        observable.on('datacatalog', (e) => {

            /** получение транс-табличных данных
             *  @param {object} e таблицы-строки
             *  @return {object} self.datacatalog
             */

            self.datacatalog = e
        })

        self.one('updated', () => {

            self.debuger({ ...self.debugParam, method:"updated" })

            self.tags.datatable.on('row-selected', count => {
                self.selectedCount = count
                if(self.selectedCount === self.totalCount){
                    self.allMode = true
                }
                self.update()
            })
            self.tags.datatable.on('sort', () => {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`) || '{}')

                store.sort = {}

                let sort = self.tags.datatable.getSortedColumn()

                store.sort[sort.name] = sort.dir
                localStorage[`shop24_${opts.store}`] = JSON.stringify(store)
                self.reload()
            })
            self.tags.datatable.on('column-toggle', (name, hidden) => {
                let store = JSON.parse(localStorage.getItem(`shop24_${opts.store}`) || '{}')
                if (!('cols' in store))
                    store.cols = {}

                if (!hidden) {
                    store.cols[name] = hidden
                } else {
                    delete store.cols[name]
                }

                localStorage[`shop24_${opts.store}`] = JSON.stringify(store)
            })

        })

        self.lastEvent = 0;

        self.allParams = (params) => {

            self.debuger({ ...self.debugParam, method:"allParams" })

            var mode = self.allIds < self.selectedCount;
            if((params.ids || params.id ) && mode){
                var newParams = {};
                delete params.ids;
                delete params.id;
                newParams.allModeLastParams = self.lastParams;
                newParams.allModeParams = params;
                newParams.allMode = true;
            }
            if(newParams !== undefined){
                return newParams
            }
            return params;
        };

        // Горячие клавиши
        document.onkeydown = function(e) {
            if(e.ctrlKey){
                if(e.key == 'a'){
                    self.selectedAll();
                    return false;
                }
                if(e.key == 'f'){
                    self.lastEvent = 1
                    $('.searchCatalog').focus();
                    return false;
                }
                if(e.key == 'r'){
                    self.reload();
                    return false;
                }
            }
        };

        self.toggleSearchField = (e) => {
            console.log("ok");
            console.log(e);
        }


        self.debugParam = {
            module   : "catalog.tag",
            dClass   : "catalog",
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
                norm          : true,
                reload        : false,
                storeSettings : false,
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