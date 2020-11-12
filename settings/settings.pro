TEMPLATE = aux
#jolla-settings pages
settings.files = mainpage.qml \
                aboutpage.qml \
                addconfigpage.qml \
                EnableSwitch.qml \
                viewpage.qml \
                database.js \
                clipboardutil.js \
                fileutil.js \
                config.json.template \
                v2ray.png
settings.path = /usr/share/jolla-settings/pages/v2ray/
INSTALLS += settings


#jolla-settings entries
entries.files = settings-v2ray.json
entries.path = /usr/share/jolla-settings/entries/
INSTALLS += entries