| import 'pages/products/parameters/parameters-groups-list.tag'
| import 'pages/products/parameters/parameters-list.tag'

parameters
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li.active #[a(data-toggle='tab', href='#palametrs-list') Список параметров]
        li #[a(data-toggle='tab', href='#parameters-groups') Категории]

    .tab-content
        #palametrs-list.tab-pane.fade.in.active
            parameters-list()
        #parameters-groups.tab-pane.fade
            parameters-groups-list()

    script(type='text/babel').
        var self = this,
        route = riot.route.create()
        self.on('mount', () => {
        riot.route.exec()
        })