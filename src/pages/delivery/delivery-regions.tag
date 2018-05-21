| import parallel from 'async/parallel'


delivery-regions
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Выберите город
        #{'yield'}(to="body")
            form(onchange='{ parent.change.bind(this.parent) }')
                .form-group
                    label.control-label Страна
                    autocomplete(name='idCountryTo', value-field='name', data='{ parent.countries }',
                    onchange='{ parent.changeCountry.bind(this) }', min-symbols='2', value='{ parent.item.idCountryTo }')
                        | { item.name }
                .form-group
                    label.control-label Регион
                    autocomplete(name='idRegionTo', value-field='name', data='{ parent.getRegions(tags.idCountryTo.value) }',
                    disabled='{ tags.region.data.length == 0 && tags.country.value == undefined }',
                    onchange='{ parent.changeRegion.bind(this) }', min-symbols='2', , value='{ parent.item.idRegionTo }')
                        | { item.name }
                .form-group
                    label.control-label Город
                    autocomplete(name='idCityTo', value-field='name', data='{ parent.cities }',
                    disabled='{ tags.country.value == undefined }', min-symbols='2', value='{ parent.item.idCityTo }')
                        | { item.name }
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    script(type='text/babel').
        var self = this

        self.mixin('change')
        self.cities = []

        self.getRegions = (id) => {
            if (self.regions instanceof Array && id !== undefined)
                return self.regions.filter(item => item.idCountry == id)
            else
                return []
        }

        self.changeCountry = function (e) {
            self.getCities(this.idCountryTo.value, this.idRegionTo.value)
        }

        self.changeRegion = function (e) {
            self.getCities(this.idCountryTo.value, this.idRegionTo.value)
        }

        self.getCities = (country, region) => {
            return API.request({
                object: 'GeoCity',
                method: 'Fetch',
                data: {idCountry: country, idRegion: region},
                success(response) {
                    self.cities = response.items
                    self.update()
                }
            })
        }

        self.on('mount', () => {
            self.item = {}

            if (opts.item)
                self.item = opts.item

            parallel([
                (callback) => {
                    API.request({
                        object: 'GeoCountry',
                        method: 'Fetch',
                        success(response) {
                            self.countries = response.items
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
                            self.regions = response.items
                            callback(null, 'Regions')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }
            ], (err, res) => {

                if (self.item.idCityTo != null) {
                    let ids = [self.item.idCityTo]

                    API.request({
                        object: 'GeoCity',
                        method: 'Fetch',
                        data: {ids: ids},
                        success(response) {
                            self.item.idCountryTo = response.items[0].idCountry
                            self.item.idRegionTo = response.items[0].idRegion

                            self.countries.forEach(item => {
                                if (item.id == self.item.idCountryTo)
                                    self.tags['bs-modal'].tags.idCountryTo.filterValue = item.name
                            })

                            self.regions.forEach(item => {
                                if (item.id == self.item.idRegionTo)
                                    self.tags['bs-modal'].tags.idRegionTo.filterValue = item.name
                            })

                            self.tags['bs-modal'].tags.idCityTo.filterValue = response.items[0].name

                            self.loader = false
                            self.update()
                        }
                    })
                } else {
                    self.loader = false
                    self.update()
                }
            })
        })