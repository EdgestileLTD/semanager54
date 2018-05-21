import-products-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Импорт (Шаг 1 из 2)
        #{'yield'}(to="body")
            loader(text='Импорт', indeterminate='true', if='{ loader }')
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group(class='{ has-error: error.filename }')
                    .input-group
                        .input-group-btn
                            .btn-file.btn.btn-default(onchange='{ changeFile }')
                                input(name='file', type='file', accept='.xlsx, .csv')
                                i.fa.fa-fw.fa-folder-open.text-primary
                        input.form-control(name='filename', value='{ item.filename }', placeholder='Выберите файл или введите ссылку',
                        disabled='{ file.files.length }')
                        .input-group-btn
                            .btn-file.btn.btn-default(onclick='{ clear }', title='Сброс')
                                i.fa.fa-fw.fa-close.text-danger
                .row
                    .col-md-6.col-xs-12
                        .form-group
                            label.control-label Профиль загрузки
                            .input-group
                                select.form-control(name='uploadProfile', value='{ item.uploadProfile }', onchange='{ uploadProfileChange }')
                                    option(
                                        each='{ i in uploadProfiles }', value='{ i.name }',
                                        selected='{ i.name == parent.item.uploadProfile }', no-reorder
                                    ) { i.title }
                                .input-group-btn
                                    .btn-file.btn.btn-default(onclick='{ deleteProfile }', title='Удалить выбранный профиль', placeholder='Выберите файл или введите ссылку')
                                        i.fa.fa-fw.fa-close.text-danger

                        //.form-group
                        //    label.control-label Кодировка
                        //    select.form-control(name='encoding', value='{ item.encoding }')
                        //        option(
                        //            each='{ i in encodings }', value='{ i.name }',
                        //            selected='{ i.name == parent.item.encoding }', no-reorder
                        //        ) { i.title }

                        .form-group
                            label.control-label Разделитель столбцов
                            select.form-control(name='delimiter', value='{ item.delimiter }')
                                option(
                                    each='{ i in delimiters }', value='{ i.name }',
                                    selected='{ i.name == parent.item.delimiter }', no-reorder
                                ) { i.title }

                    .col-md-6.col-xs-12
                        // .form-group
                        //     label.control-label Ключевое поле
                        //     select.form-control(name='keyField', value='{ item.keyField }')
                        //         option(
                        //             each='{ i in keyFields }', value='{ i.name }',
                        //             selected='{ i.name == parent.item.keyField }', no-reorder
                        //         ) { i.title }

                        .form-group
                            label.control-label Пропустить строк
                            input.form-control(name='skip', type='number', min='0', step='1', value='{ item.skip }')

                        .form-group
                            label.control-label Ограничитель поля
                            input.form-control(name='limiterField', value='{ item.limiterField }')

                    .help-block { error.filename }
                //.form-group
                    label.control-label Тип импорта
                    br
                    label.radio-inline
                        input(type='radio', name='type', value='0', checked='{ item.type == 0 }')
                        | Обновление
                    label.radio-inline
                        input(type='radio', name='type', value='1', checked='{ item.type == 1 }')
                        | Вставка
                //.form-group(if='{ item.type == 1 }')
                    .checkbox-inline
                        label
                            input(name='reset', type='checkbox', checked='{ item.reset }')
                            | Очистить базу данных перед импортом
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed', disabled='{ cannotBeClosed }') Закрыть
            button(onclick='{ parent.submit }', type='button', class='btn btn-primary btn-embossed', disabled='{ cannotBeClosed }') Продолжить


    script(type='text/babel').
        var self = this
        self.loader = true

        // ВКЛ
        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            // нужно получать профили из браузера
            var profiles = JSON.parse(localStorage.getItem("profiles")) // отсутствуют - null

            // поля селектора профиля загрузки,
            // значение при отсутствии записей в браузере
            modal.uploadProfiles = [
                {name: 'profile1',  title: 'Профиль 1'}
            ]

            // загружаем профили из браузера
            if (profiles == null) {
                var profiles = {}
            } else {
                modal.uploadProfiles = []
                for (var key in profiles) {
                    if(key != 'groupNow') {
                        let profileUnit = {name: key,  title: profiles[key]['title']}
                        modal.uploadProfiles.push(profileUnit)
                    }
                }
            }

            /*// ... кодировки
            modal.encodings = [
                {name: 'utf-8',         title: 'UTF-8'},
                {name: 'windows-1251',  title: 'Windows-1251'}
            ]*/

            // ... разделителителя столбцов
            modal.delimiters = [
                {name: 'auto',  title: 'Автоопределение'},
                {name: ';',     title: 'Точка с запятой'},
                {name: ',',     title: 'Запятая'},
                {name: '\t',    title: 'Табуляция'}
            ]

            // ... ключевое поле
            modal.keyFields = [
                {name: 'article',   title: 'Артикул'},
                {name: 'id',        title: 'Идентификатор'},
                {name: 'code',      title: 'Код (URL)'},
                {name: 'name',      title: 'Наименование'}
            ]

            // значния по умолчанию
            modal.error = false
            modal.mixin('validation')
            modal.mixin('change')

            // получаем настройки последнего профиля или по умолчанию
            if(Object.keys(profiles).length != 0) {

                var uploadProfileValue = profiles['groupNow']

                if(profiles[uploadProfileValue]['title'] != undefined) {
                    var titleValue = profiles[uploadProfileValue]['title']
                } else {var titleValue = undefined}

                if(profiles[uploadProfileValue]['delimiter'] != undefined) {
                    var delimiterValue = profiles[uploadProfileValue]['delimiter']
                } else {var delimiterValue = modal.delimiters[0]['name']}

                if(profiles[uploadProfileValue]['keyField'] != undefined) {
                    var keyFieldValue = profiles[uploadProfileValue]['keyField']
                } else {var keyFieldValue = modal.keyFields[0]['name']}

                if(profiles[uploadProfileValue]['limiterField'] != undefined) {
                    var limiterFieldValue = profiles[uploadProfileValue]['limiterField']
                } else {var limiterFieldValue = '"'}

                if(profiles[uploadProfileValue]['skip'] != undefined) {
                    var skipValue = profiles[uploadProfileValue]['skip']
                } else {var skipValue = 1}

                if(profiles[uploadProfileValue]['margins'] != undefined) {
                    var marginsValue = profiles[uploadProfileValue]['margins']
                } else {var marginsValue = undefined}

            } else {
                var uploadProfileValue = modal.uploadProfiles[0]['name']
                var titleValue = modal.uploadProfiles[0]['title']
                var delimiterValue = modal.delimiters[0]['name']
                var keyFieldValue = modal.keyFields[0]['name']
                var limiterFieldValue = '"'
                var skipValue = 1
                var marginsValue = undefined
            }

            modal.item = {
                filename      : '',
                type          : '0',
                reset         : false,

                uploadProfile : uploadProfileValue,
                title         : titleValue,
                /*encoding      : modal.encodings[0]['name'],*/
                delimiter     : delimiterValue,
                keyField      : keyFieldValue,
                limiterField  : limiterFieldValue,
                skip          : skipValue,

                margins       : marginsValue
            }

            modal.rules = {
                filename: {
                    required: true,
                    rules:[{
                        type: 'url',
                        prompt: 'Выберите файл или введите правильную ссылку',
                    }]
                }
            }

            modal.loader = false
            modal.changeFile = e => {
                modal.item.filename = e.target.files[0].name
                modal.update()
            }

            modal.clear = () => {
                modal.item.filename      = ''
                modal.item.file          = ''
                modal.file.value         = ''
            }

            // после изменения
            modal.afterChange = e => {
                if (modal.file.files && !modal.file.files.length) {
                    let name = e.target.name
                    delete modal.error[name]
                    modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
                }

                if (modal.file.files && modal.file.files.length)
                    modal.error = false

                if (modal.item && modal.item.type == 0)
                    modal.item.reset = false

                delete modal.item.file
            }

            // загрузка измененного профиля
            modal.uploadProfileChange = e => {
                let prof = JSON.parse(localStorage.getItem("profiles"))
                if (prof != null)
                    profiles = prof

                // parseInt()
                modal.item.uploadProfile = e.target.value
                modal.item.title         = profiles[modal.item.uploadProfile]['title']
                modal.item.delimiter     = profiles[modal.item.uploadProfile]['delimiter']
                modal.item.keyField      = profiles[modal.item.uploadProfile]['keyField']
                modal.item.limiterField  = profiles[modal.item.uploadProfile]['limiterField']
                modal.item.skip          = parseInt(profiles[modal.item.uploadProfile]['skip'])
                modal.item.margins       = profiles[modal.item.uploadProfile]['margins']
                modal.update()
            }
            
            // удаление профиля
            modal.deleteProfile = e => {
                // получаем данные из брауз
                let prof = JSON.parse(localStorage.getItem("profiles"))
                if (prof != null)
                    profiles = prof
                    
                // удаление проф
                if(Object.keys(profiles).length != 0) {
                    delete profiles[modal.item.uploadProfile]
                    profiles['groupNow'] = 'profile1'
                    
                    // запись
                    var serialProfiles = JSON.stringify(profiles)
                    localStorage.setItem('profiles', serialProfiles)
        
                    modal.uploadProfiles = []
                    for (var key in profiles) {
                        if(key != 'groupNow') {
                            let profileUnit = {name: key,  title: profiles[key]['title']}
                            modal.uploadProfiles.push(profileUnit)
                        }
                    }
                    delete modal.item.margins
                    modal.update()
                }
            }
        })
        
        // ОТПРАВИТЬ
        self.submit = () => {
            let modal = self.tags['bs-modal']
            let formData = new FormData()
            let target = modal.file
            modal.loader = true

            //formData.append('type', modal.item.type)
            //formData.append('reset', modal.item.reset)
            formData.append('prepare', true)

            if (target.files.length) {
                for (var i = 0; i < target.files.length; i++) {
                   formData.append('file' + i, target.files[i], target.files[i].name)
                }
            } else {
                formData.append('url', modal.item.filename)
                modal.error = modal.validation.validate(modal.item, modal.rules)
                if (modal.error) return
            }
            // прикрепляем к отправке параметры
            formData.append('uploadProfile', modal.item.uploadProfile)
            /*formData.append('encoding', modal.item.encoding)*/
            formData.append('delimiter', modal.item.delimiter)
            formData.append('keyField', modal.item.keyField)
            formData.append('limiterField', modal.item.limiterField)
            formData.append('skip', parseInt(modal.item.skip))

            // получаем настройки по профилям из браузера
            var profiles = JSON.parse(localStorage.getItem("profiles")) // отсутствуют - null

            // если настройки не совподают или их нет - добаить новый профиль
            // (если нет параметра - перезаписывается в профиль)
            var create = true
            if (profiles == null) {
                var profiles = {}
            } else if(Object.keys(profiles).length == 1) {
                var create = false
            } else {
                for (var key in profiles) {
                    if (
                        modal.item.delimiter    == profiles[key]['delimiter'] &&
                        modal.item.keyField     == profiles[key]['keyField'] &&
                        modal.item.limiterField == profiles[key]['limiterField']
                        //- modal.item.skip         == profiles[key]['skip']  // отступ менятеся внутри профиля
                    ) {
                        var create = false
                        break
                    }
                }
            }

            if (create == true) {
                // генерируем новый профиль

                // получаем список имен профилей - генерируем новое название
                var numProfiles = 1
                var stop = false
                while(stop == false) {
                    var array_in_presence = false

                    // проверяем наличие имени в списке
                    for (var key in profiles) {
                        if (`profile${numProfiles}` == key) {
                            array_in_presence = true
                            break
                        }
                    }

                    // нет - присваивае к newNameProfile, останавливаем перебор
                    // есть - поднимаем номер, продолжаем перебор
                    if(array_in_presence == false) {
                        var newNameProfile  = `profile${numProfiles}`
                        var newTitleProfile = `Профиль ${numProfiles}`
                        stop = true
                    } else numProfiles += 1

                }
            } else {
                // редактируем старый профиль
                var newNameProfile  = modal.item.uploadProfile
                var newTitleProfile = modal.item.title
            }

            // собираем данные
            let newProfileSettings = {
                'title'              : newTitleProfile,
                'delimiter'          : modal.item.delimiter,
                'keyField'           : modal.item.keyField,
                'limiterField'       : modal.item.limiterField,
                'skip'               : parseInt(modal.item.skip),

                'margins'            : modal.item.margins
            }

            // добавляем в массив и возвращаем браузеру
            profiles[newNameProfile] = newProfileSettings
            profiles['groupNow'] = newNameProfile

            var serialProfiles = JSON.stringify(profiles)
            localStorage.setItem('profiles', serialProfiles)

            modal.uploadProfiles = []
            for (var key in profiles) {
                if(key != 'groupNow') {
                    let profileUnit = {name: key,  title: profiles[key]['title']}
                    modal.uploadProfiles.push(profileUnit)
                }
            }
            modal.update()
                

            //- } else {
            //-     // добавляем в массив выбранный профиль
            //-     profiles['groupNow'] = modal.item.uploadProfile
            //-
            //-     var serialProfiles = JSON.stringify(profiles)
            //-     localStorage.setItem('profiles', serialProfiles)
            //- }
            //-
            //- modal.loader = true
            //- modal.cannotBeClosed = true
            //- modal.update()

            // ЗАГРУЗИТЬ
            // данные уходят в Product.php post
            // по файлу - $items, по настройкам - $_POST

            API.upload({
                object: 'Product',
                data: formData,
                success: function(response) {
                    let dataI = response;
                    dataI.filename = modal.item.filename
                    dataI.uploadProfile = modal.item.uploadProfile
                    localStorage.setItem('shop24_import_products', JSON.stringify(dataI))
                    modal.modalHide()
                    observable.trigger('products-imports')
                },
                complete: function() {
                    modal.loader = false
                    modal.cannotBeClosed = false
                    modal.update()
                }
            })
        }
