| import parallel from 'async/parallel'

delivery-condition-regions-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Регион доставки
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .form-group
                    label.control-label Наименование
                    input.form-control(name='name', value='{ item.name }', type='text')
                .form-group
                    label.control-label Страна
                    autocomplete(name='idCountryTo', value-field='name', data='{ countries }',
                    onchange='{ changeCountry }', min-symbols='2', value='{ item.idCountryTo }')
                        | { item.name }
                .form-group
                    label.control-label Регион
                    autocomplete(name='idRegionTo', value-field='name', data='{ getRegions(tags.idCountryTo.value) }',
                    disabled='{ tags.region.data.length == 0 && tags.country.value == undefined }',
                    onchange='{ changeRegion }', min-symbols='2', , value='{ item.idRegionTo }')
                        | { item.name }
                .form-group
                    label.control-label Город
                    autocomplete(name='idCityTo', value-field='name', data='{ cities }',
                    disabled='{ tags.country.value == undefined }', min-symbols='2', value='{ item.idCityTo }')
                        | { item.name }

                .form-group
                    label.control-label Срок доставки
                    input.form-control(name='period', value='{ item.period }', type='number', min='0')
                .form-group
                    label.control-label Цена
                    input.form-control(name='price', value='{ item.price }', type='number', min='0')
                .form-group
                    label.control-label Макс. объем
                    .input-group
                        input.form-control(name='maxVolume', value='{ item.maxVolume }', type='number', min='0')
                        .input-group-addon
                            | м<sup>3</sup>
                .form-group
                    label.control-label Макс. вес
                    .input-group
                        input.form-control(name='maxWeight', value='{ item.maxWeight }', type='number', min='0')
                        .input-group-addon
                            | гр.
                .form-group
                    label.control-label Адрес склада/примечание
                    textarea.form-control(rows='5', name='note',
                    style='min-width: 100%; max-width: 100%;', value='{ item.note }')
                .form-group
                    .checkbox-inline
                        label
                            input(type='checkbox', name='isActive', checked='{ item.isActive }')
                            | Активная

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']

            modal.item = opts.item || {
                isActive: true
            }
            modal.mixin('change')
            modal.mixin('validation')

            modal.getRegions = (id) => {
                if (modal.regions instanceof Array && id !== undefined)
                    return modal.regions.filter(item => item.idCountry == id)
                else
                    return []
            }

            modal.changeCountry = function (e) {
            modal.getCities(this.idCountryTo.value, this.idRegionTo.value)
            }

            modal.changeRegion = function (e) {
                modal.getCities(this.idCountryTo.value, this.idRegionTo.value)
            }

            modal.getCities = (country, region) => {
                return API.request({
                    object: 'GeoCity',
                    method: 'Fetch',
                    data: {idCountry: country, idRegion: region},
                    success(response) {
                        modal.cities = response.items
                        modal.update()
                    }
                })
            }

            parallel([
                (callback) => {
                    API.request({
                        object: 'GeoCountry',
                        method: 'Fetch',
                        success(response) {
                            modal.countries = response.items
                            callback(null, 'Countries')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                },
                (callback) => {
                    API.request({
                        object: 'GeoRegion',
                        method: 'Fetch',
                        success(response) {
                            modal.regions = response.items
                            callback(null, 'Regions')
                        },
                        error(response) {
                            callback('error', null)
                        }
                        })
                    }
                ], (err, res) => {
                    if (modal.item.idCityTo != null) {
                        let ids = [modal.item.idCityTo]

                        API.request({
                            object: 'GeoCity',
                            method: 'Fetch',
                            data: {ids: ids},
                            success(response) {
                                modal.item.idCountryTo = response.items[0].idCountry
                                modal.item.idRegionTo = response.items[0].idRegion

                                modal.countries.forEach(item => {
                                    if (item.id == modal.item.idCountryTo)
                                        modal.tags.idCountryTo.filterValue = item.name
                                })

                                modal.regions.forEach(item => {
                                    if (item.id == modal.item.idRegionTo)
                                        modal.tags.idRegionTo.filterValue = item.name
                                })

                                modal.tags.idCityTo.filterValue = response.items[0].name

                                modal.loader = false
                                modal.update()
                            }
                        })
                    } else {
                    modal.loader = false
                    modal.update()
                }
            })


        })

