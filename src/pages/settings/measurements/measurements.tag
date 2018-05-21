| import './measure-weight.tag'
| import './measure-volume.tag'

measurements
    ul.nav.nav-tabs.m-b-2
        li.active
            a(data-toggle='tab', href='#measure-weight') Меры веса
        li
            a(data-toggle='tab', href='#measure-volume') Меры объема

    .tab-content
        #measure-weight.tab-pane.fade.in.active
            measure-weight
        #measure-volume.tab-pane.fade
            measure-volume

