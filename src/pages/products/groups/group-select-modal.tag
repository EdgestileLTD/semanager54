

group-select-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title Категории
        #{'yield'}(to="body")
           catalog-tree(
                object          = 'Category',
                add             = '{ add }',
                label-field     = '{ "name" }',
                children-field  = '{ "childs" }',
                handlers        = '{ handlers }',
                reload          = 'true',
                search          = 'true',
                dblclick        = '{ parent.opts.submit.bind(this) }',
                exception       = '{ parent.opts.id }',
           )
               #{'yield'}(to='after')
                   span { this[parent.childrenField].length ? "[" + this[parent.childrenField].length + "]" : "" }
        #{'yield'}(to='footer')
            button(
                onclick ='{ modalHide }',
                type    ='button',
                class   ='btn btn-default btn-embossed'
            ) Закрыть
            button(
                onclick ='{ parent.opts.submit.bind(this) }',
                type    ='button',
                class   ='btn btn-primary btn-embossed'
            ) Выбрать

    style(scoped).
        .tree {
            display         : inline-block;
            border-left     : 1px solid grey;
            border-bottom   : 1px solid grey;
            width           : 10px;
            height          : 10px;
            margin-bottom   : 5px;
            margin-right    : 5px;
        }

    script(type='text/babel').
        var self = this