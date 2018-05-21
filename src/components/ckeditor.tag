ckeditor
    textarea(name='{ opts.name }', id='ck_{ _riot_id }', value='{ value }')
    script(type='text/babel').
        var self = this

        self.value = ''

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value
            }
        })

        self.one('updated', () => {
            let instance = CKEDITOR.replace('ck_' + self._riot_id, {
                extraPlugins: 'divarea,youtube'
            })

            instance.on('change', () => {
                var event = document.createEvent('Event')
                event.initEvent('change', true, true)
                self.root.dispatchEvent(event)
                $('#ck_'+self. _riot_id).val(self.value)
            })

            localStorage.setItem('SE_section', opts.section);

            instance.on('instanceReady', event => {
                /* Активируем кнопку исходного кода */
                var element = instance.document.getById('cke_37');
                element.on('click', function () {
                    var elem = $('#cke_ck_' + self._riot_id + ' .cke_source')
                    elem.attr('name', self.root.name)
                })

                instance.setData(self.value)
                instance.resetUndo()
                Object.defineProperty(self, 'value', {
                    get() {
                        return instance.getData()
                    },
                    set(value) {
                        if (value == null || value == undefined)
                            value = ''
                        if (instance.getData() !== value) {
                            instance.setData(value)
                            instance.resetUndo()
                        }
                    }
                })
            })

            self.on('unmount', () => {
                instance.destroy()
            })
        })

        self.on('mount', function () {
            self.value = opts.value || ''
            self.root.name = opts.name
        })