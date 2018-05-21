add-fields-edit-block
    .row
        .col-md-12
            ul.nav.nav-tabs.m-b-2(if='{ value.length > 0 }')
                li(each='{ item, i in value }', class='{ active: activeTab === i }')
                    a(onclick='{ changeTab }')
                        span { item.name }

    .row
        .col-md-12
            add-fields-edit-block-group(if='{ value.length > 0 }', value='{ value[activeTab].items || [] }')

    script(type='text/babel').
        var self = this
        self.value = []

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value || []
            }
        })

        self.activeTab = 0

        self.changeTab = e => {
            self.activeTab = e.item.i
        }

        self.on('update', () => {
            if (opts.value)
                self.value = opts.value

            if (opts.name)
                self.root.name = opts.name
        })

add-fields-edit-block-group
    .row
        form
            .col-md-4(each='{ field, i in value }', onchange='{ change }')
                .form-group
                    label.control-label { field.name }
                    // String
                    input.form-control(if='{ field.type == "string" }', required='{ field.required }',value='{ field.value }')
                    // Text
                    textarea.form-control(if='{ field.type == "text" }', required='{ field.required }', rows='5', style='min-width: 100%; max-width: 100%;', value='{ field.value }')
                    // Number
                    input.form-control(if='{ field.type == "number" }',required='{ field.required }', value='{ field.value }', type='number')
                    // Select
                    select.form-control(if='{ field.type == "select" }', required='{ field.required }', value='{ field.value }')
                        option(value='') -
                        option(each='{ option, k in field.values.split(",") }',
                        selected='{ option == field.value }') { option }
                    // CheckBox
                    .checkbox(if='{ field.type == "checkbox" }', required='{ field.required }', each='{ option, k in field.values.split(",") }')
                        label
                            input(type='checkbox', data-value='{ option }',
                            checked='{ field.value.split(",").indexOf(option) !== - 1 }')
                            | { option }
                    // Radio
                    .radio(if='{ field.type == "radio" }', each='{ option, k in field.values.split(",") }')
                        label
                            input(name='{ field.name}', type='radio',
                            checked='{ field.value.split(",").indexOf(option) !== - 1 }', value='{ option }')
                            | { option }
                    // Date
                    datetime-picker.form-control(if='{ field.type == "date" }', required='{ field.required }', format='YYYY-MM-DD', value='{ field.value }')
                    .help-block { field.description }

    script(type='text/babel').
        var self = this

        self.change = e => {
            e.stopPropagation()
            let type = e.item.field.type

            if (type !== 'checkbox') {
                e.item.field.value = e.target.value
            } else {
                let checkedValues = (e.item.field.value || '').split(',')
                let checkedValue = e.target.getAttribute('data-value')
                let idx = checkedValues.indexOf(checkedValue)

                if (idx !== -1)
                    checkedValues.splice(idx, 1)
                else
                    checkedValues.push(checkedValue)

                e.item.field.value = checkedValues.filter(i => i).join(',')
            }

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.parent.root.dispatchEvent(event)
        }

        self.on('update', () => {
            if (opts.value)
                self.value = opts.value
        })