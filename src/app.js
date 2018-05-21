import md5 from 'blueimp-md5/js/md5.min.js'

var app = {
    auth: false,
    accounts: [],
    permissions: {},
    config: {},
    mainCookie: ''
}

riot.observable(app)

app.checkUnsupported = () => {
    if (window.FormData === undefined) return true
    if (window.FileReader === undefined) return true
    if (typeof document.createElement("canvas").getContext !== 'function') return true
    return false
}

app.login = params => {
    $.ajax({
        url: 'https://api.siteedit.ru/api/host.php?project=' + params.project.trim(),
        dataType: 'json',
        success(response) {
            if (response.status === 'ok') {
                var secookie = md5(Date.now())
                API.url = `${response.data.hostApi}/api/`

                API.request({
                    object: 'Auth',
                    method: 'Info',
                    data: {
                        login: params.serial.toString().trim(),
                        hash: params.password.trim()
                    },
                    beforeSend(request) {
                        request.setRequestHeader('Project', response.data.project)
                        request.setRequestHeader('Secookie', secookie)
                    },
                    success(response) {
                        if (typeof params.success === 'function')
                            params.success.bind(this, response, secookie)()
                    },
                    error(response) {
                        if (typeof params.error === 'function')
                            params.error.bind(this, response)()
                    }
                })

            }
            if (response.status === 'error') {
                if (typeof params.error === 'function')
                    params.error.bind(this, response)()
            }
        },
        error(response) {
            if (typeof params.error === 'function')
                params.error.bind(this, response)()
        }
    })
}

app.init = () => {
    let storage = JSON.parse(localStorage.getItem('shop24') || '{}')

    if (storage && storage.domain) {
        app.config.project = storage.project
        app.config.version = storage.version
        app.config.lang = 'rus'
        app.config.projectURL = `${storage.domain}/`
        app.config.isAdmin = storage.isAdmin || false
        app.config.idUser = storage.idUser || 0
        app.auth = true
    } else {
        app.auth = false
    }

    if (!app.auth) {
        observable.trigger('auth', app.auth)
        return
    }

    let permissions = JSON.parse(localStorage.getItem('shop24_permissions') || '[]')

    if (permissions) {
        permissions.forEach(item => {
            app.permissions[item.code] = item.mask
        })
    }

    let mainUser = JSON.parse(localStorage.getItem('shop24_main_user') || '{}')
    let config = JSON.parse(localStorage.getItem('shop24') || '{}')

    if (config && mainUser &&
        'login' in config &&
        'login' in mainUser &&
        config.login !== mainUser.login) {
        app.login({
            project: mainUser.project,
            serial: mainUser.login,
            password: mainUser.hash,
            success(response, secookie) {
                API.request({
                    object: 'Account',
                    method: 'Fetch',
                    cookie: secookie,
                    unauthorizedReload: false,
                    success(response) {
                        app.mainCookie = secookie
                        if ('items' in response &&
                            response.items instanceof Array) {
                            app.accounts = response.items
                        }
                    },
                    complete() {
                        observable.trigger('auth', app.auth)
                    }
                })
            },
            error(response) {
                observable.trigger('auth', app.auth)
            }
        })
    } else {
        API.request({
            object: 'Account',
            method: 'Fetch',
            unauthorizedReload: false,
            success(response) {
                app.mainCookie = localStorage.getItem('shop24_cookie')
                if ('items' in response &&
                    response.items instanceof Array) {
                    app.accounts = response.items
                }
            },
            complete() {
                observable.trigger('auth', app.auth)
            }
        })
    }
}

app.restoreSession = user => {
    let params = JSON.parse(user)
    let secookie = md5(Date.now())
    API.url = `${params.uri}/api/`

    API.request({
        object: 'Auth',
        method: 'Info',
        unauthorizedReload: false,
        data: params,
        beforeSend(request) {
            request.setRequestHeader('Secookie', secookie)
            request.setRequestHeader('Project', params.project)
        },
        success(response) {
            if (response.permissions) {
                localStorage.setItem('shop24_permissions', response.permissions)
                app.permissions = response.permissions
            }

            localStorage.setItem('shop24_cookie', secookie)
            localStorage.setItem('shop24', JSON.stringify(response.config))
            app.init()
            riot.route.start(true)
        },
        error() {
            localStorage.removeItem('shop24')
            localStorage.removeItem('shop24_permissions')
            localStorage.removeItem('shop24_cookie')
            localStorage.removeItem('shop24_user')
            localStorage.removeItem('shop24_main_user')
            observable.trigger('auth', app.auth)
        }
    })
}

app.getImageUrl = function (name, section, lang = 'rus') {
    return `${app.config.projectURL}images/${lang}/${section}/${name}`
}

app.getImagePreviewURL = function (name, section, size = 64, lang = 'rus') {
    return `${app.config.projectURL}lib/image.php?size=${size}&img=images/${lang}/${section}/${name}`
}

app.insertText = function () {
    this.target = null

    this.focus = function (e) {
        this.target = e.target
    }

    this.insert = function (e) {
        if (this.target) {
            var value = this.target.value
            var start = this.target.selectionStart
            var end = this.target.selectionEnd
            var newstr = value.substr(0, start) + e.target.innerHTML + value.substr(end)
            this.target.value = newstr
            this.target.selectionEnd = this.target.selectionStart = start + e.target.innerHTML.length
            this.target.focus()
            var event = document.createEvent('Event')
            event.initEvent('change', true, true)
            this.target.dispatchEvent(event)
        }
    }

    return this
}

if (process.env.NODE_ENV === 'development')
    window.app = app

module.exports = app