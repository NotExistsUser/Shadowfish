TEMPLATE = subdirs
SUBDIRS = \
    dbus \
    icons \
    settings \
    shadow \
    v2ray 

OTHER_FILES += rpm/shadowfish.spec \
               settings/mainpage.qml \
               settings/aboutpage.qml   \
               settings/database.js   \
               settings/addconfigpage.qml \
               settings/EnableSwitch.qml \
               settings/viewpage.qml \
               settings/clipboardutil.js \
               settings/fileutil.js \
               settings/settings-v2ray.json \
               v2ray/config.json \
               v2ray/shadowfish.sh \
               translations/*.ts \
               dbus/* \
               systemd/myv2ray.service



TRANSLATIONS += translations/settings-network-v2ray.ts \
                translations/settings-network-v2ray-zh_CN.ts

#translations
translations.files += translations/*.qm
translations.path = /usr/share/translations/

system(lupdate . -ts $$PWD/translations/settings-network-v2ray.ts)
system(lupdate . -ts $$PWD/translations/settings-network-v2ray-zh_CN.ts)
#system(lrelease -idbased $$PWD/translations/*.ts)
system(lrelease $$PWD/translations/*.ts)

INSTALLS += translations 