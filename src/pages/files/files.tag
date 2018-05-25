| import 'components/filemanager.tag'

files
    filemanager(value='{ value }', accept='*', path='filesPath', folder='FileFolder', object='Base')

    script(type='text/babel').
        var self = this,
        route = riot.route.create()

        route('images', () => {
            self.tags.filemanager.reload()
        })

        self.on('mount', () => {
            riot.route.exec()
        })