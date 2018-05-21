| import 'components/datatable.tag'
| import 'components/catalog-static.tag'
| import 'modals/add-link-modal.tag'

product-files
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ value }', handlers='{ handlers }',
            upload='{ upload }', remove='{ handlers.remove }', reorder='true')
                #{'yield'}(to='toolbar')
                    .form-group(if='{ checkPermission("files", "0100") }')
                        .input-group(class='btn btn-primary btn-file')
                            input(name='files', onchange='{ opts.upload }', type='file', multiple='multiple')
                            i.fa.fa-plus
                            |  Загрузить
                        button.btn.btn-default(name='link', onclick='{ parent.addLink }', type='button')
                            i.fa.fa-plus
                            |  Ссылку

                #{'yield'}(to='body')
                    datatable-cell(name='')
                        img(src='https://placeholdit.imgix.net/~text?txtsize=30&txtclr=ffffff&bg=2196F3&txt={ row.fileExt }&w=64&h=64&txttrack=0', height='64px', width='64px')
                    datatable-cell(name='')
                        input.form-control(value='{ row.fileText }', onchange='{ handlers.fileAltChange }')
                        .help-block
                            a(href="{ row.fileURL }" target='_blank') Открыть: { row.fileName }

    script(type='text/babel').
        var self = this
        self.mixin('permissions')
        self.items = []

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.add = () => {}

        self.cols = [
            {name: '', value: 'Файл'},
            {name: '', value: 'Текст'},
        ]

        self.handlers = {
            fileAltChange: function (e) {
                e.item.row.fileText = e.target.value
            },
            remove: function (e) {
                var rows = self.tags['catalog-static'].tags.datatable.getSelectedRows()

                rows.forEach(function(row) {
                    self.value.splice(self.value.indexOf(row),1)
                })
            }

        }

        self.addLink = e => {
            modals.create('add-link-modal', {
                type: 'modal-primary',
                title: 'Добавить ссылку',
                submit() {
                    self.value.push({
                        fileText: this.item.name,
                        fileURL:  this.item.name,
                        fileExt:  'http',
                        fileName: this.item.name
                    })
                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }
        self.upload = e => {
            var formData = new FormData();
            var FilesItems = []

            for (var i = 0; i < e.target.files.length; i++) {
                formData.append('file'+i, e.target.files[i], e.target.files[i].name)
                //items.push(e.target.files[i].name)
            }

            API.upload({
                section: opts.section,
                object: 'Files',
                count: e.target.files.length,
                data: formData,
                progress: function(e) {},
                success: function(response) {
                    FilesItems = response.items
                    self.value = self.value || []

                    if(FilesItems.length == 0){
                        popups.create({title: 'Ошибка!', text: 'Данные файлы уже есть на сервере', style: 'popup-danger'})
                    }
                    FilesItems.forEach(i => {
                        self.value.push({
                            fileText: i.name,
                            fileURL:  i.url,
                            fileExt:  i.ext,
                            fileName: i.file
                        })
                    })
                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)
                    self.update()
                }
            })

        }

        self.on('updated', () => {
            self.tags['catalog-static'].tags.datatable.on('reorder-end', (newIndex, oldIndex) => {
                self.tags['catalog-static'].value.splice(newIndex, 0, self.tags['catalog-static'].value.splice(oldIndex, 1)[0])
                var temp = self.tags['catalog-static'].value
                self.rows = []
                self.update()
                self.tags['catalog-static'].value = temp
                self.tags['catalog-static'].items.forEach((item, sort) => {
                    item.sortIndex = sort
                })
            })
        })

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })