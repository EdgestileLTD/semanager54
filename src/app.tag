| import md5 from 'blueimp-md5/js/md5.min.js'
| import 'pages/auth.tag'
| import 'pages/orders/orders.tag'
| import 'pages/products/products.tag'
| import 'pages/sections/sections.tag'
| import 'pages/persons/persons.tag'
| import 'pages/comments/comments.tag'
| import 'pages/news/news.tag'
| import 'pages/user-reviews.tag'
| import 'pages/images/images-manager.tag'
| import 'pages/images/images.tag'
| import 'pages/settings/settings.tag'
| import 'pages/payments/payments.tag'
| import 'pages/analytics/analytics.tag'
| import 'pages/not-found.tag'
| import 'modals/account-add-modal.tag'
| import 'modals/account-settings-modal.tag'
| import 'pages/settings/add-fields/add-fields-edit-block.tag'
| import parallel from 'async/parallel'

// ГЛАВНАЯ СТРАНИЦА МЕНЕДЖЕРА

include src/blocks/old-browser.pug

app
    div(if="{ unsupported }")
        +oldBrowser

    loader(if='{ loader }', size='large', text='Загрузка')
    auth(if='{ !app.auth && !loader }')
    images-manager(if='{ imageLoad && !loader }')

    .app-layout(if='{ sidebarShow }', onclick='{ toggleSidebar }')

    .wrapper(if='{ !unsupported && app.auth && !loader && !imageLoad }')
        .sidebar-left(class='{ active: sidebarShow }')
            .logo
            .menu
                .menu__up(onclick='{ scrollMenuTop }', style='display: none;')
                .menu__down(onclick='{ scrollMenuBottom }')
                ul(onscroll='{ onResize }')
                    li(each='{ sidebar }', if='{ checkPermission(permission, 1000) }', class='{ active: name == tab }')
                        a(href='#\{ link \}')
                            i(class='fa { icon }')
                            span { title }
                    //li.hidden-md.hidden-sm.hidden-lg
                    //    a
                    //        i.fa.fa-globe
                    //        span Аккаунты
                    //    ul.dropdown-menu
                    //        li
                    //            a(href='#', onclick='{ accountAdd }')
                    //                i.fa.fa-fw.fa-plus.text-success
                    //                |  Добавить
                    //        li.divider(if='{ app.accounts.length }')
                    //        li(each='{ account, i in app.accounts }', class='{ active: activeLogin == account.login }')
                    //            a(href='{ "#": activeLogin != account.login }', onclick='{ activeLogin != account.login  ? accountChange : null }')
                    //                i.fa.fa-fw(class='{ "text-primary": activeLogin != account.login, "fa-home": account.isMain, "fa-globe": !account.isMain }')
                    //                |  { account.alias }
                    //        li.divider(if='{ app.accounts.length }')
                    //        li
                    //            a(href='#', onclick='{ accountSettings }')
                    //                i.fa.fa-fw.fa-pencil.text-danger
                    //                |  Управление аккаунтами
                    li.hidden-md.hidden-sm.hidden-lg
                        a(href='{ app.config.projectURL }', target='_blank', title='Перейти на сайт')
                            i.fa.fa-share
                            span Перейти на сайт
                    li.hidden-md.hidden-sm.hidden-lg
                        a(onclick='{ logout }', href='#')
                            i.fa.fa-sign-out
                            span Выход

        .main-container
            .navbar.navbar-default.navbar-fixed-top.m-b-2
                .container-fluid
                    .navbar-header
                        button(onclick='{ toggleSidebar }', type='button', class='navbar-toggle pull-left m-x-2')
                            span.sr-only
                            span.icon-bar
                            span.icon-bar
                            span.icon-bar
                        a.navbar-brand { headTitle || 'Shop 24' }

                    .navbar-collapse.collapse
                        ul.nav.navbar-nav.navbar-right
                            li.dropdown
                                a.dropdown-toggle(href='#', data-toggle='dropdown', role='button', aria-haspopup='true',
                                aria-expanded='false')
                                    | { app.config.project }
                                    span.caret
                                ul.dropdown-menu
                                    li
                                        a(href='#', onclick='{ accountAdd }')
                                            i.fa.fa-fw.fa-plus.text-success
                                            |  Добавить
                                    li.divider(if='{ app.accounts.length }')
                                    li(each='{ account, i in app.accounts }', class='{ active: activeLogin == account.login }')
                                        a(href='{ "#": activeLogin != account.login }', onclick='{ activeLogin != account.login  ? accountChange : null }')
                                            i.fa.fa-fw(class='{ "text-primary": activeLogin != account.login, "fa-home": account.isMain, "fa-globe": !account.isMain }')
                                            |  { account.alias }
                                    li.divider(if='{ app.accounts.length }')
                                    li
                                        a(href='#', onclick='{ accountSettings }')
                                            i.fa.fa-fw.fa-pencil.text-danger
                                            |  Управление аккаунтами
                            li(if='{ app.config.projectURL }')
                                a(href='{ app.config.projectURL }', target='_blank', title='Перейти на сайт')
                                    i.fa.fa-share
                            li
                                a(onclick='{ logout }', href='#')
                                    i.fa.fa-fw.fa-sign-out
                                    | Выход
            .main.col-md-12(style='width: 100%;')
                desktop(if='{ tab == "desktop" }')
                    h4 Рабочий стол - в разработке
                orders(if='{ tab == "orders" }')
                products(if='{ tab == "products" }')
                payments(if='{ tab == "payments" }')
                persons(if='{ tab == "persons" }')
                news(if='{ tab == "news" }')
                user-reviews(if='{ tab == "reviews" }')
                images(if='{ tab == "images" }')
                sections(if='{ tab == "sections" }')
                analytics(if='{ tab == "analytics" }')
                settings(if='{ tab == "settings" }')
                not-found(if='{ tab == "not-found" }')


    style(scoped).
        .app-layout {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #000;
            opacity: 0.7;
            z-index: 1100;
        }

    script(type='text/babel').
        var self = this

        self.app = app
        self.mixin('permissions')
        self.auth = false
        self.sidebarShow = false
        self.loader = true
        self.auth = app.auth
        self.imageLoad = false;

        var route = riot.route.create()

        route(tab => {
            if (tab == '') {
                if (self.checkPermission(self.sidebar[1].permission, "1000")) {
                    riot.route(self.sidebar[1].link)
                } else {
                    let links = self.sidebar.filter(i => self.checkPermission(i.permission, "1000"))
                    if (links.length) {
                        riot.route(links[0].link)
                    } else {
                        riot.route('')
                        observable.trigger('not-found')
                    }
                }
            } else {
                if (tab == 'imageLoad') {
                    self.imageLoad = true
                    self.update()
                    return;
                }
                let idx = self.sidebar.map(item => item.name).indexOf(tab)
                if (idx !== -1 && self.checkPermission(self.sidebar[idx].permission, 1000)) {
                    var item = self.sidebar.filter(item => item.name === tab)
                    self.headTitle = item[0].title
                    self.tab = tab
                } else {
                    observable.trigger('not-found')
                }
            }
            self.sidebarShow = false
            document.body.classList.remove('modal-open')
            window.scrollTo(0, 0)
            self.update()
        })

        self.unsupported = app.checkUnsupported()

        self.sidebar = [
            {title: 'Аналитика', name: 'analytics', link: 'analytics', permission: '', icon: 'fa-area-chart '},
            {title: 'Заказы', name: 'orders', link: 'orders', permission: 'orders', icon: 'fa-shopping-cart'},
            {title: 'Товары', name: 'products', link: 'products', permission: 'products', icon: 'fa-shopping-bag'},
            {title: 'Платежи', name: 'payments', link: 'payments', permission: 'payments', icon: 'fa-money'},
            {title: 'Контакты', name: 'persons', link: 'persons', permission: 'contacts', icon: 'fa-users'},
            {title: 'Публикации', name: 'news', link: 'news', permission: 'news', icon: 'fa-newspaper-o'},
            {title: 'Отзывы', name: 'reviews', link: 'reviews', permission: 'reviews', icon: 'fa-comment-o'},
            {title: 'Разделы', name: 'sections', link: 'sections', permission: 'sections', icon: 'fa-file-text'},
            {title: 'Картинки', name: 'images', link: 'images/products', permission: 'images', icon: 'fa-picture-o'},
            {title: 'Настройки', name: 'settings', link: 'settings', permission: '', icon: 'fa-cogs'},
        ]

        self.toggleSidebar = () => {
            self.sidebarShow = !self.sidebarShow
            if (self.sidebarShow)
                document.body.classList.add('modal-open')
            else
                document.body.classList.remove('modal-open')
        }


        self.logout = () => {
            localStorage.removeItem('shop24')
            localStorage.removeItem('shop24_permissions')
            localStorage.removeItem('shop24_cookie')
            localStorage.removeItem('shop24_user')
            localStorage.removeItem('shop24_main_user')
            window.location.reload()
        }

        self.accountAdd = () => {
            modals.create('account-add-modal', {
                type: 'modal-primary',
                size: 'modal-sm'
            })
        }

        self.accountChange = e => {
            var account = e.item.account

            if (account.isMain) {
                let mainUser = JSON.parse(localStorage.getItem('shop24_main_user'))
                var { login, hash, project } = mainUser
            } else {
                var { login, hash, project } = account
            }

            app.login({
                project: project,
                serial: login,
                password: hash,
                success(response, secookie) {
                    if (response.permissions)
                        localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))

                    localStorage.setItem('shop24_cookie', secookie)
                    localStorage.setItem('shop24', JSON.stringify(response.config))
                    window.location.reload()
                },
                error(response) {
                    self.update()
                }
            })
        }

        self.accountSettings = () => {
            modals.create('account-settings-modal', {
                type: 'modal-primary'
            })
        }

        self.getActiveAccount = () => {
            let shop = JSON.parse(localStorage.getItem('shop24') || '{}')
            if ('login' in shop) {
                let { login } = shop
                let item = app.accounts.filter(item => item.login === login)[0] || {}
                if ('login' in item)
                    self.activeLogin = item.login
            }
        }

        observable.on('auth', auth => {
            if (auth)
                self.getActiveAccount()
            self.loader = false
            self.update()
        })

        observable.on('accounts-change', accounts => {
            if (accounts && accounts instanceof Array) {
                app.accounts = accounts
                self.update()
            } else {
                API.request({
                    object: 'Account',
                    method: 'Fetch',
                    cookie: app.mainCookie,
                    unauthorizedReload: false,
                    success(response) {
                        if ('items' in response &&
                            response.items instanceof Array) {
                            app.accounts = response.items
                            self.update()
                        }
                    },
                })
            }
        })

        observable.on('not-found', () => {
            self.headTitle = '404'
            self.tab = 'not-found'
            self.update()
        })

        self.onResize = e => {
            let menuWrapper = self.root.querySelector('.menu')
            let menuUp = menuWrapper.querySelector('.menu__up')
            let menuDown = menuWrapper.querySelector('.menu__down')
            let menu = menuWrapper.querySelector('ul')

            if (menu.scrollTopMax === 0) {
                menuUp.style.display = 'none'
                menuDown.style.display = 'none'
            } else {
                if (menu.scrollTop === 0) {
                    menuUp.style.display = 'none'
                    menuDown.style.display = 'block'
                }

                if (menu.scrollTop === menu.scrollTopMax) {
                    menuUp.style.display = 'block'
                    menuDown.style.display = 'none'
                }

                if (menu.scrollTop !== 0 && menu.scrollTop !== menu.scrollTopMax) {
                    menuUp.style.display = 'block'
                    menuDown.style.display = 'block'
                }

            }
        }

        self.scrollMenuTop = e => {
            $(self.root).find('.menu ul').animate({scrollTop: 0}, '300')
        }

        self.scrollMenuBottom = e => {
            let menu = $(self.root).find('.menu ul')[0]
            let scroll = menu.scrollTopMax
            $(menu).animate({scrollTop: scroll}, '300')
        }

        self.parseGetParams = () => {
            var $_GET = {};
            var __GET = window.location.search.substring(1).split("&");
            for(var i = 0; i < __GET.length; i++) {
                var getVar = __GET[i].split("=");
                $_GET[getVar[0]] = typeof(getVar[1])=="undefined" ? "" : getVar[1];
            }
            return $_GET;
        }

        self.on('mount', () => {
            let params = self.parseGetParams()
            if (params.project && params.login && params.password) {
                localStorage.removeItem('shop24_cookie')
                app.login({
                    project: params.project.trim(),
                    serial: params.login.trim(),
                    password: md5(params.password.trim()),
                    success(response, secookie) {
                        var mainUser = {
                            project: params.project.trim(),
                            login: params.login.trim(),
                            hash: md5(params.password.trim()),
                        }

                        localStorage.setItem('shop24_main_user', JSON.stringify(mainUser))
                        localStorage.setItem('shop24_cookie', secookie)
                        localStorage.setItem('shop24', JSON.stringify(response.config))
                        if (response.permissions)
                            localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))
                        location.search = ''
                    }
                })
                return
            }

            if (localStorage.getItem('shop24_cookie') !== null) {
                API.authCheck({
                    success(response) {
                        if (response.permissions)
                            localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))

                        app.init()
                        riot.route.start(true)
                    },
                    error() {
                        let user = localStorage.getItem('shop24_user')

                        if (user) {
                            app.restoreSession(user)
                        } else {
                            app.init()
                            riot.route.start(true)
                        }
                    }
                })
            } else {
                app.init()
                riot.route.start(true)
            }

            window.addEventListener('resize', self.onResize)


            self.on('unmount', () => {
                window.removeEventListener('resize', self.onResize)
            })

        })