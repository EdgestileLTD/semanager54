export-products-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Экспорт
        #{'yield'}(to="body")
            div(id="myProgress", style='width: 100%; background-color: #ccc;', if='{ loader }')
                div(id="myBar", style='width: 0%; height: 30px; background-color: #0782C1; text-align: center; line-height: 30px; color: white;') 0%
            form(onchange='{ change }', onkeyup='{ change }', if='{ !loader }')


                // Вывод всех столбцов
                .container-fluid
                    table.table.table.table
                        thead
                            tr
                                th #
                                th Тип
                                th Вставка в импорт
                        tbody
                            tr(each='{ i, v in units }')
                                td
                                    | { i }
                                td(style='width: 80%;')
                                    div(style='width: 180px; overflow: hidden;') { v.column || 'Пустая строка' }
                                td(style='width: 20%')
                                    // button.btn.btn-default.btn-sm(
                                    //     onclick='{ switch }',
                                    //     type='button',
                                    //     value='{ i }'
                                    // )
                                    //     i(class='fa { v.checkbox == "Y" ? "fa-eye text-active" : "fa-eye-slash text-noactive" } ')
                                    input(
                                        onclick='{ switch }',
                                        checked='{ (v.checkbox == "Y") }',
                                        type='checkbox',
                                        value = '{ i }'
                                    )
                    //label.control-label Формат экспорта
                    //select.form-control(name='delimiter', value='{ item.delimiter }')
                    //    option(
                    //        each='{ i in delimiters }', value='{ i.name }',
                    //        selected='{ i.name == parent.item.delimiter }', no-reorder
                    //    ) { i.title }

                    .checkbox-inline
                        label
                            input(
                                onclick='{ switchMod }',
                                checked='{ (expModif == "Y") }',
                                type='checkbox',
                            )
                            | Экспортировать модификации


        #{'yield'}(to='footer')
            button(
                onclick='{ modalHide }',
                type='button',
                class='btn btn-default btn-embossed',
                disabled='{ cannotBeClosed }'
            ) Закрыть
            button(
                onclick='{ parent.submit }',
                type='button',
                class='btn btn-primary btn-embossed',
                disabled='{ cannotBeClosed }',
                if='{ !loader }'
            ) Экспорт


    script(type='text/babel').
        var self = this


        /*
        * ПРОГРУЗКА СТРАНИЦЫ
        * statusPreview - параметр-светофор, при значении true, файл excel не создается
        */
        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            let data = {
                'statusPreview' : true,
            }

            // получение колонок из браузера и БД
            API.request({
                object: 'Product',
                method: 'Export',
                data: data,
                success: function(response) {
                    modal.units = {}
                    modal.columns = response['headerCSV']
                    modal.expModif = (localStorage.getItem('shop24_export_modif') || 'N')
                    let jsonUnits = JSON.parse(localStorage.getItem('shop24_export_products') || '{}')
                    localStorage.removeItem('shop24_import_products')


                    // слияние данных (данные браузера в приоритете)
                    for (var i = 0; i < modal.columns.length; i++) {
                        if(
                            jsonUnits[i] && jsonUnits[i].column &&
                            jsonUnits[i].column == modal.columns[i]
                        )
                            modal.units[i] = jsonUnits[i]
                        else
                            modal.units[i] = {
                                'column' :    modal.columns[i],
                                'checkbox' : 'Y'
                            }
                    }
                    modal.update()
                }
            })


            // переключатель чекбокса
            modal.switch = e => {
                let i = e.target.value
                if(modal.units[i].checkbox == 'Y') {
                    delete modal.units[i].checkbox
                    modal.units[i].checkbox = 'N'
                } else {
                    delete modal.units[i].checkbox
                    modal.units[i].checkbox = 'Y'
                }
                modal.update()
            }

            // переключатель чекбокса Модификаций
            modal.switchMod = e => {
                if(modal.expModif == 'Y') modal.expModif = 'N'
                else                      modal.expModif = 'Y'
                modal.update()
            }


        })


        // отправка
        self.submit = () => {
            let modal = self.tags['bs-modal']
            modal.loader = true

            // сохранение профиля экспорта (растановка чекбоксов)
            var profile = JSON.stringify(modal.units)
            localStorage.setItem('shop24_export_products', profile)
            localStorage.setItem('shop24_export_modif', modal.expModif)

            /**
            * прикрепляем к профилю соотношения полей
            * объявляем переменные
            * запускаем цикл запросов к API
            *   отправляем в API соотношения полей и страницу
            *     в циклах формируются временные файлы на сервере
            *     возвращается колво страниц
            *   если страница == общему колву страниц
            *     загружаем файл
            *     закрываем всплывающее окно, обновляем страницу
            *     выходим из цикла
            */

            var cycleNum = 0
            var pages    = null
            var units    = modal.units
            var expModif = modal.expModif
            function repReq(pages, cycleNum, units, expModif) {
                let data = {
                    'cycleNum' : cycleNum,
                    'columns'  : units,
                    'expModif' : expModif
                }
                API.request({
                    object: 'Product',
                    method: 'Export',
                    data:    data,
                    success(response) {
                        pages = response.pages

                        // прогресс-бар
                        var elem = document.getElementById("myBar");
                        var width = (cycleNum + 1) / pages * 100;
                        elem.style.width = width + '%';
                        elem.innerHTML = Math.round(width) * 1 + '%';

                        if (cycleNum  != pages - 1){                     // переход в следующий цикл
                            cycleNum   = cycleNum + 1                    // подгружаем следующую страницу
                            return repReq(pages, cycleNum, units, expModif)
                        } else {                                         // закрытие / обновление / выход из цикла
                            let a      = document.createElement('a')
                            a.href     = response.url
                            a.download = response.name
                            document.body.appendChild(a)
                            a.click()
                            a.remove()
                            modal.modalHide()
                            observable.trigger('products-reload')
                            observable.trigger('categories-reload')
                            observable.trigger('special-reload')
                            observable.trigger('products-exports-end')
                        }
                    }
                })
            }
            repReq(pages, cycleNum, units, expModif)

        }
