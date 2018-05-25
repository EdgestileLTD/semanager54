| import 'components/datatable.tag'
| import 'components/catalog-static.tag'
| import 'modals/add-link-modal.tag'

list-files
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', cols='{ cols }', rows='{ opts.rows }', handlers='{ handlers }',
                remove='{ handlers.remove }', reorder='true')
                #{'yield'}(to='toolbar')
                    .form-group
                        .input-group(class='btn btn-primary btn-file')
                            input(name='file', onchange='{ parent.upload }', type='file', multiple='multiple')
                            i.fa.fa-plus
                            |  Загрузить

                #{'yield'}(to='body')
                    datatable-cell(name='')
                        img(src='https://placeholdit.imgix.net/~text?txtsize=30&txtclr=ffffff&bg=2196F3&txt={ row.ext }&w=64&h=64&txttrack=0', height='64px', width='64px')
                    datatable-cell(name='')
                        input.form-control(value='{ row.file }', onchange='{ handlers.fileAltChange }')
                        .help-block
                            a(href="{ row.url }" target='_blank') Открыть: { row.name }

    script(type='text/babel').
        var self = this

        self.cols = [
            {name: '', value: 'Файл'},
            {name: '', value: 'Текст'},
        ]

        self.handlers = {
            fileAltChange: function (e) {
                e.item.row.file = e.target.value
            },
            remove: function (e) {
                var rows = self.tags['catalog-static'].tags.datatable.getSelectedRows()

                rows.forEach(function(row) {
                    opts.rows.splice(opts.rows.indexOf(row), 1)
                })
            }

        }

        self.addLink = e => {
            modals.create('add-link-modal', {
                type: 'modal-primary',
                title: 'Добавить ссылку',
                submit() {
                    self.value.push({
                        file: this.item.name,
                        url:  this.item.name,
                        ext:  'http',
                        name: this.item.name
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
            var filesItems = []

            for (var i = 0; i < e.target.files.length; i++)
                formData.append('file'+i, e.target.files[i], e.target.files[i].name)
            console.log("upload")

            API.upload({
                section: opts.section,
                object: 'Files',
                count: e.target.files.length,
                data: formData,
                progress: function(e) {},
                success: function(response) {
                    filesItems = response.items
                    if(!filesItems.length) {
                        popups.create({title: 'Ошибка!', text: 'Данные файлы уже есть на сервере', style: 'popup-danger'})
                        return
                    }

                    filesItems.forEach(i => {
                        opts.rows.push({
                            name: i.name,
                            url:  i.url,
                            ext:  i.ext,
                            file: i.file,
                            filePath: i.filePath
                        })
                    })
                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)
                    self.update()

                }
            })

        }