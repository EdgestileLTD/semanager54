| import 'pages/images/image-gallery.tag'

images-manager
    .main-container
        .col-md-12
            .row(if='{ !notFound }')
                .col-sm-10.col-xs-12
                    image-gallery(name='gallery', dblclick='{ dblclick }', autoselect='{ autoselect }')
    style.
        .main-container {
            margin: 10px;
        }

    script(type='text/babel').
        var self = this


        self.state = {}
        self.state.section = '';

        self.on('update', () => {
            if (!self.state.section || self.state.section != localStorage.getItem('CMS_section')) {
                self.update()
                self.state.section = localStorage.getItem('SE_section')
                self.state.limit = self.tags.gallery.pages.limit
                self.state.offset = 0

                self.tags.gallery.update({ params: self.state })
                self.tags.gallery.reload()

                self.update()
            }
        })

        observable.on('images-page-change', (params) => {
            self.state = params
        })

        self.autoselect = item => {
            window.top.opener.CKEDITOR.tools.callFunction( self.callback, item.imageUrl);
            window.top.close() ;
            window.top.opener.focus()
        }

        self.dblclick = e => {
            self.autoselect(e.item.row)
        }



        self.menuSelect = (e) => {
            riot.route(`/imageUpload/${e.target.value}`)
        }

        self.on('mount', () => {
            //riot.route.exec()
            self.callback = riot.route.query()
            self.callback = self.callback['CKEditorFuncNum']
        })

















