TEMPLATE = app
TARGET = shadowfishd

target.path = /usr/bin
INSTALLS += target

QT += core dbus

system(qdbusxml2cpp dbus/xyz.freedom.v2ray.xml -i src/jolla-settings-v2ray.h -a src/adaptor)

SOURCES += src/main.cpp \
    src/jolla-settings-v2ray.cpp \
    src/adaptor.cpp

HEADERS += \
    src/jolla-settings-v2ray.h \
    src/adaptor.h

