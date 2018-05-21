| import 'pages/images/images-gallery-modal.tag'


image-select
    .image(style='background-image: url({ item.imageUrlPreview });')
        .image-select.text-center(if='{ uploadStatus === 0 }')
            .form-group(if='{ checkPermission("images", "0100") }')
                .input-group.btn.btn-sm.btn-primary.btn-file(style='margin: 0 auto;')
                    input(onchange='{ upload }', type='file', accept='image/*')
                    i.fa.fa-fw.fa-upload
                    |  Загрузить
            .form-group(if='{ checkPermission("images", "0010") }')
                button.btn.btn-sm.btn-success(onclick='{ select }', type='button')
                    i.fa.fa-fw.fa-picture-o
                    |  Выбрать
            .form-group(if='{ checkPermission("images", "0010") }')
                button.btn.btn-sm.btn-danger(onclick='{ remove }', type='button')
                    i.fa.fa-fw.fa-trash
                    |  Очистить
        .image-upload.text-center(if='{ uploadStatus > 0 }')
            h3.image-upload-percent { uploadStatus }%


    style(scoped).
        .image {
            display: table;
            position: relative;
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
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

        .image-upload-percent {
            color: #FFF;
            text-shadow: 0 0 1px black, 1px 1px 2px black;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.uploadStatus = 0
        self.item = {}

        function changeEvent() {
            var event = document.createEvent('Event')
            event.initEvent('change', true, true)
            self.root.dispatchEvent(event);
        }

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.item.image
            },
            set(value) {
                self.item.image = value
                self.item.imageFile = 'images/' + opts.section + '/' + value
                self.item.imageUrlPreview = app.getImagePreviewURL(value, opts.section, opts.size)
            }
        })

        self.upload = e => {
            var formData = new FormData();

            for (var i = 0; i < e.target.files.length; i++) {
                formData.append('file' + i, e.target.files[i], e.target.files[i].name)
            }

            API.upload({
                section: opts.section,
                count: 1,
                data: formData,
                progress(e) {
                    var percentComplete = Math.ceil(e.loaded / e.total * 100)
                    self.uploadStatus = percentComplete
                    self.update()
                },
                success(response) {
                    self.item.image = response.items[0].name
                    changeEvent()
                    self.update()
                },
                complete() {
                    self.uploadStatus = 0
                    self.update()
                }
            })
        }

        self.select = () => {
            modals.create('images-gallery-modal', {
                type: 'modal-primary',
                section: opts.section,
                submit: function () {
                    var items = this.tags.gallery.tags.datatable.getSelectedRows()

                    if (items.length) {
                        self.item.image = items[0].name
                        changeEvent()
                        self.update()
                    }

                    this.modalHide()
                }
            })
        }

        self.remove = () => {
            self.item.image = ''
            self.item.imageFile = ''
            self.item.imageUrlPreview = ''
            changeEvent()
        }

        self.on('mount', () => {
            self.root.name = opts.name
        })

