| import 'pages/settings/permissions/permissions-users.tag'
| import 'pages/settings/permissions/permissions-roles.tag'

permissions
    ul.nav.nav-tabs.m-b-2
        li.active #[a(data-toggle='tab', href='#permissions-users') Пользователи]
        li #[a(data-toggle='tab', href='#permissions-roles') Роли]

    .tab-content
        #permissions-users.tab-pane.fade.in.active
            permissions-users
        #permissions-roles.tab-pane.fade
            permissions-roles