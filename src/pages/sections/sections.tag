| import 'pages/sections/section-list.tag'
| import 'pages/sections/section-list-items.tag'
| import 'pages/sections/section-edit.tag'

sections
    section-list(if='{ !edit }')
    section-edit(if='{ edit }')


    script(type='text/babel').
        var self = this
        self.edit = false

        var route = riot.route.create()

        route('/sections/([0-9]+)', id => {
            observable.trigger('section-edit', id)
            self.edit = true
            self.update()
        })


        route('/sections', () => {
            self.edit = false
            self.update()
        })

        route('/sections/new..', () => {
            let q = riot.route.query()
            let sect = q.section
            self.edit = true
            observable.trigger('section-new', sect)
            self.update()
        })

        route('/sections/new', () => {
            riot.route(`/sections`)
        })

        self.on('mount', () => {
            riot.route.exec()
        })