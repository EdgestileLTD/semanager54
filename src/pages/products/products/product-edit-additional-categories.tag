| import 'components/catalog-static.tag'
| import 'components/tags.tag'
| import 'pages/products/groups/group-select-modal.tag'

product-edit-additional-categories
    .input-group
        tags.form-control(name='{ opts.name }', value='{ value }')
        span.input-group-addon(onclick='{ add }')
            i.fa.fa-plus

    script(type='text/babel').
        var self = this

        self.mixin('permissions')

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value
            },
            set(value) {
                self.value = value
                self.update()
            }
        })


        self.add = () => {
            modals.create('group-select-modal', {
                type: 'modal-primary',
                submit() {
                    self.value = self.value || []
                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                    let ids = self.value.map(item => item.id)

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1)
                            self.value.push(item)
                    })

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.on('update', () => {
            if ('name' in opts && opts.name !== '')
                self.root.name = opts.name

            if ('value' in opts)
                self.value = opts.value || []
        })