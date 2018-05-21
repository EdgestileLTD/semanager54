description-tabs
    ul.nav.nav-tabs(if='{ value.length > 0 }')
        li(each='{ item, i in value }', class='{ active: activeTab === i }')
            a(onclick='{ changeTab }')
                span { item.title }
                button.close(onclick='{ closeTab }', type='button')
                    span  &times;

    .row(each='{ item, i in value }', show='{ active: activeTab === i }', no-reorder)
        .col-md-12
            .form-inline.m-t-3
                .form-group
                    input.form-control(name='title', value='{ item.title }', onchange='{ change }')
                .form-group
                    button.btn.btn-default(type='button', title='Добавить вкладку', onclick='{ addTab }')
                        i.fa.fa-plus
            .form-group.m-t-3
                ckeditor(name='text', value='{ item.text }', onchange='{ change }')

    script(type='text/babel').
        let self = this

        self.value = []
        self.activeTab = 0

        function xmlToArray(xml) {
            let matches = xml.match(/(<tab(.*?)>.*?[\s\S]*?<\/tab>)/g)

            if (matches) {
                return matches.map(item => {
                    return {
                        title: item.replace(/<tab.*?title="(.*?)".*?>.*[\s\S]*?<\/tab>/g, '$1'),
                        text: item.replace(/<tab.*?>(.*[\s\S]*?)<\/tab>/g, '$1')
                    }
                })
            } else {
                return [{
                    title: 'Описание товара',
                    text: xml,
                }]
            }
        }

        function arrayToText(array) {
            if (array instanceof Array && array.length != 0) {
                if (array.length > 1) {
                    let result = ''

                    array.forEach(item => {
                        result += `<tab title="${item.title}">${item.text}</tab>`
                    })

                    return result
                } else {
                    return array[0].text
                }
            } else {
                return ''
            }
        }

        Object.defineProperty(self.root, 'value', {
            get() {
                return arrayToText(self.value)
            },
            set(value) {
                self.value = xmlToArray(value || '')
                self.update()
            }
        })

        self.change = e => {
            e.stopPropagation()
            e.stopImmediatePropagation()

            let { value, name } = e.target

            self.value[e.item.i][name] = value

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event)
        }

        self.changeTab = e => {
            self.activeTab = e.item.i
        }

        self.addTab = e => {
            e.stopPropagation()
            e.stopImmediatePropagation()

            self.value.push({
                title: 'Новая вкладка',
                text: ''
            })

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event)
        }

        self.closeTab = e => {
            e.stopPropagation()
            e.stopImmediatePropagation()
            self.value = self.value.slice(0, self.value.length)
            self.value.splice(e.item.i, 1)

            if (e.item.i <= self.activeTab)
                if (self.activeTab > 0)
                    self.activeTab -= 1

            let event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event)
        }

        self.on('update', () => {
            if (!opts.value)
                self.value = [{
                    title: 'Описание товара',
                    text: '',
                }]

            if (opts.name)
                self.root.name = opts.name
        })