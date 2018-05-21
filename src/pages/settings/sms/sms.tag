| import './sms-settings.tag'
| import './sms-templates.tag'
| import './sms-journal.tag'

sms
    ul.nav.nav-tabs.m-b-2
        li.active
            a(data-toggle='tab', href='#sms-settings') Настройки
        li
            a(data-toggle='tab', href='#sms-templates') Шаблоны
        li
            a(data-toggle='tab', href='#sms-journal') Журнал

    .tab-content
        #sms-settings.tab-pane.fade.in.active
            sms-settings
        #sms-templates.tab-pane.fade
            sms-templates
        #sms-journal.tab-pane.fade
            sms-journal
