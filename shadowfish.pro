# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = shadowfishd

QT += core dbus

system(qdbusxml2cpp dbus/xyz.freedom.v2ray.xml -i src/jolla-settings-v2ray.h -a src/adaptor)

SOURCES += src/main.cpp \
    src/jolla-settings-v2ray.cpp \
    src/adaptor.cpp

HEADERS += \
    src/jolla-settings-v2ray.h \
    src/adaptor.h

target.path = /usr/bin
INSTALLS += target


OTHER_FILES += rpm/shadowfish.spec \
               settings/mainpage.qml \
               settings/aboutpage.qml   \
               settings/database.js   \
               settings/addconfigpage.qml \
               settings/viewpage.qml \
               settings/clipboardutil.js \
               settings/fileutil.js \
               settings/settings-v2ray.json \
               v2ray/config.json \
               v2ray/shadowfish.sh \
               translations/*.ts \
               dbus/* \
               systemd/myv2ray.service


# DBus service
dbusService.files = dbus/xyz.freedom.v2ray.service
dbusService.path = /usr/share/dbus-1/system-services/
INSTALLS += dbusService

# DBus interface
dbusInterface.files = dbus/xyz.freedom.v2ray.xml
dbusInterface.path = /usr/share/dbus-1/interfaces/
INSTALLS += dbusInterface

# DBus config
dbusConf.files = dbus/xyz.freedom.v2ray.conf
dbusConf.path = /etc/dbus-1/system.d/
INSTALLS += dbusConf

# DBus service 2
dbusService2.files = dbus/projectv.v2ray.service \
                                 systemd/myv2ray.service
dbusService2.path = /lib/systemd/system/
INSTALLS += dbusService2

#jolla-settings pages
settings.files = settings/mainpage.qml \
                settings/aboutpage.qml \
                settings/addconfigpage.qml \
                settings/viewpage.qml \
                settings/database.js \
                settings/clipboardutil.js \
                settings/fileutil.js \
                settings/v2ray.png
settings.path = /usr/share/jolla-settings/pages/v2ray/
INSTALLS += settings


#jolla-settings entries
entries.files = settings/settings-v2ray.json
entries.path = /usr/share/jolla-settings/entries/
INSTALLS += entries

#sh script
sh.files = v2ray/shadowfish.sh
sh.path = /usr/bin/
INSTALLS += sh


#icons
icons.files = icons/*
icons.path = /usr/share/themes/sailfish-default/meegotouch/
INSTALLS += icons

#v2ray config json
v2conf.files = v2ray/config.json.template
v2conf.path = /home/nemo/.config/v2ray/
INSTALLS += v2conf

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


