| import debounce from 'lodash/debounce'

settings-synhro-1c
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .row
            .col-md-12
                .h4
                    a(href='http://help.siteedit.ru/1c/', target='blank')
                        i.fa.fa-fw.fa-info-circle
                        | Справка
        form(action='', onchange='{ changeSettings1c }', onkeyup='{ changeSettings1c }', method='POST')
            .row
                .col-xs-12.col-md-6
                    .panel.panel-default
                        .panel-heading
                            h3.panel-title Основные настройки обмена
                        .panel-body
                            .form-group
                                label.control-label Имя пользователя (логин) для авторизации
                                input.form-control.input-sm(name='login', value='{ item.login }', type='text')
                            .form-group
                                label.control-label Пароль пользователя для авторизации
                                input.form-control.input-sm(name='password', value='{ item.password }', type='password')
                            .form-group
                                label.control-label Язык сайта для импорта
                                input.form-control.input-sm(name='lang', value='{ item.lang }', type='text')
                            .checkbox
                                label
                                    input(name='zip', checked='{ item.zip == "yes" }', type='checkbox', data-bool="Y,N")
                                    |  Использовать zip сжатие при обмене
                            .form-group
                                label.control-label Максимальный размер пакета в байтах
                                input.form-control.input-sm(name='limit_filesize', value='{ item.limit_filesize }', type='number')
                            .form-group
                                label.control-label Максимальное время обработки в секундах
                                input.form-control.input-sm(name='max_execution_time', min='1', max='90', value='{ item.max_execution_time }', type='number')
                    .panel.panel-default
                        .panel-heading
                            h3.panel-title Настройки обмена заказами
                        .panel-body
                            .form-group
                                label.control-label Изменить статус если заказ проведен
                                select.form-control.input-sm(name='change_status', value='{ item.change_status }')
                                    option(value='Y') Оплачен
                                    option(value='N') Не оплачен
                                    option(value='K') Кредит
                                    option(value='P') Подарок
                                    option(value='false') Не менять
                            .checkbox
                                label
                                    input(name='new_date_order', checked='{ item.new_date_order == "Y" }', type='checkbox', data-bool="Y,N")
                                    |                         Записывать дату заказа на сайте датой по 1с
                            .checkbox
                                label
                                    input(name='new_date_payee', type='checkbox', data-bool="Y,N", checked='{ item.new_date_payee == "Y" }')
                                    |                         Записывать дату оплаты на сайте датой по 1с
                            .form-group
                                label.control-label Дата с которой необходимо экспортировать заказы
                                input.form-control.input-sm(name='date_export_orders', value='{ item.date_export_orders }', type='text')
                            .form-group
                                label.control-label Соответствие валют сайта и 1с при обмене заказами
                                input.form-control.input-sm(name='conform_currency', value='{ item.conform_currency }', type='text')
                            .checkbox
                                label
                                    input(name='export_only_update', checked='{ item.export_only_update == "Y" }', type='checkbox', data-bool="Y,N")
                                    |                         Выгружать только измененные заказы с сайта
                    .panel.panel-default
                        .panel-heading
                            h3.panel-title Настройки синхронизации с существующими товарами на сайте*
                        .panel-body
                            .checkbox
                                label
                                    input(name='="ex_group_name"', type='checkbox', data-bool="Y,N", checked='{ item.ex_group_name == "Y" }')
                                    |                         Синхронизация групп товаров по наименованию
                            .form-group
                                label.control-label Синхронизация каталога товаров
                                select.form-control.input-sm(name='ex_catalog_product', value='{ item.ex_catalog_product }')
                                    option(value='1', selected='') Не использовать
                                    option(value='2') По наименованию
                                    option(value='3') По артиклу
                                    option(value='4') По наименованию или артиклу
                                    option(value='5') По наименованию и артиклу
                            .checkbox
                                label
                                    input(name='ex_catalog_group', type='checkbox', data-bool="Y,N", checked='{ item.ex_catalog_group == "Y" }')
                                    |                         Соблюдение иерархии групп при идентификации товаров
                .col-xs-12.col-md-6
                    .panel.panel-default
                        .panel-heading
                            h3.panel-title Настройки импорта каталога товаров
                        .panel-body
                            .form-group
                                label.control-label Наименование доп. реквизита используемого как производитель
                                input.form-control.input-sm(name='manufacturer', value='{ item.manufacturer }', type='text')
                            .form-group
                                label.control-label Название доп. параметра для неизвестных характеристик т.овара
                                input.form-control.input-sm(name='new_param', value='{ item.new_param }', type='text')
                            .form-group
                                label.control-label Тип записи кода групп товаров
                                select.form-control.input-sm(name='code_group', value='{ item.code_group }')
                                    option(value='translit') Транслит
                                    option(value='id') Ид по 1с
                            .form-group
                                label.control-label Тип записи кода товаров
                                select.form-control.input-sm(name='code_product', value='{ item.code_product }')
                                    option(value='translit') Транслит
                                    option(value='article') Артикул
                                    option(value='barcode') Штрихкод по 1с
                                    option(value='id') Ид по 1с
                            .form-group
                                label.control-label Основная картинка товара
                                select.form-control.input-sm(name='main_image', value='{ item.main_image }')
                                    option(value='first') Первая
                                    option(value='last') Последняя
                            .form-group
                                label.control-label Id группы для всех импортируемых товаров
                                input.form-control.input-sm(name='parent_group', value='{ item.parent_group }', type='text')
                            .form-group
                                label.control-label Тип цены (типовое соглашение) для импорта основной цены товара
                                input.form-control.input-sm(name='price_main', value='{ item.price_main }', type='text')
                            .form-group
                                label.control-label Типа цен (типовое соглашение) для импорта оптовой цены товара
                                input.form-control.input-sm(name='price_opt', value='{ item.price_opt }', type='text')
                            .form-group
                                label.control-label Тип цены (типовое соглашение) для импорта цены "мелкий опт"
                                input.form-control.input-sm(name='price_opt_corp', value='{ item.price_opt_corp }', type='text')
                            .form-group
                                label.control-label Обновления полей и товаров
                            .checkbox
                                label
                                    input(name='upd_name_group', checked='{ item.upd_name_group == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Наименования групп товаров
                            .checkbox
                                label
                                    input(name='upd_code_group', checked='{ item.upd_code_group == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Коды групп товаров
                            .checkbox
                                label
                                    input(name='upd_name_product', checked='{ item.upd_name_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Наименования товаров
                            .checkbox
                                label
                                    input(name='upd_group_product', checked='{ item.upd_group_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Группы, указанные в товарах
                            .checkbox
                                label
                                    input(name='upd_code_product', checked='{ item.upd_code_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Коды товаров
                            .checkbox
                                label
                                    input(name='upd_article_product', checked='{ item.upd_article_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Артикулы товаров
                            .checkbox
                                label
                                    input(name='upd_manufacturer_product', checked='{ item.upd_manufacturer_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Производители товаров
                            .checkbox
                                label
                                    input(name='upd_note_product', checked='{ item.upd_note_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Краткие описания товаров
                            .checkbox
                                label
                                    input(name='upd_text_product', checked='{ item.upd_text_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Подробные описания товаров
                            .checkbox
                                label
                                    input(name='upd_measure_product', checked='{ item.upd_measure_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Единицы измерения у товаров
                            .checkbox
                                label
                                    input(name='upd_weight_product', checked='{ item.upd_weight_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Значения веса товаров
                            .checkbox
                                label
                                    input(name='upd_main_image_product', checked='{ item.upd_main_image_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Основные картинки товаров
                            .checkbox
                                label
                                    input(name='upd_more_image_product', checked='{ item.upd_more_image_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Дополнительные картинки товаров
                            .checkbox
                                label
                                    input(name='remove_product', checked='{ item.remove_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Удалять товары, помеченые на удаление в 1С
                            .checkbox
                                label
                                    input(name='upd_price_product', checked='{ item.upd_price_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Обновление ценовых предложений товаров
                            .checkbox
                                label
                                    input(name='upd_count_product', checked='{ item.upd_count_product == "Y" }', type='checkbox', data-bool="Y,N")
                                    |  Обновление остатков товаров

    script(type='text/babel').
        var self = this,
        route = riot.route.create()

        self.item = {}
        self.mixin('change')
        self.mixin('permissions')

        var save = debounce(e => {
            API.request({
                object: 'SettingSynhro1C',
                method: 'Save',
                data: self.item,
                complete: () => self.update()
            })
        }, 600)


        self.changeSettings1c = e => {
            if (self.checkPermission('settings', '0010')) {
                self.change(e)
                save()
            } else {
                e.target.value = self.item[e.target.getAttribute('name')]
            }
        }

        self.reload = () => {
            self.loader = true
            self.update()

            API.request({
                object: 'SettingSynhro1C',
                method: 'Info',
                data: {},
                success(response) {
                    self.item = response
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        route('/settings/settings-synhro-1c', () => {
            self.reload()
        })

        self.on('mount', () => {
            riot.route.exec()
        })

