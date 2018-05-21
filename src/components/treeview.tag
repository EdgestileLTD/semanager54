treeview
    loader(if='{ opts.loader }')
    treenodes(
        if             = '{ !opts.loader }',
        nodes          = '{ nodes }',
        handlers       = '{ opts.handlers }',
        treeview       = '{ this }',
        label-field    = '{ labelField }',
        children-field = '{ childrenField }',
        dblclick       = '{ opts.dblclick }'
    )
        #{'yield'}(to='before')
            #{'yield'}(from='before')
        #{'yield'}(to='after')
            #{'yield'}(from='after')

    script(type='text/babel').
        var self = this

        self.nodes = []
        self.labelField = opts.labelField || 'label'
        self.childrenField = opts.childrenField || 'children'
        self.descendants = opts.descendants || undefined

        self.toggleChildren = (node, value) => {
            if (node[self.childrenField] && node[self.childrenField] instanceof Array) {
                node[self.childrenField].forEach(item => {
                    item.__selected__ = value
                    self.toggleChildren(item, value)
                })
            }
        }

        self.toggleParent = item => {
            if (item.__parent__) {
                let parent = item.__parent__
                if (parent instanceof Object && !(parent instanceof Array)) {
                    let selected = parent[self.childrenField].map(i => i.__selected__).indexOf(false) <= -1
                    parent.__selected__ = selected
                    self.toggleParent(parent)
                }

            }
        }

        self.deselectAll = (nodes = self.nodes) => {
            if (nodes instanceof Array) {
                nodes.forEach(item => {
                    item.__selected__ = false
                    if (item[self.childrenField])
                        self.deselectAll(item[self.childrenField])
                })
            }
        }

        /** Выделить все
         * Запускает рекурсивную функцию для выделения элементов всех уровней
         *
         * @param array nodes  нумерованный массив с информацией об элементах
         */
        self.selectAllRows = (nodes = self.nodes) => {
            selectAllRowsChildren(nodes)
        }

        /** Исключить из списка
         *
         * @param array nodes  нумерованный массив с информацией об элементах
         * @param str exception id редактируемой группы для исключения из списка
         */
        self.exceptionFilter = (nodes, exception) => {
            exceptionFilter(nodes, exception)
        }

        self.getSelectedNodes = (nodes = self.nodes) => {
            let result = []

            if (nodes instanceof Array) {
                nodes.forEach(item => {
                    if (item.__selected__)
                        result.push(item)
                    if (item[self.childrenField]) {
                        let childResult = self.getSelectedNodes(item[self.childrenField])
                        result = [...result, ...childResult]
                    }
                })
                return result
            }
            return []
        }

        /** Рекурсивная функция выделения всех строк в древовидном списке (включая детей)
         *
         * @param array nodes  нумерованный массив с информацией об элементах
         * @var array item["childs"] нумерованный массив с информацией о Дочерних элементах
         */
        function selectAllRowsChildren(nodes) {
            if (nodes instanceof Array) {
                nodes.forEach(item => {
                    if (item["childs"] && item["childs"].length > 0) {
                        selectAllRowsChildren(item["childs"])
                    }
                    item.__selected__ = true
                })
            }
        }

        /** Рекурсия исключения из древовидного списка
         * 1 запускаем цикл прохода по уровню
         * 2 если id совпадает с исключением - удаляем из массива, заканчиваем поиск
         * 3 если исключение не сработало и есть элементы-дети - запускаем проверку уровня ниже
         * 4 если исключение встретилось в нижних уровнях и вернулось true - заканчиваем поиск
         *
         * @param array nodes  нумерованный массив с информацией об элементах
         * @param str exception id редактируемой группы для исключения из списка
         * @return bool true - исключение найденно
         */
        function exceptionFilter(nodes, exception) {
            if (nodes instanceof Array) {                      // 1
                nodes.forEach(function(item, index, object) {
                    if (item["id"] == exception) {             // 2
                        object.splice(index, 1)
                        return true
                    }
                    if (item["childs"].length > 0) {           // 3
                        var stop = exceptionFilter(item["childs"],exception)
                        if(stop == true) return true           // 4
                    }
                })
            }
        }

        function setParentLinks(nodes, parent = self.nodes) {
            if (nodes instanceof Array) {
                nodes.forEach(item => {
                    Object.defineProperty(item, '__parent__', {
                        writable: true,
                        configurable: true,
                        enumerable: false,
                        value: parent
                    })
                    if (typeof(item) === 'object' && item[self.childrenField])
                        setParentLinks(item[self.childrenField], item)
                })
            }
        }

        self.on('update', () => {
            self.labelField = opts.labelField || 'label'
            self.childrenField = opts.childrenField || 'children'
            self.descendants = opts.descendants || undefined

            if (self.nodes !== opts.nodes) {
                self.nodes = opts.nodes || []
                setParentLinks(self.nodes)
            }
        })

