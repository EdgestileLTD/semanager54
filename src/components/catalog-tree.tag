| import debounce from 'lodash/debounce'
| import 'components/treeview.tag'

catalog-tree
    .row(if='{ opts.add || opts.reload || opts.remove || opts.search }')
        .col-md-8.col-sm-6.col-xs-12
            .form-inline.m-b-2
                button.btn(if='{ opts.allselect && (totalCount > 0)  }', type='button', class='{ allMode ? "btn-primary" : "btn-default"  }',
                onclick='{ selectedAll }', title='{ allMode ? "Снять выделение" : "Выделить всё" }')
                    i.fa(class='{ allMode ? "fa-toggle-on" : "fa-toggle-off" }')
                button.btn.btn-primary( if='{ opts.add }',                      onclick='{ opts.add }',                         type='button')
                    i.fa.fa-plus
                    |  Добавить
                button.btn.btn-success( if='{ opts.reload }',                   onclick='{ reload }',   title='Обновить',       type='button')
                    i.fa.fa-refresh
                button.btn.btn-primary( if='{ opts.deselall }',                 onclick='{ deselAll }', title='Показать все',   type='button')
                    i.fa.fa-share
                button.btn.btn-danger(  if='{ opts.remove && selectedCount }',  onclick='{ remove }',   title='Удалить',        type='button')
                    i.fa.fa-trash { (selectedCount > 1) ? "&nbsp;" : "" }
                    span.badge(if='{ selectedCount > 1 }') { selectedCount }
                #{'yield'}(from='head')
        .col-md-4.col-sm-6.col-xs-12
            form.form-inline.text-right.m-b-2
                .form-group
                    .input-group(if='{ opts.search }')
                        input.form-control(name='search', type='text', placeholder='Поиск', onkeyup='{ find }')
                        span.input-group-btn
                            button.btn.btn-default(onclick='{ find }', type='submit')
                                i.fa.fa-search

    .row
        .col-md-12
            treeview(
                nodes           ='{ nodes }',
                handlers        ='{ opts.handlers }',
                label-field     ='{ opts.labelField }',
                children-field  ='{ opts.childrenField }',
                loader          ='{ loader }',
                descendants     ='{ opts.descendants }',
                dblclick        ='{ opts.dblclick }'
            )
                #{'yield'}(to='before')
                    #{'yield'}(from='before')
                #{'yield'}(to='after')
                    #{'yield'}(from='after')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.allMode = false;
        self.nodes = []
        self.selectedCount = 0
        self.handlers = opts.handlers


        // перезагрузить
        self.reload = () => {
            self.trigger('reload')
            self.allMode = false;
            self.loader = true
            self.update()
            self.deselAll();

            var params = {}
            params.isTree = true

            if (opts.search && self.search) {
                params.searchText = self.search.value
            }

            /** API.request
             *
             * @param str opts.object  exp:Category
             * @param bool isTree  true-древовидный список
             * @param str searchText  искомый текст
             * @return array response.items  массив групп
             */
            API.request({
                object: opts.object,
                method: 'Fetch',
                data: params,
                success(response) {
                    self.nodes = response.items
                    if (opts.exception) {
                        self.tags.treeview.exceptionFilter(self.nodes, opts.exception)
                    }
                    self.totalCount = response.items.length
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        }

        // выделить все
        self.selectedAll = () => {
            //self.allMode = self.tags.treeview.selectAllRows(self.allMode);
            if (self.allMode == false) {
                self.allMode = true
                self.selectedCount = self.totalCount
                self.tags.treeview.selectAllRows();
            } else {
                self.deselAll();
            }

            observable.trigger('catalog-recount',true);
        }


        // сброс выбора в списке
        self.deselAll = e => {
            self.allMode = false
            self.selectedCount = 0
            self.tags.treeview.deselectAll()
            observable.trigger('products-reload', []) // перезагрузка листа товаров
        }


        self.remove = e => {
            /** удалить
             * 1 обнулить выделение элементов
             */

            var _this = this

            let items = self.tags.treeview.getSelectedNodes()
            let itemsToRemove = items.map(i => i.id)

            if (opts.remove)
                opts.remove.bind(this, e, itemsToRemove, self)()

            self.deselAll(); //1
        }

        self.find = debounce(e => {
            self.reload()
        }, 400)

        self.on('mount', () => {
            self.reload()
        })

        self.on('update', () => {
            self.handlers = opts.handlers
            if (self.selectedCount != self.totalCount) {
                self.allMode = false
            }
        })

        self.one('updated', () => {
            self.tags.treeview.on('nodeselect', (item, count) => {
                self.selectedCount = count
                if(self.selectedCount === self.totalCount){
                    self.allMode = true
                }
                self.update()
            })
        })
