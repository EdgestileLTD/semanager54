images-gallery-modal
    bs-modal(name='modal')
        #{'yield'}(to='title')
            .h4.modal-title Библиотека изображений
        #{'yield'}(to='body')
            image-gallery(name='gallery')
        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

    script(type='text/babel').
        var self = this

        self.on('mount', () => {
            self.tags.modal.tags.gallery.update({params:{section: opts.section, limit: 10, offset: 0}})
            self.tags.modal.tags.gallery.reload()
        })