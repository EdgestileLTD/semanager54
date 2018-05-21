| import './seo-vars-macro.tag'
| import './seo-vars-word-exclude.tag'

seo-vars
    ul.nav.nav-tabs.m-b-2
        li.active #[a(data-toggle='tab', href='#seo-vars-macro') Макропеременные]
        li #[a(data-toggle='tab', href='#seo-vars-word-exclude') Слова исключения]

    .tab-content
        #seo-vars-macro.tab-pane.fade.in.active
            seo-vars-macro
        #seo-vars-word-exclude.tab-pane.fade
            seo-vars-word-exclude