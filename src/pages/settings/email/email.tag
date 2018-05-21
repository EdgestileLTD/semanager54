| import './email-settings.tag'
| import './email-templates.tag'
//| import './sms-journal.tag'

email
    ul.nav.nav-tabs.m-b-2
        li.active
            a(data-toggle='tab', href='#email-settings') Настройки
        li
            a(data-toggle='tab', href='#email-templates') Шаблоны
        //li
            a(data-toggle='tab', href='#email-journal') Журнал

    .tab-content
        #email-settings.tab-pane.fade.in.active
            email-settings
        #email-templates.tab-pane.fade
            email-templates
        //#email-journal.tab-pane.fade
            email-journal
