| import 'eonasdan-bootstrap-datetimepicker'
| import 'eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.min.css'

datetime-picker
    input(value='{ value }', onchange='{ change }', onfocus='{ show }')

    style(scope).
        :scope {
            position: inherit;
        }

        input {
            font-family: inherit;
            padding: 0;
            margin: 0;
            border: none;
            width: inherit;
            height: auto;
            color: inherit;
            background-color: inherit;
        }

        span {
            cursor: pointer;
        }

    script(type='text/babel').
        var self = this
        self.value = ''

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value
                if (opts.value)
                    opts.value = value
                self.update()
            }
        })

        self.on('mount', () => {

            var input = self.root.children[0]
                if (opts.value)
                    self.value = opts.value
                else if (opts.defvalue)
                         self.value = opts.defvalue


                $(self.root).datetimepicker({
                locale: opts.locale || 'ru',
                useCurrent: true,
                showTodayButton: true,
                showClear: true,
                format: opts.format || false,
                widgetParent: $(self.root)
            })

            $(self.root).on('dp.change',  e => {
                self.one('update', () => {
                    if (opts.value)
                        opts.value = input.value
                    self.value = input.value
                    var event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)
                })
                self.update()
            })

            self.show = e => {
                $(self.root).data("DateTimePicker").show()
            }

            self.hide = e => {
                $(self.root).data("DateTimePicker").hide()
            }

        })

        self.on('mount', () => {
            self.root.name = opts.name
        })