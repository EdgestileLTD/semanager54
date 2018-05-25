| import 'components/filemanager.tag'

images-manager
    .main-container
        .col-md-12
            .row(if='{ !notFound }')
                filemanager(name='gallery', onSelectImage='{ dblclick }')
    style.
        .main-container {
            margin: 10px;
        }

    script(type='text/babel').
        var self = this

        self.state = {}

        self.on('update', () => {

            self.update()
            self.tags.gallery.reload()
            self.update()
        })

        observable.on('images-page-change', (params) => {
            self.state = params
        })

        self.dblclick = e => {

            let path = self.tags.gallery.path
            let items = self.tags.gallery.getSelectedFiles()

            if (items.length) {
                let value = app.getImageRelativeUrl(path, items[0].name, '')
                let valueAbsolute = app.getImageUrl(path, items[0].name)

                console.log(value)

                window.top.opener.CKEDITOR.tools.callFunction( self.callback, valueAbsolute);
                window.top.close() ;
                window.top.opener.focus()
            }


        }

        self.menuSelect = (e) => {
            riot.route(`/imageUpload/${e.target.value}`)
        }

        self.on('mount', () => {
            //riot.route.exec()
            self.callback = riot.route.query()
            self.callback = self.callback['CKEditorFuncNum']
        })

















