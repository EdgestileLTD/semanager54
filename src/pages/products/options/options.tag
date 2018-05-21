| import 'pages/products/options/options-groups-list.tag'
| import 'pages/products/options/options-list.tag'

options
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li.active #[a(data-toggle='tab', href='#options-list') Опции]
        li #[a(data-toggle='tab', href='#options-groups') Группы]

    .tab-content
        #options-list.tab-pane.fade.in.active
            options-list()
        #options-groups.tab-pane.fade
            options-groups-list()

    script(type='text/babel').
        var self = this,
        route = riot.route.create()
        self.on('mount', () => {
        riot.route.exec()
        })