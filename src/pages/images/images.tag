| import 'components/filemanager.tag'

images
    filemanager(value='{ value }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        route('images', () => {
            self.tags.filemanager.reload()
        })

        self.on('mount', () => {
            riot.route.exec()
        })