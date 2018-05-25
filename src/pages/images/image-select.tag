| import 'pages/images/images-modal.tag'

image-select
    .image(style='background-image: url({ valueAbsolute });')
        .image-select.text-center
            .form-group(if='{ checkPermission("images", "0010") }')
                button.btn.btn-sm.btn-success(onclick='{ select }', type='button')
                    i.fa.fa-fw.fa-picture-o
                    |  Выбрать
            .form-group(if='{ checkPermission("images", "0010") }')
                button.btn.btn-sm.btn-danger(onclick='{ remove }', type='button')
                    i.fa.fa-fw.fa-trash
                    |  Очистить


    style(scoped).
        .image {
            display: table;
            position: relative;
            background-position: center;
            background-repeat: no-repeat;
            background-size: contain;
            width: 100%;
            height: 170px;
        }

        @media (max-width: 991px) {
            .image {
                margin: 0 auto;
                height: 450px !important;
                width: 450px !important;
            }
        }

        @media (max-width: 767px) {
            .image {
                margin: 0 auto;
                height: 300px !important;
                width: 300px !important;
            }
        }

        @media (max-width: 480px) {
            .image {
                margin: 0 auto;
                height: 240px !important;
                width: 240px !important;
            }
        }

        .image .image-select {
            display: none;
        }

        .image:hover .image-select,
        .image:focus .image-select {
            display: table-cell;
            vertical-align: middle;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .image-upload {
            display: table-cell;
            vertical-align: middle;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.value = ''

        function changeEvent() {
            var event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event);
        }

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value
                self.valueAbsolute = app.getImageUrl(value)
            }
        })

        self.select = () => {
            modals.create('images-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit: function () {
                    let filemanager = this.tags.filemanager
                    let items = filemanager.getSelectedFiles()
                    let path = filemanager.path

                    if (items.length) {
                        self.value = app.getImageRelativeUrl(path, items[0].name, '')
                        self.valueAbsolute = app.getImageUrl(path, items[0].name)
                        changeEvent()
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.remove = () => {
            self.value = ''
            changeEvent()
        }

        self.on('mount', () => {
            self.root.name = opts.name
        })

