import-products-modal-continue
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Импорт (Шаг 2 из 2)
        #{'yield'}(to="body")
            // loader(text='Импорт', indeterminate='true', if='{ loader }')
            div(id="myProgress", style='width: 100%; background-color: #ccc;', if='{ loader }')
                div(id="myBar", style='width: 0%; height: 30px; background-color: #0782C1; text-align: center; line-height: 30px; color: white;') 0%
            form(onchange='{ change }', onkeyup='{ change }', if='{ !loader }')

                // Вывод всех столбцов
                .container-fluid
                    table.table.table.table
                        thead
                            tr
                                th #
                                th Пример
                                th Тип
                        tbody
                            tr(each='{ category, i in item[0] }')
                                td
                                    | { i }
                                td(style='width: 55%;')
                                    div(style='width: 180px; overflow: hidden;') { item[1][i] || 'Пустая строка' }

                                td(style='width: 35%')
                                    select.form-control(onchange='{ changeitem }', name='{ category }')
                                        option(value='')
                                        option(
                                            each='{ russian, english in item[2] }',
                                            selected='{ item[0][i] == russian }',
                                            value='{ i }:{ russian }:{ english }',
                                            no-reorder
                                        ) { russian }
                                    //.help-block(style='max-height:50px; text-overflow: ellipsis; overflow: hidden; max-width: 150px')
                                        b Пример: {' '}
                                        | { item[1][i] || 'Пустая строка' }

                    //- //.row(each='{ category, i in item[0] }')
                    //-     .form-group
                    //-         label.control-label Столбец { '#' + i }
                    //-         .col-sm-6
                    //-             | hghjgjhg
                    //-         .col-sm-6
                    //-             select.form-control
                    //-                 option(value='')
                    //-                 option(
                    //-                     each='{ russian, english in item[2] }',
                    //-                     selected='{ item[0][i] == russian }',
                    //-                     value='{ english }',
                    //-                     no-reorder
                    //-                 ) { russian }
                    //-         .help-block(style='max-height:50px; text-overflow: ellipsis; overflow: hidden;')
                    //-             b Пример: {' '}
                    //-             | { item[1][i] || 'Пустая строка' }

                .form-group
                    label.control-label Тип импорта
                    br
                    label.radio-inline
                        input(type='radio', name='type', value='0', checked='{ item.type == 0 }')
                        | Обновление
                    label.radio-inline
                        input(type='radio', name='type', value='1', checked='{ item.type == 1 }')
                        | Вставка
                .form-group(if='{ item.type == 1 }')
                    .checkbox-inline
                        label
                            input(name='reset', type='checkbox', checked='{ item.reset }')
                            | Очистить базу данных перед импортом
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed', disabled='{ cannotBeClosed }') Закрыть
            button(onclick='{ parent.submit }', type='button', class='btn btn-primary btn-embossed', disabled='{ cannotBeClosed }', if='{ !loader }') Импорт


    script(type='text/babel').
        var self = this
        var items = JSON.parse(localStorage.getItem('shop24_import_products') || '{}')
        localStorage.removeItem('shop24_import_products')

        self.item = items.prepare

        // проверка наличия соотношений в профиле и замена (при положительном результате)
        var profiles = JSON.parse(localStorage.getItem("profiles"))
        if (profiles[profiles['groupNow']]['margins'] != undefined) {
            self.item[0] = profiles[profiles['groupNow']]['margins']
        }


        // прогрузка страницы
        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.error = false
            modal.mixin('validation')
            modal.mixin('change')
            modal.item = self.item

            // сохранение и передача пользовательских правок
            self.newItem = {
                'newTitele' : {},
                'newDB'     : {}
            }

            // пользовательские замены
            modal.changeitem = e => {

                let num_walue_db = e.target.value.split(':')
                let num          = Number(num_walue_db[0])
                let walue        = num_walue_db[1]
                let db           = num_walue_db[2]

                self.newItem.newTitele[num] = walue
                self.newItem.newDB[e.target.name] = db
            }
        })

        // отправка
        self.submit = () => {
            let modal = self.tags['bs-modal']
            modal.loader = true

            // замена на пользовательские значения
            for(var index in self.newItem.newTitele)
                self.item[0][index] = self.newItem.newTitele[index]
            for(var index in self.newItem.newDB)
                self.item[2][index] = self.newItem.newDB[index]

            items.prepare = self.item

            if(self.item.type) items.type = self.item.type
            if(self.item.reset) items.reset = self.item.reset

            if(self.item.type > -1 && self.item.type < 2){

                // прикрепляем к профилю соотношения полей
                var profiles = JSON.parse(localStorage.getItem("profiles"))
                profiles[profiles['groupNow']]['margins'] = items.prepare[0]
                var serialProfiles = JSON.stringify(profiles)
                localStorage.setItem('profiles', serialProfiles)

                var cycleNum   = 0
                var countPages = 0
                var pages      = null
                function repReq(pages, cycleNum) {
                    let data = {
                        'cycleNum'      : cycleNum,
                        'prepare'       : items.prepare,
                        'type'          : items.type,
                        'reset'         : items.reset,
                        'filename'      : items.filename,
                        'uploadProfile' : items.uploadProfile
                    }
                    API.request({
                        object: 'Product',
                        method: 'Import',
                        data:    data,
                        success(response) {
                            pages      = response.pages
                            cycleNum   = response.cycleNum
                            countPages = response.countPages

                            // прогресс-бар
                            var elem         = document.getElementById("myBar")
                            var progress     = (cycleNum+countPages)/2
                            var width        = progress / (pages) * 100
                            if (width <= 100){
                                elem.style.width = width + '%'
                                elem.innerHTML   = Math.round(width) * 1 + '%'
                                //elem.innerHTML = cycleNum+'/'+pages
                            }

                            if (progress <= pages){                            // переход в следующий цикл
                                //cycleNum   = cycleNum + 1                    // подгружаем следующую страницу
                                //if(cycleNum == 0) cycleNum = cycleNum + 2
                                return repReq(pages, cycleNum)
                            } else {                                           // закрытие / обновление / выход из цикла
                                 modal.modalHide()
                                 observable.trigger('products-reload')
                                 observable.trigger('categories-reload')
                                 observable.trigger('special-reload')
                                 // observable.trigger('products-imports-end')
                            }
                        }
                    })
                }
                repReq(pages, cycleNum)
            }
        }
