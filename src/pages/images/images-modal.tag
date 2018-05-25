images-modal
    bs-modal
        #{'yield'}(to='title')
            .h4.modal-title Картинки
        #{'yield'}(to='body')
            filemanager(onSelectImage='{ parent.opts.submit.bind(this) }')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Сохранить

    style(scoped).
        :scope .filemanager__body {
            min-height: calc(100vh - 315px) !important;
        }

    script(type='text/babel').
        let self = this

        self.on('mount', () => {
            let modal = self.tags['bs-modal']
            modal.tags.filemanager.reload()
        })