treenodes
    ul(each='{ nodes }')
        li
            div(class='treenode{ __selected__ ? " selected" : "" }', title='{ title }',
            onclick='{ select }', ondblclick='{ dblclick }')
                span(class='icon { this[parent.childrenField].length ? expanded ? css.open  : css.closed : css.leaf }', onclick='{ toggleExpand }')
                #{'yield'}(from='before')
                span(class='{ this[parent.childrenField].length ? "" : "leaf" }', draggable="true", ondragstart='{ handleDragStart }',
                ondragenter='{ handleDragEnter }', ondragover='{ handleDragOver }', ondragleave='{ handleDragLeave }',
                ondrop='{ handleDrop }', ondragend='{ handleDragEnd }') { this[parent.labelField] }
                #{'yield'}(from='after')
            hr(class='drop', ondragenter='{ handleDragEnterHr }', ondragleave='{ handleDragLeaveHr }', ondragover='{ handleDragOverHr }',
                ondrop='{ handleDropHr }')
            treenodes(nodes='{ this[parent.childrenField] }', dblclick='{ dblclick }', handler='{ parent.handler }', css='{ parent.css }', if='{ expanded }',
            handlers='{ handlers }', treeview='{ treeview }', label-field='{ labelField }', children-field='{ childrenField }')
                #{'yield'}(to='before')
                    #{'yield'}(from='before')
                #{'yield'}(to='after')
                    #{'yield'}(from='after')

    style(scoped).
        ul {
            list-style: none;
            padding-left: 2em;
            margin: 0.25em 0;
        }
        li {
            cursor: pointer;
        }
        .icon {
            width: 1.1em;
        }
        .treenode.selected {
            background-color: #d9edf7;
        }
        .treenode span.highlight {
            border: 2px dashed #000;
        }
        hr.drop {
            margin: 0;
            padding-top: 3px;
            padding-bottom: 3px;
            border: 0;
            border-top: 1px solid #fff;
        }
        hr.drop.highlight {
            padding-top: 8px;
            padding-bottom: 8px;
            border-top: 2px solid #000;
        }

    script(type='text/babel').
        var self = this

        self.treeview = opts.treeview
        self.labelField = opts.labelField || 'label'
        self.childrenField = opts.childrenField || 'children'

        self.nodes = opts.nodes || []


        var doubleClick = opts.dblclick || function (e) {}

        self.on('update', () => {
            self.title = opts.title
            self.css = opts.css  || {open: 'fa fa-fw fa-caret-down', closed: 'fa fa-fw fa-caret-right' , leaf: 'fa fa-fw'}
            self.nodes = opts.nodes || []
            self.handlers = opts.handlers || {}
            self.labelField = opts.labelField || 'label'
            self.childrenField = opts.childrenField || 'children'
        })

        self.dblclick = e => {
            doubleClick(e)
        }

        self.handleDragStart = e => {
            e.target.style.opacity = 0.5;
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('json', JSON.stringify(e.item));
            return true;
        }

        self.handleDragOver = e => {
            //console.log("DragOver")
        }

        self.handleDragEnterHr = e => {
            e.target.classList.add('highlight')
        }

        self.handleDragLeaveHr = e => {
            e.target.classList.remove('highlight')
        }

        self.handleDragOverHr = e => {

        }

        self.handleDragEnter = e => {
            if (e.fromElement)
                e.target.classList.add('highlight')

        }

        self.handleDragLeave = e => {
            e.target.classList.remove('highlight')
        }


        self.handleDrop = e => {
            e.target.classList.remove('highlight')
            var dataTransfer = JSON.parse(e.dataTransfer.getData("json"))
            if (dataTransfer.id == e.item.id) {
                e.stopPropagation();
                return false;
            }

            self.changeParent(self.treeview.nodes, e.item, dataTransfer.id)

            e.stopPropagation();
            return false;
        }

        self.handleDropHr = e => {
            e.target.classList.remove('highlight')
            var dataTransfer = JSON.parse(e.dataTransfer.getData("json"))
            if (dataTransfer.id == e.item.id) {
                e.stopPropagation();
                return false;
            }

            if (e.item.upid != dataTransfer.upid) {
                let itemParent = e.item.upid ? self.getItemById(self.treeview.nodes, e.item.upid) : null
                self.changeParent(self.treeview.nodes, itemParent, dataTransfer.id)
            }

            self.changePositionItem(e.item, dataTransfer.id)

            e.stopPropagation();
            return false;
        }

        self.handleDragEnd = e => {
            e.target.style.opacity = 1
            self.update()
        }

        self.toggleExpand = e => {
            e.stopPropagation()
            e.item.expanded = !e.item.expanded
        }

        self.getItemById = (nodes, id) => {

            for (let i = 0; i < nodes.length; i++) {
                if (nodes[i].id == id)
                  return nodes[i]

                if (nodes[i][self.childrenField]) {
                    let result = self.getItemById(nodes[i][self.childrenField], id)
                    if (result)
                      return result
                }
            }

            return null
        }

        self.changeParent = (nodes, itemParent, id) => {
            let indexDel = -1;

            nodes.forEach((item, i) => {
                if (item.id == id) {
                    indexDel = i
                    return
                }
            })
            if (indexDel > -1) {
                let item = nodes[indexDel]
                nodes.splice(indexDel, 1)
                let idParent = null
                let position = self.treeview.nodes.length
                if (itemParent) {
                    if (itemParent[self.childrenField].length > 0)
                        position = itemParent[self.childrenField][itemParent[self.childrenField].length - 1].position + 1
                    itemParent[self.childrenField].push(item)
                    idParent = itemParent.id
                } else self.treeview.nodes.push(item)


                if ('afterChangeParent' in self.handlers && typeof(self.handlers.afterChangeParent) === 'function')
                    self.handlers.afterChangeParent.call(this, idParent, id, position)
            } else {
                nodes.forEach((item, i) => {
                    if (item[self.childrenField])
                        self.changeParent(item[self.childrenField], itemParent, id)
                })
            }
        }

        self.changePositionItem = (item, id) => {
            let nodes = self.getNodesWithId(self.treeview.nodes, id)
            let indexDel = -1;

            nodes.forEach((item, i) => {
                if (item.id == id) {
                    indexDel = i
                    return
                }
            })
            if (indexDel > -1) {
                let itemMove = nodes[indexDel]
                nodes.splice(indexDel, 1)
                nodes = self.getNodesWithId(self.treeview.nodes, item.id)
                if (nodes) {
                    let indexInsert = nodes.indexOf(item);
                    if (indexInsert > -1) {
                        nodes.splice(indexInsert + 1, 0, itemMove)
                        let indexes = []
                        nodes.forEach((item, sort) => {
                            item.sort = sort
                            indexes.push({id: item.id, sort: sort})
                        })
                        if ('afterChangePosition' in self.handlers && typeof(self.handlers.afterChangePosition) === 'function')
                            self.handlers.afterChangePosition.call(this, indexes)
                    }
                }
            }
        }

        self.getNodesWithId = (nodes, id) => {

            for (let i = 0; i < nodes.length; i++) {
                if (nodes[i].id == id)
                     return nodes

                if (nodes[i][self.childrenField]) {
                    let result = self.getNodesWithId(nodes[i][self.childrenField], id)
                    if (result)
                        return result
                }
            }

            return null
        }

        self.select = e => {
            if (e.ctrlKey) {
                e.item.__selected__ = !e.item.__selected__
                if (self.treeview.descendants) {
                    self.treeview.toggleChildren(e.item, e.item.__selected__)
                    self.treeview.toggleParent(e.item)
                    self.treeview.update()
                }
            } else {
                self.treeview.deselectAll()
                e.item.__selected__ = true
                if (self.treeview.descendants) {
                    self.treeview.toggleChildren(e.item, e.item.__selected__)
                }
                self.treeview.update()
            }

            let count = self.treeview.getSelectedNodes().length
            self.treeview.trigger('nodeselect', e.item, count)
        }

        self.stopPropagation = function (e) {
            e.stopPropagation()
        }